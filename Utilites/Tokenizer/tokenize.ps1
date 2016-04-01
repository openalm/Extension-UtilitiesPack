﻿[CmdletBinding(DefaultParameterSetName = 'None')]
param
(
    #SourceFile that contains environment specific information which needs to be transformed based on the environment
    [String] [Parameter(Mandatory = $true)][ValidateNotNullorEmpty()] $SourcePath,
    #DestinationFile that will have the transformed $SourcePath, if empty then $SourcePath will be used as $DestinationPath
    [String] [Parameter(Mandatory = $false)] $DestinationPath,
    #ConfigurationJsonFile contains the environment specific configuration values, XPath key value pairs that will be used for XML documents passed as $SourcePath
    [String] [Parameter(Mandatory = $false)] $ConfigurationJsonFile
)

. $PSScriptRoot\Helpers.ps1

function UpdateConfig ($SourcePath, $jsonContent, $envName, $DestinationPath )
{
    if( $envName )
    {
        $keys= $jsonContent.$envName.ConfigChanges
    }
    else
    {
        $keys= $jsonContent.ConfigChanges
    }

    $xmlraw=[xml](Get-Content $SourcePath)
    ForEach($key in $keys){
        "Looking for key: $($key.KeyName)"
        $node=$xmlraw.SelectSingleNode($key.KeyName)
        if($node) {
            "Key found: $($key.KeyName)"
            try{
                "Updating $($key.Attribute) of $($key.KeyName): $($key.Value)" 
                $node.($key.Attribute)=$key.Value
            }
            catch{
            }
        }
    }
    $xmlraw.Save($DestinationPath)
}

function Tokenize($SourcePath, $DestinationPath, $ConfigurationJsonFile)
{
    #ConfigurationJsonFile has multiple environment sections.
    $environmentName="default"
    if (Test-Path -Path env:RELEASE_ENVIRONMENTNAME){
	    $environmentName=(get-item env:RELEASE_ENVIRONMENTNAME).value
    }
    "Environment: $environmentName"
    # Validate that $SourcePath is a valid path
    if (!(Test-Path -Path $SourcePath)){
        throw "$SourcePath is not a valid path. Please provide a valid path"
    }

    # Set $DestinationPath as $SourcePath if it is not passed as input. So, SourceFile gets transformed as DestinationFile
    if($DestinationPath -eq ''){
        $DestinationPath = $SourcePath
    }

    # Is SourceFile an XML document
    $SourceIsXml=Test-ValidXmlFile $SourcePath

    # Is there a valid Configuration Json input provided for modifying configuration
    if($ConfigurationJsonFile -ne ''){
        $Configuration=Get-JsonFromFile $ConfigurationJsonFile
    } 

    <#
        Step 1:- if the SourceIsXml and a valid configuration file is provided then 
            Run through all the XPaths in the Json Configuration and update the XML file
    #>

    if(($SourceIsXml) -and ($Configuration)){
	    "Updating Config using Json config file..."
        #Do non-env specific update first
        UpdateConfig -SourcePath $SourcePath -jsonContent $Configuration -DestinationPath $DestinationPath

        #do Env specific update, this will trump any non-env specific changes
        UpdateConfig -SourcePath $SourcePath -jsonContent $Configuration -envName $environmentName -DestinationPath $DestinationPath

    }

    <#
      Step 2:- For each token in the source configuration that matches with the regular expression __<tokenname>__
                i.	If there is a custom variable at build or release definition then replace the token with the value of the same..
                ii.	If the variable is available in the configuration section of json document then replace the token with the vaule from json document
                iii.Or else it ignores the token
    #>
    $regex = '__[A-Za-z0-9._-]*__'
    $matches = @()
    $tempFile = $DestinationPath + '.tmp'
    Copy-Item -Force $DestinationPath $tempFile

    "Replacing tokens..."
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

    Copy-Item -Force $tempFile $DestinationPath
    Remove-Item -Force $tempFile
    "Done"
}

# Piped output to Out-String first to remove new lines, then pipe that to Write-Verbose to get messages to show up in log.  Write-Host won't show up.
Tokenize -SourcePath $SourcePath -DestinationPath $DestinationPath -ConfigurationJsonFile $ConfigurationJsonFile | Out-String | Write-Verbose -Verbose