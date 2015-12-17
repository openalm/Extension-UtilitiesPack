param (
    [string]$cwd,
    [string]$script
)

Write-Verbose 'Entering sample.ps1'
Write-Verbose 'Current Working Directory is $cwd'
Write-Verbose "Your script is \n $script"

# Import the Task.Common dll that has all the cmdlets we need for Build
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

if(!$cwd)
{
    throw (Get-LocalizedString -Key "Working directory parameter is not set")
}

if(!(Test-Path $cwd -PathType Container))
{
    throw ("$cwd does not exist");
}

Write-Verbose "Setting working directory to $cwd"
Set-Location $cwd

Invoke-Expression $script