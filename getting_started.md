<!--
TITLE: CodeMelted - DEV | Getting Started
PUBLISH_DATE: 2024-08-03
AUTHOR: Mark Shaffer
KEYWORDS: CodeMelted - DEV, Getting Started
DESCRIPTION: Describes how to setup and make changes to the CodeMelted - Developer project once cloned from GitHub.
-->
<center>
  <a href="README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logos/logo-developer-smaller.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icons/design.png" /> CodeMelted - Getting Started</h1>

**Table of Contents**

- [Environment Setup](#environment-setup)
  - [GitHub](#github)
  - [Programming Languages](#programming-languages)
  - [VS Code](#vs-code)
- [Module Versioning](#module-versioning)
- [Build Script](#build-script)

## Environment Setup

The following are the items recommended for installation to properly make use of this repo in your development environment.

### GitHub

- [ ] [git](https://git-scm.com/downloads)
- [ ] [GitHub Desktop](https://desktop.github.com/)

### Programming Languages

- [ ] [C/C++](https://code.visualstudio.com/docs/languages/cpp)
- [ ] [Deno](https://deno.com/)
- [ ] [Flutter](https://flutter.dev/)
- [ ] [PowerShell Core](https://github.com/PowerShell/PowerShell)

### VS Code

**The Application:**

- [ ] [VS Code](https://code.visualstudio.com/)

**Extensions:**

- [ ] [C/C++ Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack)
- [ ] [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
- [ ] [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
- [ ] [Deno](https://marketplace.visualstudio.com/items?itemName=denoland.vscode-deno)
- [ ] [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [ ] [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [ ] [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [ ] [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
- [ ] [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)
- [ ] [PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- [ ] [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python)
- [ ] [WSL](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl)

## Module Versioning

The versioning of the module will be captured via GitHub or the modules documentation method. It will utilize semantic versioning `X.Y.Z` with the following rules for the numbering scheme this project.

- **X:** Completion of either Core / User Interface / Advance set of use cases.
- **Y:** Use case implemented, documented, tested, and ready for usage by a developer.
- **Z:** Bug fix or expansion of a use case.

## Build Script

The `build.ps1` script provides the ability to build different elements of this project. Execute the command option below from the root of the `codemelted_developer` repo to get the specified result.

- `./build.ps1 --cdn`: Builds all the other options to a `_dist` directory allowing for a severable static website.
- `./build.ps1 --codemelted_flutter`: Compiles the module and generates its SDK documentation.
- `./build.ps1 --codemelted_js`: Compiles the module to serve from a website and generates its SDK documentation.
- `./build.ps1 --codemelted_pwsh`: Compiles the PowerShell module to be installed on your system and generates its SDK documentation.
- `./build.ps1 --codemelted_pi`: Generates a static website of the raspberry pi `README.md` and supporting markdown files.