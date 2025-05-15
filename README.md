<center>
  <img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/favicon/apple-touch-icon.png" /> CodeMelted DEV Project</h1>

The following document will help you setup this repo for local development utilizing PowerShell Core, VS Code, and the installation of the necessary tools to support the `build.ps1` script.

<center>
  <br />
  <a href="https://www.buymeacoffee.com/codemelted" target="_blank">
    <img height="50px" src="https://codemelted.com/assets/images/icon-bmc-button.png" />
  </a>
  <br /><br />
  <p>Hope you enjoy the content. Any support is greatly appreciated. Thank you! 🙇</p>
</center>

**Table of Contents**

- [Environment Setup](#environment-setup)
  - [GitHub](#github)
  - [Programming Languages](#programming-languages)
  - [VS Code](#vs-code)
- [Repo Structure](#repo-structure)
  - [build.ps1 Script](#buildps1-script)
  - [Module Directories](#module-directories)

## Environment Setup

The following are the items recommended for installation to properly make use of this repo in your development environment.

### GitHub

- [ ] [git](https://git-scm.com/downloads)
- [ ] [GitHub Desktop](https://desktop.github.com/)

### Programming Languages

- [ ] [Deno](https://deno.com/)
- [ ] [Flutter](https://flutter.dev/)
- [ ] [NodeJS](https://nodejs.org/en)
- [ ] [PowerShell Core](https://github.com/PowerShell/PowerShell)
- [ ] [Rust](https://doc.rust-lang.org/book/ch01-01-installation.html)

### VS Code

**The Application:**

- [ ] [VS Code](https://code.visualstudio.com/)

**Extensions:**

- [ ] [Code Spell Checker](https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker)
- [ ] [Dart](https://marketplace.visualstudio.com/items?itemName=Dart-Code.dart-code)
- [ ] [Deno](https://marketplace.visualstudio.com/items?itemName=denoland.vscode-deno)
- [ ] [Docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
- [ ] [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [ ] [Flutter](https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
- [ ] [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
- [ ] [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)
- [ ] [PowerShell](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)
- [ ] [Rust](https://marketplace.visualstudio.com/items?itemName=rust-lang.rust-analyzer)

## Repo Structure

### build.ps1 Script

The `build.ps1 --build` script provides the ability to build, test, and document the `codemelted_developer` repo modules. The `build.ps1 --deploy` deploys the [CodeMelted DEV](https://codemelted.com/developer) website. The `build.ps1 --test` will test any changes to the repo modules.

### Module Directories

The following are the individual source module project folders. They are setup to work with both the CLI tools of that particular language SDK and the `build.ps1` script. For an understanding what these modules are about see the `design-notes.drawio.html` file or the individual `README.md` file of each project.

- [codemelted_dev](codemelted_dev): An `mdbook` project documenting what the *CodeMelted DEV Project* is all about.
- [codemelted_flutter](codemelted_flutter/): The development of the `codemelted.dart` module and supporting project definitions for targeting Flutter Web targets. Supports both SDK deployment to the `codemelted.com` domain and `pub.dev` for discoverability by flutter developers.
- [codemelted_js](codemelted_js/): The development of the `codemelted.js` ES6 module for usage in Deno, NodeJS, and static Web page deployments. Supports SDK deployment to the `codemelted.com` domain with support via the `codemelted` CLI when starting new web projects.
- [codemelted_pi](codemelted_pi/): An `mdbook` project documenting the CodeMelted PI project. It will contain all the design artifacts and instructions for how to setup such a system for photography fun.
- [codemelted_pwsh](codemelted_pwsh/): An `mdbook` project documenting the `codemelted.ps1` module that represents the `codemelted` CLI. Supports both SDK deployment to the `codemelted.com` domain and the Microsoft PSGallery for script installation.
- [codemelted_rust](codemelted_rust/): The development of the `codemelted.rs` cargo project to support native app / service development. Supports both SDK deployment to the `codemelted.com` domain and the `crates.io` Rust repository.
- `index.html`: Static page for the `codemelted.com/developer` domain to access the above SDK documents.