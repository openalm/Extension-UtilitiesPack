[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    [String] [Parameter(Mandatory = $true)] $SourcePath,
    [String] [Parameter(Mandatory = $false)] $DestinationPath
)

if($DestinationPath -eq '')
{
    $DestinationPath = $SourcePath
}

$patterns = @()
$regex = ‘__[A-Za-z0-9.]*__'
$matches = @()
$tempFile = $SourcePath + '.tmp'

Copy-Item -Force $SourcePath $tempFile

$matches = select-string -Path $tempFile -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value }
ForEach($match in $matches)
{
  $matchedItem = $match
  $matchedItem = $matchedItem.Trim('_')
  $matchedItem = $matchedItem -replace '\.','_'
  (Get-Content $tempFile) | 
  Foreach-Object {
  $_ -replace $match,(get-item env:$matchedItem).Value
  } | 
Set-Content $tempFile -Force
}

Copy-Item -Force $tempFile $DestinationPath
Remove-Item -Force $tempFile