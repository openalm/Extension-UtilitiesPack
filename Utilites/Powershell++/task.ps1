param (
[string] $type,
[string] $scriptName,
[string] $arguments,
[string] $workingFolder,
[string] $script
)

Write-Verbose 'Entering task.ps1'
Write-Verbose 'Current Working Directory is $cwd'
Write-Verbose "Your script is \n $script"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if($workingFolder)
{
    if(!(Test-Path $workingFolder -PathType Container))
    {
        throw ("$workingFolder does not exist");
    }
    Write-Verbose "Setting working directory to $workingFolder"
    Set-Location $workingFolder
}

if($type -eq "FilePath"){
    Invoke-Expression "& `"$scriptName`" $arguments"
}
if($type -eq "InlineScript"){
    Invoke-Expression $script
}






