
Param(
   [string]$rollbackpowershellfile,
   [string]$additionalarguments
)

Write-Verbose -Verbose "ScriptPath= $rollbackpowershellfile" 
Write-Verbose -Verbose "ScriptArguments= $additionalarguments" 

# Construct the REST URL to obtain Build ID
$releasequeryuri = "$($env:SYSTEM_TEAMFOUNDATIONSERVERURI)/$($env:SYSTEM_TEAMPROJECT)/_apis/release/releases/$($env:Release_ReleaseId)/environments/$($env:RELEASE_ENVIRONMENTURI.Split('/')[-1])/tasks?api-version=2.1-preview.1"
$taskexecutioninfo = @{}
$releasequeryresult = $null
$user = ""

try
{
    Write-Verbose -Verbose "Getting the connection object" 
    $connection = Get-VssConnection -TaskContext $distributedTaskContext 
 
    Write-Verbose -Verbose "Getting Personal Access Token for the Run" 
    $vssEndPoint = Get-ServiceEndPoint -Name "SystemVssConnection" -Context $distributedTaskContext
    $personalAccessToken = $vssEndpoint.Authorization.Parameters.AccessToken

    if (!$personalAccessToken) 
    { 
       throw "Could not extract personal access token. Exitting"     
    } 

    # Base64-encodes the Personal Access Token (PAT) appropriately
    $base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $user,$personalAccessToken)))
    
    # Invoke the REST call and capture the results
    Write-Verbose -Verbose "Calling $releasequeryuri using obtained PAT token"
    $releasequeryresult = Invoke-RestMethod -Uri $releasequeryuri -Method Get -ContentType "application/json" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)}    
}
catch
{
    Write-Verbose -Verbose "Could not obtain release tasks status"
    Write-Verbose -Verbose $Error
    $result = $null
}


if ($releasequeryresult.count -eq 0)
{
    Write-Verbose -Verbose  "Release Query unsuccessful."
}
else
{    
    $jobtasks = $releasequeryresult.value | Sort-Object dateStarted
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
         elseif ( ! $taskexecutioninfo.ContainsKey($task.rank.ToString()))
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
if (Test-Path $rollbackpowershellfile)
{
    Write-Verbose "ScriptArguments= $additionalarguments" 
    Write-Verbose "ScriptPath= $rollbackpowershellfile" 
    $scriptCommand = "& `"$rollbackpowershellfile`" $additionalarguments" 
    Write-Verbose -Verbose "Rollback script execution command = $scriptCommand" 
    Invoke-Expression -Command $scriptCommand 
}

Write-Verbose -Verbose "Exitting script runpowershellwithtaskcontext"