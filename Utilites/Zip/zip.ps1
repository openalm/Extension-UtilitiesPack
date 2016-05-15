param (
    [string]$pathToZipFolder,
    [string]$pathToZipFile,
    [Boolean]$overwrite
)

Write-Verbose 'Entering sample.ps1'
Write-Verbose "pathToZipFolder = $pathToZipFolder"
Write-Verbose "pathToZipFile = $pathToZipFile"
Write-Verbose "overwrite = $overwrite"
# Import the Task.Common dll that has all the cmdlets we need for Build
# import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"
Add-Type -A System.IO.Compression.FileSystem

if ($overwrite -and (Test-Path $pathToZipFile)){
    Write-Verbose "Removing the old file"
    Remove-Item $pathToZipFile
}

[IO.Compression.ZipFile]::CreateFromDirectory($pathToZipFolder, $pathToZipFile)