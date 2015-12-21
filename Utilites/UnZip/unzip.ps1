param (
    [string]$pathToZipFile,
    [string]$pathToZipFolder

)

Write-Verbose 'Entering sample.ps1'
Write-Verbose "pathToZipFile = $pathToZipFile"
Write-Verbose "pathToZipFolder = $pathToZipFolder"


# Import the Task.Common dll that has all the cmdlets we need for Build
# import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"
Add-Type -A System.IO.Compression.FileSystem

[IO.Compression.ZipFile]::ExtractToDirectory($pathToZipFile, $pathToZipFolder)
