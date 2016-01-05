[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    #SourceFile that contains environment specific information which needs to be transformed based on the environment
    [String] [Parameter(Mandatory = $true)][ValidateNotNullorEmpty()] $SourceFile,
    #DestinationFile that will have the transformed $SourceFile, if empty then $SourceFile will be used as $DestinationFile
    [String] [Parameter(Mandatory = $false)] $DestinationFile,
    #ConfigurationJsonFile contains the environment specific configuration values, XPath key value pairs that will be used for XML documents passed as $SourceFile
    [String] [Parameter(Mandatory = $false)] $ConfigurationJsonFile,
    #ConfigurationJsonFile has multiple environment sections.
    [String] [Parameter(Mandatory = $false)] $CurrentEnvironment
)

. $PSScriptRoot\Helpers.ps1

if($CurrentEnvironment -eq ''){
    $environmentName="default"
}
else{
    $environmentName=$CurrentEnvironment
}

# Validate that $SourceFile is a valid path
if (!(Test-Path -Path $SourceFile)){
    throw "$SourceFile is not a valid path. Please provide a valid path"
}

# Set $DestinationFile as $SourceFile if it is not passed as input. So, SourceFile gets transformed as DestinationFile
if($DestinationFile -eq ''){
    $DestinationFile = $SourceFile
}

# Is SourceFile an XML document
$SourceIsXml=Test-ValidXmlFile $SourceFile
# Is there a valid Configuration Json input provided for modifying configuration
$Configuration=Get-JsonFromFile $ConfigurationJsonFile
<#
    Step 1:- if the SourceIsXml and a valid configuration file is provided then 
        Run through all the XPaths in the Json Configuration and update the XML file
#>

if(($SourceIsXml) -and ($Configuration)){
    $keys= $Configuration.$environmentName.ConfigChanges

    $xmlraw=[xml](Get-Content $SourceFile)
    ForEach($key in $keys){
        $node=$xmlraw.SelectSingleNode($key.KeyName)
        if($node) {
            try{
                Write-Host "Updating " $key.Attribute "of " $key.KeyName ":" $key.Value 
                $node.($key.Attribute)=$key.Value
                }
            catch{
            }
        }
    }
    $xmlraw.Save($DestinationFile)


}
<#
  Step 2:- For each token in the source configuration that matches with the regular expression __<tokenname>__
            i.	If there is a custom variable at build or release definition then replace the token with the value of the same..
            ii.	If the variable is available in the configuration section of json document then replace the token with the vaule from json document
            iii.Or else it ignores the token
#>
$patterns = @()
$regex = ‘__[A-Za-z0-9._-]*__'
$matches = @()
$tempFile = $DestinationFile + '.tmp'
Copy-Item -Force $DestinationFile $tempFile

$matches = select-string -Path $tempFile -Pattern $regex -AllMatches | % { $_.Matches } | % { $_.Value }
ForEach($match in $matches)
{
  $matchedItem = $match
  $matchedItem = $matchedItem.Trim('_')
  $matchedItem = $matchedItem -replace '\.','_'
  (Get-Content $tempFile) | 
  Foreach-Object {
    $variableValue=$match
    try{
        if(Test-Path env:$matchedItem){
            $variableValue=(get-item env:$matchedItem).Value
            }
        else{
            if($Configuration.$environmentName.CustomVariables.$matchedItem){
                $variableValue=$Configuration.$environmentName.CustomVariables.$matchedItem
            }
        }
        }
    catch{
        $variableValue=$match
    }
    $_ -replace $match,$variableValue
  } | 
Set-Content $tempFile -Force
}

Copy-Item -Force $tempFile $DestinationFile
Remove-Item -Force $tempFile