![](https://github.com/openalm/Extension-UtilitiesPack/blob/master/Utilites/images/utilitytasks-logo.png)
# Task Utilities
Release Management utility tasks

This extension has the following tasks: <br>
###Tokenizer
The task is used to tokenize environment specific configuration that is maintained in XML or any other text documents. This task allows translating XML documents with environment specific values by setting values based on XPath and/or replace the tokens that match the regular expression __<variable>__
#### Tokenization based on XML / XPath
A configuration Json document is provided as an input that contains a section ConfigChanges to provide KeyName the XPath to identify a particular node in the XML document, Attribute name that needs to be set and Value to be set. And this configuration can be maintained for multiple environments.
Below is the sample for the Json document that can be provided as input. There can be multiple sections for each <environment>
```
{
  "<environment>": {
    "CustomVariables": {
    "Variable1": "value1",
    "Variable2": "value2",
  },
    "ConfigChanges": [
        {
          "KeyName": "/configuration/appSettings/add[@key='ServiceURL']",
          "Attribute":"value",
          "Value":"https://ServiceURL"
        },
        {
          "KeyName": "/configuration/appSettings/add[@key='EnableDebugging']",
          "Attribute":"value",
          "Value":"false"
        },
        {
          "KeyName":“/configuration/connectionStrings/add[@name='databaseentities']”,
          "Attribute": "connectionString",
          "value": "Integrated Security=True;Persist Security Info=False;Initial Catalog=DB;Data Source=servername"
        }
    ]
}
```
Below is the list of inputs for the task: <br>
**Source filename*** - Source file name that contains the tokens (\_\_<variable-name>\_\_). These patterns will be replaced with user-defined variables or from Configuration Json FileName. If it is an XML document, XPaths mentioned in the Configuration JsonFileName will be set as per environment. <br>
**Destination filename** (optional) - Destination filename that has transformed Source filename. If this is empty, the 'Source filename' will be modified. <br>
**Configuration Json filename** (optional) - Json file that contains environment specific settings in the form XPath, Attribute, Value and values for user-defined variables. <br>
Refer above for the schema/format of the Json filename. If this parameter is not specified, then custom variables mentioned against the build/release are used to replace the tokens that match the regular expression \_\_<variable-name>\_\_
<br>
#### Tokenization based pattern replacement
In the absence of **Configuration Json filename**, this task finds the pattern:  **\_\_\<pattern\>\_\_** and replaces the same with the value from the variable with name **\<pattern\>**. Eg. If you have a vriable defined as **foo** with value **bar**, on running this task on a file that contains **\_\_foo\_\_** will be changed to **bar**. <br><br>
###PowerShell++
This task lets you write your powershell script inline in the task textbox itself.  
###Shell++
This task lets you write your powershell script inline in the task textbox itself.  
###Zip & Unzip

<br>
