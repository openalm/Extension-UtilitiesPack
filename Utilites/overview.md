# Task Utilities

Release Management utility tasks

1. **Tokenizer**
1. **Powershell++**
1. **Shell++**
1. **Zip & Unzip**
1. **Powershell to rollback**

## Details

### Tokenizer

The task is used to tokenize environment specific configuration:

#### Tokenization based pattern replacement

This task finds the pattern `__<pattern>__` and replaces it with the value from the variable with name `<pattern>`. E.g. If you have a variable defined as `foo` with value `bar`, when running this task on a file that contains `__foo__`, it will be changed to `bar`. The latest version supports replacing secret variables.

#### (Optional) Tokenization based on XML / XPath

If **Configuration Json filename** is provided (optional):
A configuration Json document is provided as an input that contains a section ConfigChanges to provide KeyName the XPath to identify a particular node in the XML document, Attribute name that needs to be set and Value to be set. And this configuration can be maintained for multiple environments.
Below is the sample for the Json document that can be provided as input. There can be multiple sections for each `<release environment name>`. The `<release environment name>` must match the VSTS Release Management Environment, as that is how the task determines which environment section in the Json file to use for the token replacement.

```json
{
    "<release environment name>": {
        "CustomVariables": {
            "Variable1": "value1",
            "Variable2": "value2"
        },
        "ConfigChanges": [{
            "KeyName": "/configuration/appSettings/add[@key='ServiceURL']",
            "Attribute": "value",
            "Value": "https://ServiceURL"
        },
        {
            "KeyName": "/configuration/appSettings/add[@key='EnableDebugging']",
            "Attribute": "value",
            "Value": "false"
        },
        {
            "KeyName": "/configuration/connectionStrings/add[@name='databaseentities']",
            "Attribute": "connectionString",
            "value": "Integrated Security=True;Persist Security Info=False;Initial Catalog=DB;Data Source=servername"
        }]
    }
}
```

If the **Source filename** uses xml namespaces in some nodes, use a generic XPath query in `KeyName`. E.g.

```json
...
"ConfigChanges": [
        {
          "KeyName": "/*[local-name()='configuration']/*[local-name()='connectionStrings']/*[local-name()='add'][@name='serviceUrl']"
          ...
```

Or specify the namespace URL and prefix in the config, e.g.

```json
...
"ConfigChanges": [
    {
        "KeyName": "/configuration/ns:nlog/ns:targets/ns:target[@name='email']",
        "Attribute": "to",
        "value": "logs@test.com",
        "NamespaceUrl": "http://www.nlog-project.org/schemas/NLog.xsd",
        "NamespacePrefix": "ns"
    }
```

#### (Optional) Default variables and config changes

To prevent you from having to define variables and config changes for each environment a special **"default"-environment** can be used in the configuration JSON file. Variables and config changes defined in this special environment will be used in every environment that doesn't explicitly overwrite them.

```json
{
    "default": {
        "CustomVariables": {
            "Variable1": "this value is valid in all environments",
            "ServiceURL": "https://DefaultServiceURL"
        },
        "ConfigChanges": [{
            "KeyName": "/configuration/appSettings/add[@key='ServiceURL']",
            "Attribute": "value",
            "Value": "__ServiceURL__"
        },
        {
            "KeyName": "/configuration/appSettings/add[@key='EnableDebugging']",
            "Attribute": "value",
            "Value": "true"
        }]
    },
    "test": {},
    "prod": {
        "CustomVariables": {
            "ServiceURL": "https://ProdServiceURL"
        },
        "ConfigChanges": [{
            "KeyName": "/configuration/appSettings/add[@key='EnableDebugging']",
            "Attribute": "value",
            "Value": "false"
        }]
    }
}
```

#### Parameters

Below is the list of inputs for the task:

**Source filename*** - Source file name that contains the tokens (`__<variable-name>__`). These patterns will be replaced with user-defined variables or from Configuration Json FileName. If it is an XML document, XPaths mentioned in the Configuration JsonFileName will be set as per environment.

**Destination filename** (optional) - Destination filename that has transformed Source filename. If this is empty, the 'Source filename' will be modified.

**Configuration Json filename** (optional) - Json file that contains environment specific settings in the form XPath, Attribute, Value and values for user-defined variables.
Refer above for the schema/format of the Json filename. If this parameter is not specified, then custom variables mentioned against the build/release are used to replace the tokens that match the regular expression `__<variable-name>__`


### PowerShell++

This task lets you write your powershell script inline in the task textbox itself.

### Shell++

This task lets you write your powershell script inline in the task textbox itself.

### Zip & Unzip

This task lets you create zip files and Unzip archives on a windows agent.

### Rollback

The task is used to enable execution of rollback scripts for the environments. In case of rollback, you would need to know which of the tasks were executed successfully and which of the tasks failed. You would need to undo/fix the changes made to the environment by those tasks only.
Release does not have pre-defined variables that indicate the status of the tasks executed in the job. That makes using an intelligent rollback script difficult. Rollback task facilitates exactly that. You can author a powershell script for reverting/ fixing the changes done to your environment by the deployment.

Ensure that **Run always*** control option is enabled for the rollback task, so that the script can get executed when any of the tasks in the job fail.

 "Release_Tasks" environment variable shall be set by the task to make the execution status of each of the tasks in the deployment job available for the powershell script.
  An example to access the task execution information is as follows.

 ```PowerShell
 try
{
    $jsonobject = ConvertFrom-Json $env:Release_Tasks
}
catch
{
    Write-Verbose -Verbose "Error converting from json"
    Write-Verbose -Verbose $Error
}


foreach ($task in $jsonobject | Get-Member -MemberType NoteProperty) {
    $taskproperty = $jsonobject.$($task.Name) | ConvertFrom-Json
    Write-Verbose -Verbose "Task $($taskproperty.Name) with rank $($task.Name) has status $($taskproperty.Status)"
}

 ```

