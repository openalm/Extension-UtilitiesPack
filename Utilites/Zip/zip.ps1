param (
    [string]$pathToZipFolder,
    [string]$pathToZipFile
)

Write-Verbose 'Entering sample.ps1'
Write-Verbose "pathToZipFolder = $pathToZipFolder"
Write-Verbose "pathToZipFile = $pathToZipFile"

# Import the Task.Common dll that has all the cmdlets we need for Build
# import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"
Add-Type -A System.IO.Compression.FileSystem
[IO.Compression.ZipFile]::CreateFromDirectory($pathToZipFolder, $pathToZipFile)