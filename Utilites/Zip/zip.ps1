param (
    [string]$pathToZipFolder,
    [string]$pathToZipFile,
    [string]$overwrite
)

Write-Verbose 'Entering sample.ps1'
Write-Verbose "pathToZipFolder = $pathToZipFolder"
Write-Verbose "pathToZipFile = $pathToZipFile"
Write-Verbose "overwrite = $overwrite"

Add-Type -A System.IO.Compression.FileSystem

# This is a hack since the agent passes this as a string.
if($overwrite -eq "true"){
    $overwrite = $true
}else{
    $overwrite = $false
}

if ($overwrite -and (Test-Path $pathToZipFile)){
    Write-Verbose "Removing the old file"
    Remove-Item $pathToZipFile
}

[IO.Compression.ZipFile]::CreateFromDirectory($pathToZipFolder, $pathToZipFile)