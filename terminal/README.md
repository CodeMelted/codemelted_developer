<!--
TITLE: CodeMelted DEV | Terminal Module
PUBLISH_DATE: 2024-12-28
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: The `codemelted.ps1` script will provide a Command Line Interface (CLI) to facilitate common developer use cases on Mac, Linux, or Windows systems. When installed the CLI will provide the `codemelted` command that can be accessed in a pwsh terminal or in `ps1` scripts that facilitate a set of automated tasks. A developer may also build a Terminal User Interface (TUI) for a text based user interface.
-->
<center>
  <a title="Back To Developer Main" href="../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-codemelted-terminal.png" /> CodeMelted DEV | Terminal Module</h1>

The `codemelted.ps1` script will provide a Command Line Interface (CLI) to facilitate common developer use cases on Mac, Linux, or Windows systems. When installed the CLI will provide the `codemelted` command that can be accessed in a pwsh terminal or in `ps1` scripts that facilitate a set of automated tasks. A developer may also build a Terminal User Interface (TUI) for a text based user interface.

**LAST UPDATED:** 2024-12-28

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
- [USAGE](#usage)
  - [codemelted CLI](#codemelted-cli)
    - [Get Version](#get-version)
    - [Navigate Help](#navigate-help)
  - [Raspberry Pi Services](#raspberry-pi-services)
- [LICENSE](#license)

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

#### Uninstall-Script

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

# USAGE

## codemelted CLI

The following sub-sections break down how to drill into the codemelted CLI help system. It utilizes the PowerShell Help system tailored to the codemelted CLI needs.

### Get Version

`codemelted --about` will tell you what version of the codemelted CLI module is installed. The output will be as follows:

```
Name       Version Author                      Description
----       ------- ------                      -----------
codemelted 0.1.0.0 mark.shaffer@codemelted.com   A CLI to facilitate common developer use cases on Mac, Linux, or Windows systems.
```

To check for the latest version of the script execute `Update-Script -Name codemelted` in a `pwsh` terminal window.

### Navigate Help

`codemelted --help` will produce the following STDOUT from the PowerShell `Get-Help` system. From the help output, you can drill into the help system of each `[Action]`. You only care about the following fields from any command help:

- SYNOPSIS
- DESCRIPTION
- RELATED LINKS

```
NAME
    help

SYNOPSIS
    The codemelted Command Line Interface (CLI) Terminal Module. It allows
    a developer to execute the CodeMelted DEV | Module use cases within a
    pwsh terminal shell. This allows for building CLI tools, Terminal User
    Interface (TUI) tools, or building DevOps toolchain automation.

    SYNTAX:

      codemelted [Action] [Command] [Params]


SYNTAX
    help [<CommonParameters>]


DESCRIPTION
    PARAMETERS:

      [Action]
        --about : Displays the current PSScriptInfo about this module CLI.
        --json  : Provides the ability to work with JSON data.
        --help  : Displays this help system to facilitate navigating the CLI.

      [Command]
        Commands attached to each [Action] parameter. Execute the following
        to get the specific [Command] parameters associated with the [Action]
        parameter and the [Args] associated with the [Command] parameters.

        codemelted [Action] help

      [Params]
        The optional set of named arguments wrapped within a [hashtable]


RELATED LINKS
    CodeMelted | DEV Modules:
    https://developer.codemelted.com

    GitHub Source:
    https://github.com/CodeMelted/codemelted_developer/tree/main/terminal

REMARKS
    To see the examples, type: "Get-Help help -Examples"
    For more information, type: "Get-Help help -Detailed"
    For technical information, type: "Get-Help help -Full"
    For online help, type: "Get-Help help -Online"
```

## Raspberry Pi Services

<mark>TBD</mark>

# LICENSE

MIT License

© 2024 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<center>
  <br />
  <a href="https://www.buymeacoffee.com/codemelted" target="_blank">
    <img height="50px" src="https://codemelted.com/assets/images/icon-bmc-button.png" />
  </a>
  <br /><br />
  <p>Hope you enjoyed the content. Any support is greatly appreciated. Thank you! 🙇</p>
</center>
