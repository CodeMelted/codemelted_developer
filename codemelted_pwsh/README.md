<!--
TITLE: CodeMelted DEV | pwsh Module
PUBLISH_DATE: 2025-03-12
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: The codemelted.ps1 script will provide a Command Line Interface (CLI) to facilitate common developer use cases on Mac, Linux, or Windows systems. When installed, the CLI will provide the codemelted command that can be accessed in a pwsh terminal or in ps1 scripts that facilitate a set of automated tasks. A developer may also build a Terminal User Interface (TUI) for a text-based user interface. Lastly it will facilitate in developing applications utilizing the CodeMelted DEV | Modules.
-->
<center>
  <a title="Back To Developer Main" href="../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-pwsh.png" /> CodeMelted DEV | pwsh Module</h1>

The codemelted.ps1 script will provide a Command Line Interface (CLI) to facilitate common developer use cases on Mac, Linux, or Windows systems. When installed, the CLI will provide the codemelted command that can be accessed in a pwsh terminal or in ps1 scripts that facilitate a set of automated tasks. A developer may also build a Terminal User Interface (TUI) for a text-based user interface. Lastly it will facilitate in developing applications utilizing the CodeMelted DEV | Modules.

**LAST UPDATED:** 2025-03-12

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
    - [cmdlets](#cmdlets)
    - [Troubleshooting](#troubleshooting)
      - [Linux / Mac / Raspberry Pi](#linux--mac--raspberry-pi)
      - [Windows OS](#windows-os)
- [FEATURES](#features)
  - [codemelted.ps1 Structure](#codemeltedps1-structure)
  - [codemelted --version](#codemelted---version)
  - [codemelted --help](#codemelted---help)
- [USAGE](#usage)
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

Follow the <a target="_blank" href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux">Install Powershell on Linux</a> to properly setup the pwsh terminal for your Linux flavor.

### Windows

From a windows cmd terminal execute the command

```
winget install --id Microsoft.PowerShell --source winget
```

### Raspberry Pi

The following series of commands will setup a pwsh terminal on a Raspberry Pi picking up the necessary repo and setting up the environment. Notice the `VERSION` as the currently identified version. Change this to install the latest version.

```sh
VERSION=7.5.0
sudo dpkg --add-architecture arm64
sudo apt-get update
sudo apt-get install -y libc6:arm64 libstdc++6:arm64
sudo mkdir -p /opt/microsoft/powershell/7
sudo wget -O /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${VERSION}/powershell-$VERSION}-linux-arm64.tar.gz
sudo tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
sudo chmod +x /opt/microsoft/powershell/7/pwsh
sudo ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
sudo rm /tmp/powershell.tar.gz
pwsh --version
```

## Install codemelted CLI

The `codemelted.ps1` CLI script is hosted at [PowerShell Gallery](https://www.powershellgallery.com/packages/codemelted/0.5.3) to facilitate its installation as discussed below.

### cmdlets

- `Find-Script -Name codemelted`: To find the current version published in the PSGallery.
- `Install-Script -Name codemelted`: To install the codemelted CLI from the PSGallery.
- `Update-Script -Name codemelted`: To update to the latest version of the codemelted CLI from the PSGallery.
- `Uninstall-Script -Name codemelted`: To completely uninstall the codemelted CLI.

### Troubleshooting

#### Linux / Mac / Raspberry Pi

On the various supported unix variant operating systems, the `$env:PSModulePath` does not include the `Scripts/` path where the `Install-Script` installs the `codemelted.ps1` script file. To fix this issue, add the following entry to the appropriate **Sources** script so when you kick off `pwsh` shell, you can access the `codemelted` command.

**Sources:** The following bullets discuss the script profile order from login to executing an interactive shell. Utilize this to determine where to put the script code below to add the pwsh scripts to the `$PATH` variable.

- [Shell Startup](https://docs.nersc.gov/environment/shell_startup/)
- [zsh Guide Section 2.2](https://zsh.sourceforge.io/Guide/zshguide02.html)

**Shell Code to Add to Appropriate Login / Startup Script:**

```sh
# set PATH so it includes user's pwsh installed scripts
if [ -d "$HOME/.local/share/powershell/Scripts" ]; then
   PATH="$HOME/.local/share/powershell/Scripts:$PATH"
fi
```

#### Windows OS

No issues when running the `Install-Script` cmdlet on Windows 10/11.


*NOTE: If the `$env:PSModulePath` is not a part of the `%PATH%`, you can correct this by adding the value of `$env:PSModulePath` to the [How to Edit Environment Variables on Windows 10 or 11](https://www.howtogeek.com/787217/how-to-edit-environment-variables-on-windows-10-or-11/)*

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
codemelted 1.0.0.0 mark.shaffer@codemelted.com   A CLI to facilitate common developer use cases on Mac / Linux / Windows OS.
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

        # Async I/O Use Cases (Completed)
        --task
        --process
        --worker

        # Data Use Cases
        --database     (TBD)
        --data-check
        --disk         (IN DEVELOPMENT. DON'T USE)
        --file         (TBD)
        --json
        --string-parse
        --storage      (TBD)
        --xml          (TBD)

        # NPU Use Cases
        --compute (TBD)
        --math    (TBD)

        # SDK Use Cases
        --developer (TBD)
        --logger
        --monitor   (TBD)
        --network   (IN DEVELOPMENT. fetch usable)
        --pi        (TBD)
        --runtime
        --setup     (TBD)

        # User Interface Use Cases
        --app     (TBD)
        --console
        --dialog  (TBD)
        --ui      (TBD)

      [Params]
        The optional set of named arguments wrapped within a [hashtable]

    RETURNS:
      Will vary depending on the called [Action].
```

# USAGE

*NOTE: Current version is frozen and usable. But it will be going through a refactor. Stay Tuned*

<mark>TBD</mark>

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

- **X:** When the 14 identified use cases are fully functional.
- **Y:** Use case implemented, documented, tested, and ready for usage by a developer.
- **Z:** Bug fix or expansion of a use case.
