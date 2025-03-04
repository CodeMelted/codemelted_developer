<!--
TITLE: CodeMelted DEV | pwsh Module
PUBLISH_DATE: 2025-03-03
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: The `codemelted.ps1` script will provide a Command Line Interface (CLI) to facilitate common developer use cases on Mac, Linux, or Windows systems. When installed, the CLI will provide the `codemelted` command that can be accessed in a pwsh terminal or in `ps1` scripts that facilitate a set of automated tasks. A developer may also build a Terminal User Interface (TUI) for a text based user interface. Lastly it will facilitate in developing applications utilizing the *CodeMelted DEV | Modules*.
-->
<center>
  <a title="Back To Developer Main" href="../../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-codemelted-pwsh.png" /> CodeMelted DEV | pwsh Module</h1>

The `codemelted.ps1` script will provide a Command Line Interface (CLI) to facilitate common developer use cases on Mac, Linux, or Windows systems. When installed, the CLI will provide the `codemelted` command that can be accessed in a pwsh terminal or in `ps1` scripts that facilitate a set of automated tasks. A developer may also build a Terminal User Interface (TUI) for a text based user interface. Lastly it will facilitate in developing applications utilizing the *CodeMelted DEV | Modules*.

**LAST UPDATED:** 2025-03-03

<center>
  <br />
  <a href="https://www.buymeacoffee.com/codemelted" target="_blank">
    <img height="50px" src="https://codemelted.com/assets/images/icon-bmc-button.png" />
  </a>
  <br /><br />
  <p>Hope you enjoy the content. Any support is greatly appreciated. Thank you! 🙇</p>
</center>

**Table of Contents**

