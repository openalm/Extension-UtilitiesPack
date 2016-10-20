$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$scriptPath = Join-Path $root "\Utilites\Tokenizer\tokenize-ps3.ps1"

Import-Module (Join-Path $root "\Utilites\Tokenizer\ps_modules\VstsTaskSdk") -ArgumentList @{ NonInteractive = $true }

Describe "Replace token variables" {
    It "replaces multiple variables defined as env variables(configuration variables)"{
        
        $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
        $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
        $fooVal = "I am foo"
        $barVal = "I am bar"
        $secretVal = "I am secret"
        Set-VstsTaskVariable -Name foo -Value $fooVal
        Set-VstsTaskVariable -Name bar -Value $barVal
        Set-VstsTaskVariable -Name secret -Value $secretVal -Secret

        $sourceContent = '__foo__ __bar__ __secret__'
        $expectedDestinationContent = $fooVal + " " + $barVal + " " + $secretVal
                
        try {
            Set-Content -Value $sourceContent -Path $srcPath
            Invoke-VstsTaskScript -ScriptBlock { . $scriptPath } 
            Get-Content -Path $destPath | Should Be $expectedDestinationContent    
        }
        finally {
            Remove-Item -Path $srcPath
            Remove-Item -Path $destPath
        }
    }
}


Describe "Replace token variables" {
    It "replaces variables defined in json"{
        
        $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
        $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
        $env:INPUT_CONFIGURATIONJSONFILE = $jsonConfigPath = Join-Path $env:TEMP 'config.json'
        $env:RELEASE_ENVIRONMENTNAME = 'Test'
        $foo1val = 'I am foo1'
        $bar1val = 'I am bar1'
        $foobarVal = 'FOO - BAR'
        $jsonConfigContent = @{
            Test=@{
                CustomVariables = @{
                    "foo1" = $foo1val
                    "bar1" = $bar1val
                    "foo_bar" = $foobarVal
                }
            }
        } | ConvertTo-Json
        
        $sourceContent = '__foo1__ __bar1__ __foo_bar__ __foo.bar__'
        $expectedDestinationContent = $foo1val + " " + $bar1val + " " + $foobarVal + " " + $foobarVal
                
        try {
            Set-Content -Value $sourceContent -Path $srcPath
            Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
            Invoke-VstsTaskScript -ScriptBlock { . $scriptPath } 
            Get-Content -Path $destPath | Should Be $expectedDestinationContent    
        }
        finally {
            Remove-Item -Path $srcPath
            Remove-Item -Path $destPath
            Remove-Item -Path $jsonConfigPath
        }
    }
}

Describe "Encoding Test" {
    It "replaces multiple variables defined as env variables(configuration variables)"{
        
        $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
        $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
        $fooVal = "的I am foo的"
        $barVal = "的I am bar的"
        $secretVal = "I am secret"
        Set-VstsTaskVariable -Name foo -Value $fooVal
        Set-VstsTaskVariable -Name bar -Value $barVal
        Set-VstsTaskVariable -Name secret -Value $secretVal -Secret

        $sourceContent = '__foo__ __bar__ __secret__'
        $expectedDestinationContent = $fooVal + " " + $barVal + " " + $secretVal
                
        try {
            Set-Content -Value $sourceContent -Path $srcPath -Encoding "UTF8"
            Invoke-VstsTaskScript -ScriptBlock { . $scriptPath } 
            Get-Content -Path $destPath -Encoding "UTF8" | Should Be $expectedDestinationContent    
        }
        finally {
            Remove-Item -Path $srcPath
            Remove-Item -Path $destPath
        }
    }
}