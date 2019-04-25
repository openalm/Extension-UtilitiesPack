function Test-ValidXmlFile {
param (
[parameter(mandatory=$true)][ValidateNotNullorEmpty()][string]$xmlFilePath
)

# Does file exist?
if ((Test-Path -Path $xmlFilePath)){
    # Check for Load or Parse errors when loading the XML file
    $xml = New-Object System.Xml.XmlDocument
    try {
        $xml.Load($xmlFilePath)
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
        $encoding = Get-FileEncoding $jsonFilePath
        $outObject = (Get-Content $jsonFilePath -Encoding $encoding) -join "`n" | ConvertFrom-Json
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

function ArrayToHash($a)
{
    $hash = @{}
    $a | foreach { $hash[$_.Name] = $_ }
    return $hash
}

function Get-FileEncoding {
    param ( [string] $FilePath )

    [byte[]] $byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $FilePath

    if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
        { $encoding = 'UTF8' }  
    elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
        { $encoding = 'BigEndianUnicode' }
    elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
         { $encoding = 'Unicode' }
    elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
        { $encoding = 'UTF32' }
    elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76)
        { $encoding = 'UTF7'}
    else
        { $encoding = 'ASCII' }
    return $encoding
}
