# 2.0 FEATURES

The following describes how the *codemelted* CLI implements the above use cases.

## 2.1 codemelted.ps1 Structure

The `codemelted.ps1` is divided into different sections denoted by the `[SECTION]` separated by `====` dividers. The first section is the `TERMINAL MODULE DEFINITION`. This section contains the `PSScriptInfo` that describes the script on [PowerShell  Gallery](https://www.powershellgallery.com/). It also defines the general script interface, the `--version` flag, and the `--help` system. Lastly it will contain any data definitions common to all use case cmdlets.

The next section are the 14 CodeMelted DEV use case definitions. It is comprised firstly with data definitions to support the implement use case cmdlet. Those definitions then support the `function codemelted_xxx {}` use case cmdlet definitions. The function definition is divided into the `<#.SYNOPSIS ... #>` that defines the help section along with the `param()` which defines the interface to the cmdlet. Any violation of the cmdlet will result in a `SyntaxError: xxx` which will aid in properly using the cmdlet.

The last section is the `MAIN CLI API`. This defines the mapping between the `--use-case` flag to the cmdlet function call. This completes the overall `codemelted --use-case @{}` CLI signature of this module. The [3. USAGE](3-0_usage.md) chapter will cover the usage of each of the use cases.

## 2.2 codemelted --version

```
Name       Version  Author                      Description
----       -------  ------                      -----------
codemelted 25.1.1.0 mark.shaffer@codemelted.com     A CLI to facilitate common developer use cases on Mac / Linux / Windows.
```

## 2.3 codemelted --help

```
NAME
    codemelted_help

SYNOPSIS
    The codemelted Command Line Interface (CLI) Terminal Module. It allows
    a developer to execute the CodeMelted DEV | Module use cases within a
    pwsh terminal shell. This allows for building CLI tools, Terminal User
    Interface (TUI) tools, or building DevOps toolchain automation.

    SYNTAX:
      codemelted [Action] [Params]

    PARAMETERS:
      [Action]
        # To Learn About the CLI use case functions.
        --help : Execute 'codemelted --help @{ action = "use_case" }'
                 to learn about the CLI actions associated with the
                 use case.

                 Execute
                   codemelted --help @{
                     action = "--use_case-function"
                   }
                 to learn about an individual CLI action associated
                 with the given use case listed above.

        --version : Get current information about the codemelted CLI

        --function-name : The identified use case function name to execute.
                          Ex. codemelted --logger-log [Params]

      [Params]
        The optional set of named arguments wrapped within a [hashtable]

    USE CASES:
      async     : IN DEVELOPMENT
      console   : COMPLETED
      db        : TBD
      developer : TBD
      disk      : IN DEVELOPMENT
      hw        : TBD
      json      : COMPLETED
      logger    : COMPLETED
      monitor   : TBD
      network   : IN DEVELOPMENT
      npu       : TBD
      process   : IN DEVELOPMENT
      runtime   : COMPLETED
      setup     : TBD
      storage   : TBD
      ui        : TBD

    RETURNS:
      Will vary depending on the called [Action] representing a use case
      function call. It will be documented with each use case function.

RELATED LINKS
    codemelted.ps1 SDK Docs:
    https://developer.codemelted.com/modules/powershell

    GitHub Source:
    https://github.com/CodeMelted/codemelted_developer
```