- [GETTING STARTED](#getting-started)
  - [Install pwsh Core](#install-pwsh-core)
    - [Mac OS](#mac-os)
    - [Linux OS](#linux-os)
    - [Windows](#windows)
    - [Raspberry Pi](#raspberry-pi)
  - [Install codemelted CLI](#install-codemelted-cli)
    - [Find-Script](#find-script)
    - [Install-Script](#install-script)
    - [Update-Script](#update-script)
    - [Uninstall-Script](#uninstall-script)
    - [Troubleshooting](#troubleshooting)
      - [Mac OS](#mac-os-1)
      - [Windows OS](#windows-os)
- [FEATURES](#features)
  - [codemelted.ps1 Structure](#codemeltedps1-structure)
  - [codemelted --version](#codemelted---version)
  - [codemelted --help](#codemelted---help)
- [USAGE](#usage)
  - [Async I/O Use Cases](#async-io-use-cases)
  - [Data Use Cases](#data-use-cases)
    - [codemelted --data-check](#codemelted---data-check)
    - [codemelted --json](#codemelted---json)
    - [codemelted --string-parse](#codemelted---string-parse)
  - [NPU Use Cases](#npu-use-cases)
  - [SDK Use Cases](#sdk-use-cases)
    - [codemelted --logger](#codemelted---logger)
    - [codemelted --network](#codemelted---network)
  - [User Interface Use Cases](#user-interface-use-cases)
    - [codemelted --console](#codemelted---console)
- [MODULE INFORMATION](#module-information)
  - [License](#license)
  - [Versioning](#versioning)

# GETTING STARTED

## Install pwsh Core

The following section walk you through the installation of the pwsh terminal. Once installed you can access the terminal via the `pwsh` command.

### Mac OS

From a Mac OS terminal execute the command:

```
brew install --cask powershell
```

### Linux OS

Follow the <a target="_blank" href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.4">Install Powershell on Linux</a> to properly setup the pwsh terminal for your Linux flavor.

### Windows

From a windows cmd terminal execute the command

```
winget install --id Microsoft.PowerShell --source winget
```

### Raspberry Pi

The following series of commands will setup a pwsh terminal on a Raspberry Pi picking up the necessary repo and setting up the environment. Notice the `v7.4.6` as the currently identified version. Change this to install the latest version.

```
dpkg --add-architecture arm64
apt-get update
apt-get install -y libc6:arm64 libstdc++6:arm64
mkdir -p /opt/microsoft/powershell/7
wget -O /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v7.4.6/powershell-7.4.6-linux-arm64.tar.gz
tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
chmod +x /opt/microsoft/powershell/7/pwsh
ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
rm /tmp/powershell.tar.gz
pwsh --version
```

## Install codemelted CLI

### Find-Script

To find the current version published in the PSGallery execute:

```
Find-Script -Name codemelted
```

### Install-Script

To install the codemelted CLI from the PS Gallery execute:

```
Install-Script -Name codemelted
```

### Update-Script

To update to the latest version of the codemelted CLI from the PS Gallery execute:

```
Update-Script -Name codemelted
```

### Uninstall-Script

To completely uninstall the codemelted CLI execute:

```
Uninstall-Script -Name codemelted
```

### Troubleshooting

#### Mac OS

On Mac OS in the zsh terminal, the `$env:PSModulePath` does not include the `Scripts/` path where the `Install-Script` installs the `codemelted.ps1` script file. To fix this issue, add the following entry to your `.zshrc` file.

```bash
export PWSH_SCRIPT_INSTALL="$HOME/.local/share/powershell/Scripts:/usr/local/share/powershell/Scripts:/usr/local/microsoft/powershell/7/Scripts"
# Make sure on this to not eliminate any other script settings.
export PATH="$PWSH_SCRIPT_INSTALL:$PATH"
```

#### Windows OS

No issues when running the `Install-Script` cmdlet.

# FEATURES

<center><img style="width: 100%; max-width: 560px;" src="../../design-notes/use-case-model.drawio.png" /></center>

The following describes how the *codemelted* CLI implements the above use cases.

## codemelted.ps1 Structure

The `codemelted.ps1` is divided into three sections. The first section is the *TERMINAL MODULE DEFINITION*. This section contains the `PSScriptInfo` that describes the script on [PowerShell  Gallery](https://www.powershellgallery.com/). It also defines the general script interface, the `--version` flag, and the `--help` system.

The next section is the *USE CASE DEFINITIONS*. This section is divided into the five use case groups reflected in the use case model above. Each of these sections contains a `function codemelted_xxx {}` definition representing each individual use case function for the given group. The function definition is divided into the `<#.SYNOPSIS #>` that defines the help section along with the `param()` which defines the interface to the function. Any violation of the function will result in a `SyntaxError: xxx` which will aid in properly using the function.

The last section is the *MAIN API DEFINITION*. This defines the mapping between the `--use-case` flag to the function call. This completes the overall `codemelted --use-case @{}` CLI signature of this module. The next sections will walk you through utilizing CLI to get help on individual use cases *(NOTE: They are also covered in this page)*.

## codemelted --version

```
Name       Version Author                      Description
----       ------- ------                      -----------
codemelted 0.5.2.0 mark.shaffer@codemelted.com   A CLI to facilitate common developer use cases on Mac, Linux, or Windows systems.
```

## codemelted --help

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
        # To Learn About the CLI use cases.
        --help : Execute 'codemelted --help @{ "action" = "--use-case" }'
                 to learn more about the CLI Actions.
        --version : Get current information about the codemelted CLI

        # Async I/O Use Cases
        TBD

        # Data Use Cases
        --data-check
        --disk (IN DEVELOPMENT. DON'T USE)
        --json
        --string-parse

        # NPU Use Cases
        TBD

        # SDK Use Cases
        --logger
        --network (IN DEVELOPMENT. fetch usable)

        # User Interface Use Cases
        --console

      [Params]
        The optional set of named arguments wrapped within a [hashtable]

    RETURNS:
      Will vary depending on the called [Action].
```

# USAGE

<center><img style="width: 100%; max-width: 560px;" src="../../design-notes/module-architecture.drawio.png" /></center>

The following sub-sections provides examples of each of the implemented use cases.

## Async I/O Use Cases

<mark>TBD</mark>

## Data Use Cases

<mark>TBD</mark>

### codemelted --data-check

```
NAME
    codemelted_data_check

SYNOPSIS
    Provides basic data validation and type checking of dynamic variables
    within a powershell script.

    SYNTAX:
      # Checks that the specified 'data' [hashtable] has the specified 'key'.
      $answer = codemelted --data-check @{
        "action" = "has_property";      # required
        "data" = [hashtable];           # required
        "key" = "name of key in data";  # required
        "should_throw" = $false         # optional
      }

      # Checks that the specified 'data' variable is the expected typename
      # specified by the 'key'.
      $answer = codemelted --data-check @{
        "action" = "type";       # required
        "data" = $variable;      # required
        "key" = "typename";      # required (.NET type names)
        "should_throw" = $false  # optional
      }

      # Checks that the specified 'data' is a well formed URI object.
      $answer = codemelted --data-check @{
        "action" = "url";        # required
        "data" = "url string";   # required
        "should_throw" = $false  # optional
      }

    RETURNS:
      [boolean] $true if data check passes, $false otherwise

    THROWS:
      [string] if 'should_throw' is set to $true in the $Params.
```

### codemelted --json

```
NAME
    codemelted_json

SYNOPSIS
    Provides the facilities to create / copy JSON compliant .NET objects and
    the ability to parse / stringify that data for storage, transmission, and
    processing of the data.

    SYNTAX:
      # Create / copy data into a new [arraylist]
      $data = codemelted --json @{
        "action" = "create_array";  # required
        "data" = $arrayListData     # optional [arraylist] to copy
      }

      # Create / copy data into a new [arraylist]
      $data = codemelted --json @{
        "action" = "create_object";  # required
        "data" = $hashTableData      # optional [arraylist] to copy
      }

      # Parse a string into a [hashtable] or [arraylist] or generic datatype
      $data = codemelted --json @{
        "action" = "parse";   # required
        "data" = $stringData  # required [string] data
      }

      # Transform a [arraylist] or [hashtable] into string data
      $data = codemelted --json @{
        "action" = "stringify"; # required
        "data" = $theData       # required [arraylist] or [hashtable] data
      }

    RETURNS:
      [arraylist] for 'create_array' / 'parse' actions.
      [hashtable] for 'create_object' / 'parse' actions.
      [string] for 'stringify' action.
      $null for invalid data types that can't be translated.
```

### codemelted --string-parse

```
NAME
    codemelted_string_parse

SYNOPSIS
    Provides the facilities to translate strings into their appropriate
    data type.

    SYNTAX:
      $data = codemelted --string-parse @{
        "action" = "";  # required
        "data" = $dataString  # required
      }

    ACTIONS:
      array / boolean / double / int / object

    RETURNS:
      [System.Collections.ArrayList] for 'array' action.
      [boolean] for 'boolean' action.
      [double] for 'double' action.
      [int] for 'int' action.
      [object] for 'object' action.
      $null for string data that can't be translated.
```

## NPU Use Cases

<mark>TBD</mark>

## SDK Use Cases

<mark>TBD</mark>

### codemelted --logger

```
NAME
    codemelted_logger

SYNOPSIS
    Provides a logging facility to report log events to STDOUT color coded
    based on the type of event. Also provides for setting up a handler to
    perform other types of processing not just to STDOUT.

    SYNTAX:
      # Set up the log level for the logging facility within the module.
      # The "data" levels are 'debug' / 'info' / 'warning' / 'error' / 'off'.
      codemelted --logger @{
        "action" = "log_level";  # required
        "data" = [string]       # optional
      }

      # Set up a log handler for logged events via the logger. This will
      # be called when the logger is not configured as off. Regardless of
      # the log level, the event will be passed to the handler. The
      # CLogRecord object will include the current moduleLogLevel.
      codemelted --logger @{
        "action" = "handler";           # required
        "data" = [scriptblock] / $null  # required
      }

      # To log data to STDOUT set the "action" to 'debug' / 'info' /
      # 'warning' / 'error'. If the event meets the module log level,
      # it will report to STDOUT color coded and time stamped.
      codemelted --logger @{
        "action" = [string]  # required
        "data"   = [string]  # required
      }

    RETURNS:
      [string] When the action is 'log_level' but no log level is set.
      [void]   For all other actions.
```

### codemelted --network

```
NAME
    codemelted_network

SYNOPSIS
    Provides a basic mechanism for interacting with a user via STDIN and
    STDOUT for later processing within a script.

    SYNTAX:
      # Perform a network fetch to a REST API. The "data" is a [hashtable]
      # reflecting the named parameters of the Invoke-WebRequest. So the two
      # most common items will be "method" / "body" / "headers" but others
      # are reflected via the link.
      $resp = codemelted --network @{
        "action" = "fetch";    # required
        "url" = [string / ip]; # required
        "data" = [hashtable]   # required
      }

      # FUTURE ACTIONS not implemented yet.
      http_server / websocket_client / websocket_server

    RETURNS:
      [CNetworkResponse] for the 'fetch' action that has the statusCode,
        statusText, and data as properties. Methods of asBytes(), asObject(),
        asString() exists to get the data of the expected type or $null if
        not of that type.

RELATED LINKS
    Invoke-WebRequest Details:
    https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-webrequest
```

## User Interface Use Cases

<mark>TBD</mark>

### codemelted --console

```
NAME
    codemelted_console

SYNOPSIS
    Provides a basic mechanism for interacting with a user via STDIN and
    STDOUT for later processing within a script.

    SYNTAX:
      $answer = codemelted --console @{
        "action" = "";  # required
        "message" = ""; # optional message to associate with action
        "choices" = @(  # required when using the 'choose' action.
          "dog",
          "cat",
          "fish"
        )
      }

    ACTIONS:
      alert / confirm / choose / password / prompt / writeln

    RETURNS:
      alert    [void]
      confirm  [boolean]
      choose   [int]
      password [string]
      prompt   [string]
      writeln  [void]
```

# MODULE INFORMATION

The following sub-sections cover various aspects the `codemelted.ps1` module information. It is a single file implementation of the identified use cases.

## License

MIT License

© 2024 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Versioning

The versioning of the module will be captured via GitHub or the modules documentation method. It will utilize semantic versioning `X.Y.Z` with the following rules for the numbering scheme this project.

- **X:** Completion of a given set of use cases (i.e. Async IO, Data, NPU, SDK, or User Interface).
- **Y:** Use case implemented, documented, tested, and ready for usage by a developer.
- **Z:** Bug fix or expansion of a use case.
