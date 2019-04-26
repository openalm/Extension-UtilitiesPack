$root = Split-Path -Parent $MyInvocation.MyCommand.Path | Split-Path | Split-Path
$scriptPath = Join-Path $root "\Utilites\Tokenizer\tokenize-ps3.ps1"

Import-Module (Join-Path $root "\Utilites\Tokenizer\ps_modules\VstsTaskSdk") -ArgumentList @{ NonInteractive = $true } -Force

Describe "Replace token variables" {
    It "replaces multiple variables defined as env variables(configuration variables)"{
        
        $env:BUILD_SOURCESDIRECTORY = $fullDir = $env:TEMP
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

# Describe "Replace token variables" {
#     It "replaces variables defined in json"{
        
#         $env:BUILD_SOURCESDIRECTORY = $fullDir = $env:TEMP
#         $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
#         $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
#         $env:INPUT_CONFIGURATIONJSONFILE = $jsonConfigPath = Join-Path $env:TEMP 'config.json'
#         $env:RELEASE_ENVIRONMENTNAME = 'Test'
#         $foo1val = 'I am foo1'
#         $bar1val = 'I am bar1'
#         $foobarVal = 'FOO - BAR'
#         $jsonConfigContent = @{
#             Test=@{
#                 CustomVariables = @{
#                     "foo1" = $foo1val
#                     "bar1" = $bar1val
#                     "foo_bar" = $foobarVal
#                 }
#             }
#         } | ConvertTo-Json
        
#         $sourceContent = '__foo1__ __bar1__ __foo_bar__ __foo.bar__'
#         $expectedDestinationContent = $foo1val + " " + $bar1val + " " + $foobarVal + " " + $foobarVal
                
#         try {
#             Set-Content -Value $sourceContent -Path $srcPath
#             Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
#             Invoke-VstsTaskScript -ScriptBlock { . $scriptPath } 
#             Get-Content -Path $destPath | Should Be $expectedDestinationContent    
#         }
#         finally {
#             Remove-Item -Path $srcPath
#             Remove-Item -Path $destPath
#             Remove-Item -Path $jsonConfigPath
#         }
#     }
# }
    
# Describe "Replace token variables" {
#     It "uses or replaces default variables defined in json"{
        
#         $env:BUILD_SOURCESDIRECTORY = $fullDir = $env:TEMP
#         $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
#         $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
#         $env:INPUT_CONFIGURATIONJSONFILE = $jsonConfigPath = Join-Path $env:TEMP 'config.json'
#         $env:RELEASE_ENVIRONMENTNAME = 'Test'
#         $fooDefaultVal = 'foo-default'
#         $barTestVal = 'bar-test'
#         $barProdVal = 'bar-prod'
#         $foobarDefaultVal = 'foobar-default'
#         $foobarTestVal = 'foobar-test'
#         $foobarProdVal = 'foobar-prod'
#         $jsonConfigContent = @{
#             default=@{
#                 CustomVariables = @{
#                     "foo2" = $fooDefaultVal
#                     "foo_bar2" = $foobarDefaultVal
#                 }
#             }
#             Test=@{
#                 CustomVariables = @{
#                     "bar2" = $barTestVal
#                     "foo_bar2" = $foobarTestVal
#                 }
#             }
#             Prod=@{
#                 CustomVariables = @{
#                     "bar2" = $barProdVal
#                     "foo_bar2" = $foobarProdVal
#                 }
#             }
#         } | ConvertTo-Json
        
#         $sourceContent = '__foo2__ __bar2__ __foo_bar2__ __foo.bar2__'
#         $expectedDestinationContent = $fooDefaultVal + " " + $barTestVal + " " + $foobarTestVal + " " + $foobarTestVal
        
#         try {
#             Set-Content -Value $sourceContent -Path $srcPath
#             Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
#             Invoke-VstsTaskScript -ScriptBlock { . $scriptPath }
#             Get-Content -Path $destPath | Should Be $expectedDestinationContent
#         }
#         finally {
#             Remove-Item -Path $srcPath
#             Remove-Item -Path $destPath
#             Remove-Item -Path $jsonConfigPath
#         }
#     }
# }

# Describe "Replace token variables" {
#     It "uses or replaces default config changes defined in json"{
        
#         $env:BUILD_SOURCESDIRECTORY = $fullDir = $env:TEMP
#         $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.xml'
#         $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.xml'
#         $env:INPUT_CONFIGURATIONJSONFILE = $jsonConfigPath = Join-Path $env:TEMP 'config.json'
#         $env:RELEASE_ENVIRONMENTNAME = 'Test'
#         $fooDefaultVal = 'foo-default'
#         $barTestVal = 'bar-test'
#         $foobarDefaultVal = 'foobar-default'
#         $foobarTestVal = 'foobar-test'
#         $configContent = @{
#             default=@{
#                 ConfigChanges = @()
#             }
#             Test=@{
#                 ConfigChanges = @()
#             }
#             Prod=@{
#                 ConfigChanges = @()
#             }
#         }
#         $configContent.default.ConfigChanges += @{
#             "KeyName" = "/root/element"
#             "Attribute" = "attribute1"
#             "Value" = $fooDefaultVal
#         }
#         $configContent.default.ConfigChanges += @{
#             "KeyName" = "/root/element"
#             "Attribute" = "attribute3"
#             "Value" = $foobarDefaultVal
#         }
#         $configContent.Test.ConfigChanges += @{
#             "KeyName" = "/root/element"
#             "Attribute" = "attribute3"
#             "Value" = $foobarTestVal
#         }
#         $configContent.Test.ConfigChanges += @{
#             "KeyName" = "/root/element"
#             "Attribute" = "attribute2"
#             "Value" = $barTestVal
#         }
        
#         $jsonConfigContent = $configContent | ConvertTo-Json -Depth 3
#         $sourceContent = '<?xml version="1.0" encoding="utf-8"?><root><element attribute1="value1" attribute2="bar-test" attribute3="foobar-test" /></root>'
#         $expectedDestinationContent = "<?xml version=`"1.0`" encoding=`"utf-8`"?>`r`n<root>`r`n  <element attribute1=`"" + $fooDefaultVal + "`" attribute2=`"" + $barTestVal + "`" attribute3=`"" + $foobarTestVal + "`" />`r`n</root>`r`n"
        
#         try {
#             Set-Content -Value $sourceContent -Path $srcPath
#             Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
#             Invoke-VstsTaskScript -ScriptBlock { . $scriptPath }
#             Get-Content -Path $destPath | Out-String | Should Be $expectedDestinationContent
#         }
#         finally {
#             Remove-Item -Path $srcPath
#             Remove-Item -Path $destPath
#             Remove-Item -Path $jsonConfigPath
#         }
#     }
# }

# Describe "Replace token variables" {
# 	It "does not escape special characters in text files"{
        
#         $env:BUILD_SOURCESDIRECTORY = $fullDir = $env:TEMP
#         $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
#         $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
#         $env:INPUT_CONFIGURATIONJSONFILE = $jsonConfigPath = Join-Path $env:TEMP 'config.json'
#         $env:RELEASE_ENVIRONMENTNAME = 'Test'
#         $foo1val = 'I am foo1'
#         $bar1val = 'I am bar1'
#         $foobarVal = 'FOO - & BAR'
#         $jsonConfigContent = @{
#             Test=@{
#                 CustomVariables = @{
#                     "foo1" = $foo1val
#                     "bar1" = $bar1val
#                     "foo_bar" = $foobarVal
#                 }
#             }
#         } | ConvertTo-Json
        
#         $sourceContent = '__foo1__ __bar1__ __foo_bar__ __foo.bar__'
#         $expectedDestinationContent = $foo1val + " " + $bar1val + " " + $foobarVal + " " + $foobarVal
                
#         try {
#             Set-Content -Value $sourceContent -Path $srcPath
#             Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
#             Invoke-VstsTaskScript -ScriptBlock { . $scriptPath } 
#             Get-Content -Path $destPath | Should Be $expectedDestinationContent    
#         }
#         finally {
#             Remove-Item -Path $srcPath
#             Remove-Item -Path $destPath
#             Remove-Item -Path $jsonConfigPath
#         }
#     }
# }

Describe "XML updates based on json configuration" {
    $sourcesDir = "tokenizer-test"
    $fullDir = Join-Path -Path (Get-Location) -ChildPath $sourcesDir
    $srcPath = Join-Path $fullDir 'source.xml'
    $destPath = Join-Path $fullDir 'dest.xml'
    $jsonConfigPath = Join-Path $fullDir 'config.json'

    BeforeEach {
        $env:BUILD_SOURCESDIRECTORY = $fullDir
        $env:INPUT_SOURCEPATH = $srcPath
        $env:INPUT_DESTINATIONPATH = $destPath
        $env:INPUT_CONFIGURATIONJSONFILE = $jsonConfigPath
        $env:RELEASE_ENVIRONMENTNAME = 'Test'

        New-Item -Path . -Name "tokenizer-test" -ItemType "directory"
    }

    AfterEach {
        if (Test-Path -Path $sourcesDir) {
            Remove-Item -Path $sourcesDir -Recurse
        }
    }

	It "replaces attribute value based on configuration" {
        $sourceContent = '<?xml version="1.0" encoding="utf-8"?><configuration><foo key="testExample" bar="value to replace" /></configuration>'
        $jsonConfigContent =
'{
    "Test": {
    "ConfigChanges":  [{
            "value":  "I am replaced",
            "Attribute":  "bar",
            "KeyName":  "/configuration/foo[@key=''testExample'']"
        }]
    }
}'
        $expectedDestinationContent = '<?xml version="1.0" encoding="utf-8"?><configuration><foo key="testExample" bar="I am replaced" /></configuration>'
        		
        #cycling the expected through a write and read to normalize expected spacing
        $tempPath = Join-Path $fullDir 'temp.xml'
        Set-Content -Value $expectedDestinationContent -Path $tempPath
        $expectedDestinationContent = [xml](Get-Content -Path $tempPath)
    
        Set-Content -Value $sourceContent -Path $srcPath
        Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
        Invoke-VstsTaskScript -ScriptBlock { . $scriptPath }

        Test-Path -Path $destPath | Should Be True
        ([xml](Get-Content -Path $destPath)).OuterXML | Should Be $expectedDestinationContent.OuterXML
    }

	It "escapes special characters" {
        $sourceContent = '<?xml version="1.0" encoding="utf-8"?><configuration><foo key="testExample" bar="value to replace" /></configuration>'
        $jsonConfigContent =
'{
    "Test": {
    "ConfigChanges":  [{
            "value":  "I am replaced & \"happy\"",
            "Attribute":  "bar",
            "KeyName":  "/configuration/foo[@key=''testExample'']"
        }]
    }
}'
        $expectedDestinationContent = '<?xml version="1.0" encoding="utf-8"?><configuration><foo key="testExample" bar="I am replaced &amp; &quot;happy&quot;" /></configuration>'
        		
        #cycling the expected through a write and read to normalize expected spacing
        $tempPath = Join-Path $fullDir 'temp.xml'
        Set-Content -Value $expectedDestinationContent -Path $tempPath
        $expectedDestinationContent = [xml](Get-Content -Path $tempPath)
    
        Set-Content -Value $sourceContent -Path $srcPath
        Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
        Invoke-VstsTaskScript -ScriptBlock { . $scriptPath }

        Test-Path -Path $destPath | Should Be True
        ([xml](Get-Content -Path $destPath)).OuterXML | Should Be $expectedDestinationContent.OuterXML
    }

	It "adds missing attribute" {
        $sourceContent = '<?xml version="1.0" encoding="utf-8"?><configuration><foo key="testExample" /></configuration>'
        $jsonConfigContent =
'{
    "Test": {
    "ConfigChanges":  [{
            "value":  "I am replaced",
            "Attribute":  "bar",
            "KeyName":  "/configuration/foo[@key=''testExample'']"
        }]
    }
}'
        $expectedDestinationContent = '<?xml version="1.0" encoding="utf-8"?><configuration><foo key="testExample" bar="I am replaced" /></configuration>'
        		
        #cycling the expected through a write and read to normalize expected spacing
        $tempPath = Join-Path $fullDir 'temp.xml'
        Set-Content -Value $expectedDestinationContent -Path $tempPath
        $expectedDestinationContent = [xml](Get-Content -Path $tempPath)
    
        Set-Content -Value $sourceContent -Path $srcPath
        Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
        Invoke-VstsTaskScript -ScriptBlock { . $scriptPath }

        Test-Path -Path $destPath | Should Be True
        ([xml](Get-Content -Path $destPath)).OuterXML | Should Be $expectedDestinationContent.OuterXML
    }

	It "includes one namespace" {
        $sourceContent = '<?xml version="1.0" encoding="utf-8"?><configuration xmlns:a="http://namespace"><a:foo key="testExample" bar="value to replace" /></configuration>'
        $jsonConfigContent =
'{
    "Test": {
    "ConfigChanges":  [{
            "value":  "I am replaced",
            "Attribute":  "bar",
            "KeyName":  "/configuration/a:foo[@key=''testExample'']",
            "NamespacePrefix": "a",
            "NamespaceUrl": "http://namespace"
        }]
    }
}'
        $expectedDestinationContent = '<?xml version="1.0" encoding="utf-8"?><configuration xmlns:a="http://namespace"><a:foo key="testExample" bar="I am replaced" /></configuration>'
        		
        #cycling the expected through a write and read to normalize expected spacing
        $tempPath = Join-Path $fullDir 'temp.xml'
        Set-Content -Value $expectedDestinationContent -Path $tempPath
        $expectedDestinationContent = [xml](Get-Content -Path $tempPath)
    
        Set-Content -Value $sourceContent -Path $srcPath
        Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
        Invoke-VstsTaskScript -ScriptBlock { . $scriptPath }

        Test-Path -Path $destPath | Should Be True
        ([xml](Get-Content -Path $destPath)).OuterXML | Should Be $expectedDestinationContent.OuterXML
    }

    It "finds all nodes matching the XPath" {
        $sourceContent = '<?xml version="1.0" encoding="utf-8"?><configuration><foo1 key="test" bar="value to replace" /><foo2 key="nomatch" bar="not replaced" /><foo3 key="test" bar="value to replace"><child /></foo3></configuration>'
        $jsonConfigContent =
'{
    "Test": {
    "ConfigChanges":  [{
            "value":  "I am replaced",
            "Attribute":  "bar",
            "KeyName":  "/configuration/*[@key=''test'']"
        }]
    }
}'
        $expectedDestinationContent = '<?xml version="1.0" encoding="utf-8"?><configuration><foo1 key="test" bar="I am replaced" /><foo2 key="nomatch" bar="not replaced" /><foo3 key="test" bar="I am replaced"><child /></foo3></configuration>'
        		
        #cycling the expected through a write and read to normalize expected spacing
        $tempPath = Join-Path $fullDir 'temp.xml'
        Set-Content -Value $expectedDestinationContent -Path $tempPath
        $expectedDestinationContent = [xml](Get-Content -Path $tempPath)
    
        Set-Content -Value $sourceContent -Path $srcPath
        Set-Content -Value $jsonConfigContent -Path $jsonConfigPath
        Invoke-VstsTaskScript -ScriptBlock { . $scriptPath }

        Test-Path -Path $destPath | Should Be True
        ([xml](Get-Content -Path $destPath)).OuterXML | Should Be $expectedDestinationContent.OuterXML
    }
}

