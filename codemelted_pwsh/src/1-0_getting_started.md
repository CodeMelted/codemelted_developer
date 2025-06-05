# 1.0 GETTING STARTED

This will guide you through the setup of the `codemelted.ps1` CLI command.

## 1.1 Install pwsh Core

The following section walk you through the installation of the pwsh terminal. Once installed you can access the terminal via the `pwsh` command.

### 1.1.1 Mac OS

From a Mac OS terminal execute the command:

```
brew install --cask powershell
```

### 1.1.2 Linux OS

Follow the <a target="_blank" href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux">Install Powershell on Linux</a> to properly setup the pwsh terminal for your Linux flavor.

### 1.1.3 Windows

From a windows cmd terminal execute the command

```
winget install --id Microsoft.PowerShell --source winget
```

### 1.1.4 Raspberry Pi

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
## 1.2 Install codemelted CLI

The `codemelted.ps1` CLI script is hosted at [PowerShell Gallery](https://www.powershellgallery.com/packages/codemelted/0.5.3) to facilitate its installation as discussed below.

### 1.2.1 cmdlets

- `Find-Script -Name codemelted`: To find the current version published in the PSGallery.
- `Install-Script -Name codemelted`: To install the codemelted CLI from the PSGallery.
- `Update-Script -Name codemelted`: To update to the latest version of the codemelted CLI from the PSGallery.
- `Uninstall-Script -Name codemelted`: To completely uninstall the codemelted CLI.

### 1.2.2 Troubleshooting

#### 1.2.2.1 Linux / Mac / Raspberry Pi

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

#### 1.2.2.2 Windows OS

No issues when running the `Install-Script` cmdlet on Windows 10/11.

*NOTE: If the `$env:PSModulePath` is not a part of the `%PATH%`, you can correct this by adding the value of `$env:PSModulePath` to the [How to Edit Environment Variables on Windows 10 or 11](https://www.howtogeek.com/787217/how-to-edit-environment-variables-on-windows-10-or-11/)*
