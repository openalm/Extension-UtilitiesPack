function Test-ValidXmlFile {
param (
[parameter(mandatory=$true)][ValidateNotNullorEmpty()][string]$xmlFilePath
)

# Does file exist?
if ((Test-Path -Path $xmlFilePath)){
    # Check for Load or Parse errors when loading the XML file
    $xml = New-Object System.Xml.XmlDocument
    try {
        $xml.Load((Get-ChildItem -Path $xmlFilePath).FullName)
        return $true
    }
    catch [System.Xml.XmlException] {
    Write-Verbose "$xmlFilePath : $($_.toString())"
    return $false
    }
}
else{
    return $false
}

}


function Get-JsonFromFile {
param (
[parameter(mandatory=$true)][ValidateNotNullorEmpty()][string]$jsonFilePath
)
# Does file exist?
if ((Test-Path -Path $jsonFilePath)){
    try {
        $outObject = (Get-Content $jsonFilePath) -join "`n" | ConvertFrom-Json
        return $outObject
    }
    catch {
        Write-Host "Error parsing configuration file. Exception message: "
        Write-Host $_.Exception | Format-List
        return
    }
}
else {
    Write-Host "Configuration file '$jsonFilePath' not found."
    return
}

}
