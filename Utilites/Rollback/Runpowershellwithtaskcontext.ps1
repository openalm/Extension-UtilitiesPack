
Param(
	[string] $type,
	[string] $rollbackpowershellfile,
	[string] $additionalarguments,
	[string] $workingFolder,
	[string] $script
)

Write-Verbose -Verbose "Type= $type" 
Write-Verbose -Verbose "ScriptPath= $rollbackpowershellfile" 
Write-Verbose -Verbose "ScriptArguments= $additionalarguments" 
Write-Verbose -Verbose "workingFolder = $workingFolder" 
Write-Verbose -Verbose "inlineScripe = $script" 
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

# Construct the REST URL to obtain Build ID
$releasequeryuri = "$($env:SYSTEM_TEAMFOUNDATIONSERVERURI)$($env:SYSTEM_TEAMPROJECT)/_apis/release/releases/$($env:Release_ReleaseId)/environments/$($env:RELEASE_ENVIRONMENTURI.Split('/')[-1])?api-version=2.1-preview.1"
$taskexecutioninfo = @{}
$releasequeryresult = $null
$personalAccessToken = $null

# Wait for 60 seconds for the job context to persist with the server (for accuracy)
sleep -Seconds 60

try
{
    Write-Verbose -Verbose "Getting Personal Access Token for the Run" 
    $vssEndPoint = Get-ServiceEndPoint -Name "SystemVssConnection" -Context $distributedTaskContext
    $personalAccessToken = $vssEndpoint.Authorization.Parameters.AccessToken

    if (!$personalAccessToken) 
    { 
       throw "Could not extract personal access token. Exitting"     
    } 

    # Invoke the REST call and capture the results
    Write-Verbose -Verbose "Calling $releasequeryuri using obtained PAT token"
    if ($personalAccessToken)
    {
        $releasequeryresult = Invoke-RestMethod -Uri $releasequeryuri -Method Get -ContentType "application/json" -Headers @{Authorization= "Bearer " + $personalAccessToken}            
    }
    else
    {
        Write-Verbose -Verbose "auth info not recieved"
    }
}
catch
{
    Write-Verbose -Verbose "Could not obtain release tasks status"
    foreach($err in $Error)
    {
        Write-Verbose -Verbose $err
    }

    $releasequeryresult = $null
}


if (!$releasequeryresult -or $releasequeryresult.count -eq 0)
{
    Write-Verbose -Verbose  "Release Query unsuccessful."
}
else
{    
    $tasks = $releasequeryresult.deploySteps | Sort-Object attempt -Descending | select -First 1
    $jobtasks = $tasks.tasks | Sort-Object dateStarted

    $ignoreResultentry = $true

    Write-Verbose -Verbose  "Obtained $($jobtasks.Count) tasks from task history"
    foreach ($task in $jobtasks)
    {
        Write-Verbose -Verbose "Task $($task.rank) $($task.name) $($task.status)"
        if ($ignoreResultentry -and $task.name -eq "Release")
         {
            Write-Verbose -Verbose "skipping the the release job result"
            $ignoreResultentry = $false
         }
         elseif (!$taskexecutioninfo.ContainsKey($task.rank.ToString()))
         {  
             $newentry = @{}
             $newentry.Add("Id", $($task.rank).ToString())
             $newentry.Add("Name", $($task.name).ToString())
             $newentry.Add("Status", $($task.status).ToString())
             $taskentrystr = ConvertTo-Json $newentry -Compress
             $taskexecutioninfo.Add($task.rank.ToString(), $taskentrystr)
         }
    }
}

$outputvariabletoSet = ConvertTo-Json $taskexecutioninfo -Compress
Write-Verbose -Verbose "obtained task execution history as $outputvariabletoSet"
$env:Release_Tasks = $outputvariabletoSet
Write-Verbose -Verbose "##vso[task.setvariable variable=Release_Tasks;]$outputvariabletoSet"

Write-Verbose -Verbose "Running $rollbackpowershellfile"
if($workingFolder)
{
    if(!(Test-Path $workingFolder -PathType Container))
    {
        throw ("$workingFolder does not exist");
    }
    Write-Verbose "Setting working directory to $workingFolder"
    Set-Location $workingFolder
}

if($type -eq "InlineScript")
{
	Write-Verbose -Verbose "Invoking $script"
    Invoke-Expression $script
}

if($type -eq "FilePath")
{
	if (Test-Path $rollbackpowershellfile)
	{
		$scriptCommand = "& `"$rollbackpowershellfile`" $additionalarguments" 
		Write-Verbose -Verbose "Rollback script execution command = $scriptCommand" 
		Invoke-Expression -Command $scriptCommand
	} 
	else
	{
		Write-Error -Verbose "$rollbackpowershellfile not found"
	}
}

Write-Verbose -Verbose "Exitting script runpowershellwithtaskcontext"