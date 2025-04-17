# 2.0 FEATURES

The following describes how the *codemelted* CLI implements the above use cases.

## 2.1 codemelted.ps1 Structure

The `codemelted.ps1` is divided into different sections denoted by the `[SECTION]` separated by `====` dividers. The first section is the `TERMINAL MODULE DEFINITION`. This section contains the `PSScriptInfo` that describes the script on [PowerShell  Gallery](https://www.powershellgallery.com/). It also defines the general script interface, the `--version` flag, and the `--help` system. Lastly it will contain any data definitions common to all use case cmdlets.

The next section are the 14 CodeMelted DEV use case definitions. It is comprised firstly with data definitions to support the implement use case cmdlet. Those definitions then support the `function codemelted_xxx {}` use case cmdlet definitions. The function definition is divided into the `<#.SYNOPSIS ... #>` that defines the help section along with the `param()` which defines the interface to the cmdlet. Any violation of the cmdlet will result in a `SyntaxError: xxx` which will aid in properly using the cmdlet.

The last section is the `MAIN CLI API`. This defines the mapping between the `--use-case` flag to the cmdlet function call. This completes the overall `codemelted --use-case @{}` CLI signature of this module. The [3. USAGE](3-0_usage.md) chapter will cover the usage of each of the use cases.

## 2.2 codemelted --version

```
Name       Version Author                      Description
----       ------- ------                      -----------
codemelted 0.8.0.0 mark.shaffer@codemelted.com   A CLI to facilitate common developer use cases on Mac / Linux / Windows OS.
```

*NOTE: Current version is frozen and usable. But it will be going through a refactor. Stay Tuned*

## 2.3 codemelted --help

<mark>TBD</mark>

*NOTE: Current version is frozen and usable. But it will be going through a refactor. Stay Tuned*
