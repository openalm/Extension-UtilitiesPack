$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$scriptPath = Join-Path $root "\Utilites\Tokenizer\tokenize-ps3.ps1"

Import-Module "..\..\Utilites\Tokenizer\ps_modules\VstsTaskSdk" -ArgumentList @{ NonInteractive = $true }

Describe "Replace task variables" {
    It "replaces multiple variables"{
        
        $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
        $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
        $env:foo = 'I am foo'
        $env:bar = 'I am bar'
        $sourceContent = '__foo__ __bar__'
        $expectedDestinationContent = $env:foo + " " + $env:bar
                
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