Describe "Encoding Test" {
    It "replaces multiple variables defined as env variables(configuration variables)"{
        
        $env:BUILD_SOURCESDIRECTORY = $fullDir = $env:TEMP
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

Describe "Not set variables should not get replaced" {
    It "replaces multiple variables defined as env variables(configuration variables)"{
        
        $env:BUILD_SOURCESDIRECTORY = $fullDir = $env:TEMP
        $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
        $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
        $env:INPUT_REPLACEUNDEFINEDVALUESWITHEMPTY = $false
        $fooVal = "的I am foo的"
        $barVal = "的I am bar的"
        $secretVal = "I am secret"
        Set-VstsTaskVariable -Name foo -Value $fooVal
        Set-VstsTaskVariable -Name bar -Value $barVal
        Set-VstsTaskVariable -Name secret -Value $secretVal -Secret

        $sourceContent = '__foo__ __bar__ __secret__ __iamnotset__'
        $expectedDestinationContent = $fooVal + " " + $barVal + " " + $secretVal + " __iamnotset__"
                
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

Describe "Not set variables should get replaced" {
    It "replaces multiple variables defined as env variables(configuration variables)"{
        
        $env:BUILD_SOURCESDIRECTORY = $fullDir = $env:TEMP
        $env:INPUT_SOURCEPATH = $srcPath = Join-Path $env:TEMP 'source.txt'
        $env:INPUT_DESTINATIONPATH = $destPath = Join-Path $env:TEMP 'dest.txt'
        $env:INPUT_REPLACEUNDEFINEDVALUESWITHEMPTY = $true
        $fooVal = "的I am foo的"
        $barVal = "的I am bar的"
        $secretVal = "I am secret"
        Set-VstsTaskVariable -Name foo -Value $fooVal
        Set-VstsTaskVariable -Name bar -Value $barVal
        Set-VstsTaskVariable -Name secret -Value $secretVal -Secret

        $sourceContent = '__foo__ __bar__ __secret__ __iamnotset__'
        $expectedDestinationContent = $fooVal + " " + $barVal + " " + $secretVal + " "
                
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

Describe "Glob Matches" {
    $sourcesDir = "tokenizer-test"
    $fullDir = Join-Path -Path (Get-Location) -ChildPath $sourcesDir
    $sourceContent = '__foo__ __bar__ __secret__'
    $srcPath1 = Join-Path $fullDir 'source1match.txt'
    $srcPath2 = Join-Path $fullDir 'source2match.txt'
    $srcPath3 = Join-Path $fullDir 'source3.txt'
    $destPath = Join-Path $fullDir 'dest.txt'
    
    BeforeEach {
        New-Item -Path . -Name "tokenizer-test" -ItemType "directory"
        Set-Content -Value $sourceContent -Path $srcPath1
        Set-Content -Value $sourceContent -Path $srcPath2
        Set-Content -Value $sourceContent -Path $srcPath3
    }

    AfterEach {
        if (Test-Path -Path $sourcesDir) {
            Remove-Item -Path $sourcesDir -Recurse
        }
    }

    It "replaces variables on multiple files" {
        $env:BUILD_SOURCESDIRECTORY = $fullDir
        $env:INPUT_SOURCEPATH = "**/*match.txt"
        $env:INPUT_DESTINATIONPATH = $destPath
        $fooVal = "I am foo"
        $barVal = "I am bar"
        $secretVal = "I am secret"
        Set-VstsTaskVariable -Name foo -Value $fooVal
        Set-VstsTaskVariable -Name bar -Value $barVal
        Set-VstsTaskVariable -Name secret -Value $secretVal -Secret

        Invoke-VstsTaskScript -ScriptBlock { . $scriptPath }

        $expectedDestinationContent = $fooVal + " " + $barVal + " " + $secretVal
        Get-Content -Path $srcPath1 | Should Be $expectedDestinationContent
        Get-Content -Path $srcPath2 | Should Be $expectedDestinationContent
        Get-Content -Path $srcPath3 | Should Be $sourceContent
        Test-Path -Path $destPath | Should Be False
    }
}