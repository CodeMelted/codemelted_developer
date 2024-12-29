<!--
TITLE: CodeMelted DEV | Modules
PUBLISH_DATE: 2024-11-28
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, wasm
DESCRIPTION: Software engineers are now required to learn multiple languages, technologies, and frameworks in order to fully support full stack engineering. This project aims to simplify this by developing a set of modules implementing a similar / identical Application Program Interface (API) regardless of the chosen technology covered by this project. It gives the ability to achieve maximum application reach by supporting the development of Progressive Web Applications (PWAs). The modules are specifically designed to target each area of the technology stack to deliver PWAs.
-->
<center>
  <img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-design.png" /> CodeMelted DEV | Modules</h1>

Software engineers are now required to learn multiple languages, technologies, and frameworks in order to fully support full stack engineering. This project aims to simplify this by developing a set of modules implementing a similar / identical Application Program Interface (API) regardless of the chosen technology covered by this project. It gives the ability to achieve maximum application reach by supporting the development of Progressive Web Applications (PWAs). The modules are specifically designed to target each area of the technology stack to deliver PWAs.

**LAST UPDATED:** 2024-12-28

**Table of Contents**

- [FEATURES](#features)
  - [Async I/O Use Cases](#async-io-use-cases)
    - [Process](#process)
    - [Task](#task)
    - [Worker](#worker)
  - [Data Use Cases](#data-use-cases)
    - [Database](#database)
    - [Disk](#disk)
    - [File](#file)
    - [JSON](#json)
    - [Storage](#storage)
  - [NPU Use Cases](#npu-use-cases)
    - [Execute](#execute)
    - [Math](#math)
    - [Memory](#memory)
  - [SDK Use Cases](#sdk-use-cases)
    - [Logger](#logger)
    - [Hardware](#hardware)
    - [Network](#network)
    - [Runtime](#runtime)
  - [User Interface Use Cases](#user-interface-use-cases)
    - [Audio](#audio)
    - [Console](#console)
    - [Dialog](#dialog)
    - [SPA](#spa)
    - [Theming](#theming)
    - [Widget](#widget)
  - [Module Design](#module-design)
    - [PWA Modules](#pwa-modules)
      - [Flutter](#flutter)
      - [JavaScript](#javascript)
    - [Terminal Module](#terminal-module)
    - [NPU Module](#npu-module)
- [GETTING STARTED](#getting-started)
  - [Environment Setup](#environment-setup)
    - [GitHub](#github)
    - [Programming Languages](#programming-languages)
    - [VS Code](#vs-code)
  - [Module Versioning](#module-versioning)
  - [Build Script](#build-script)
- [codemelted.dart Change Log](#codemelteddart-change-log)
- [LICENSE](#license)

# FEATURES

<center><img style="width: 100%; max-width: 560px;" src="./design-notes/use-case-model.drawio.png" /></center>

The use case model featured above identifies 21 developer use cases divided into five major areas of how to architect a PWA. Each of these use cases will be implemented with a similar API across the different across module technology stacks. This will allow developers to easily create solutions to support their PWA.

## Async I/O Use Cases

All programming happens synchronously (i.e. one instruction to the next). This occurs within the event loop of the main SDK execution thread. This use case will provide the ability for chunking up this work asynchronously.

The developer will be able to schedule one off tasks awaiting the result via a promise. They will have the ability to schedule repeating tasks. They will have the ability to communicate with other services via a process. Lastly they will have the ability to queue tasks for processing via a worker pool.

### Process

<mark>TBD</mark>

### Task

<mark>TBD</mark>

### Worker

<mark>TBD</mark>

## Data Use Cases

The number one reason developers write code is to take data in as input, process it, and then spit that data as output. Going along with this philosophy, these use cases will provide a developer the ability read, write, and process data. The input / output mechanisms will be via files, embedded database, and storage facilities for holding key / value pairs of data.

Given the dynamic nature of data, a series of type checks will be provided to the developer. Lastly JSON represents the most versatile data type that works between languages. The developer will have access to work with this data type with encoding / decoding capabilities between the JSON object and string formats.

### Database

<mark>TBD</mark>

### Disk

**Description:** When running a backend service or terminal task, you may need to manipulate items on disk. This includes files and directories. This use case will create a *disk* namespace that attaches these management items along with queryable properties such as a user's home directory as an example.

**Acceptance Criteria:**

1. The disk namespace will provide the ability to copy files / directories from one location to another.
2. The disk namespace will determine if a given file / path exists on a disk.
3. The disk namespace will provide the ability to determine the user's home directory.
4. The disk namespace will provide the ability to get a listing of files from disk.
5. The disk namespace will provide the ability to create a directory (including parent directories) on disk.
6. The disk namespace will provide the ability to move a file / directory from one location to another on disk.
7. The disk namespace will determine the path separator character for the given operating system. Backslash for windows, forward slash for all unix variants.
8. The disk namespace will provide the ability to remove a filename / directory from disk.
9. The disk namespace will provide the ability to determine the temporary directory path on disk.
10. The disk namespace will provide the ability to read / write an entire file (text or blob) to / from disk.

### File

<mark>TBD</mark>

### JSON

**Description:** JavaScript Object Notation (JSON) represents a way of building complex data types and providing a universal way of serializing / deserializing the data as a string or object. JSON has become the goto data type for REST APIs, NoSQL database, and key / value pair storage of data. This use case will expose a namespace and utility objects to fully take advantage of this data object notation.

**Acceptance Criteria:**

1. The json namespace will support the conversion of string types to valid JSON constructs if they are of that type. These include array, boolean, number, and object types. Failure to convert will result in a `null` return.
2. The json namespace will provide the ability to parse and stringify valid JSON constructs. Failure to parse or stringify the data will result in a `null` return.
3. The json namespace will provide the ability to perform validity checks. These validity checks include determining if a JSON object has a given property, if a particular data type is of an expected type, and valid URLs. These checks can will return either a boolean of the check or throw exceptions.
4. The json namespace will provide the ability to create JSON array / object types that work within the given SDK JSON datatype.

### Storage

<mark>TBD</mark>

## NPU Use Cases

This is a specialized set of use cases representing a software Numerical Processing Unit (NPU). These will be designed in accordance with the [WASM Use Cases](https://webassembly.org/docs/use-cases/) in terms of interface definition and memory management.

### Execute

<mark>TBD</mark>

### Math

<mark>TBD</mark>

### Memory

<mark>TBD</mark>

## SDK Use Cases

A chosen SDK technology provides access to items specific to the runtime. This use case will expose those elements to the developer. This includes accessing data via hardware peripherals attached / available to a device and network services for communicating via the Internet. Also available will be logging facilities to gage the health of an application. Finally a collection of Runtime services specific to the SDK will also be exposed.

### Logger

<mark>TBD</mark>

### Hardware

<mark>TBD</mark>

### Network

<mark>TBD</mark>

### Runtime

<mark>TBD</mark>

## User Interface Use Cases

The biggest thing all applications have is a way of interacting with a user. This use case will expose a common way for either building a Command Line Interface (CLI) prompting the user for input or building a complex Single Page App (SPA) interface. This will allow for a consistent experience of communicating with an application user.

### Audio

<mark>TBD</mark>

### Console

**Description:** A STDIN / STDOUT interaction is the barest bone user interface that one can present to a user. Unlike a Command Line Interface (CLI) where a user must know the different flags to invoke the interface, a STDIN / STDOUT interaction provides a continuous set of prompts and messages guiding the user. This is commonly referred to as a System Console. This use case will provide a console interface to facilitate such actions.

**Acceptance Criteria:**

1. The console namespace will provide the ability to alert a user with a custom message that requires the *Enter* key press to continue processing.
2. The console namespace will provide the ability for a Yes/No confirmation to a user where *Y* will return *true* and anything else will return *false*.
3. The console namespace will provide the ability to choose from a set of options returning the index of the user selection. An invalid selection will result in attempting the choice again.
4. The console namespace will provide the ability to enter a *password* concealing their entry via STDIN. The result returned will be a string.
5. The console namespace will provide the ability to answer prompted questions. The result returned will be a string.
6. The console namespace will provide the ability to write a line of text with newline to STDOUT.

### Dialog

<mark>TBD</mark>

### SPA

<mark>TBD</mark>

### Theming

<mark>TBD</mark>

### Widget

<mark>TBD</mark>

## Module Design

<center><img style="width: 100%; max-width: 560px;" src="./design-notes/module-architecture.drawio.png" /></center>

**Module Links**

- [PWA Modules](./pwa/README.md)
- [Terminal Module](./terminal/README.md)
- [NPU Module](./npu/README.md)

### PWA Modules

The call signature for these modules will be via a namespace signature of `codemelted.[useCase].[function]()` with named parameters for the given function. Queryable items will be attached to the appropriate `useCase` as properties.

#### Flutter

The `codemelted.dart` which is the main root of this repo provides a Flutter specific implementations of the identified use cases delivering the full power of Flutter to construct PWAs. Use cases with no direct Flutter binding will utilize the `codemelted.js` and `codemelted.wasm` modules further detailed below.

#### JavaScript

The `codemelted.js` is a ES6 module that can operate in both a Web Browser and Deno runtime environments. It implements all the identified use cases for the different environments to provide the ability to deliver SPA/PWA solutions or support Dev Ops facilities using Deno. This is the heart of the *PWA Modules* as the `codemelted.dart` is not necessary to code a full web solution.

### Terminal Module

The `codemelted.ps1` script will provide a Command Line Interface (CLI) to facilitate common developer use cases on Mac, Linux, or Windows systems. When installed the CLI will provide the `codemelted` command that can be accessed in a pwsh terminal or in `ps1` scripts that facilitate a set of automated tasks. A developer may also build a Terminal User Interface (TUI) for a text based user interface.

The call signature for the CLI will be as follows

```
codemelted [Action] [Command] [Params]
```

*WHERE*

- `[Action]`: A flag `--use-case` that corresponds to one of the identified use cases.
- `[Command]`: A flag that corresponds to a given function of th identified use case.
- `[Params]`: A PowerShell hash table `@{}` that will setup named parameters and values associated with the selected `[Command]`.

*NOTE: This module will also provide a CLI interface for Raspberry Pi built services. See the module SDK documentation for details.*

### NPU Module

A `codemelted.cpp` C++ 20 module that will support the *WASM Module* use cases for its interface definition. It will be compiled as a `*.wasm` module to support the [PWA Modules](#pwa-modules) and as a static library to support the [Terminal Module](#terminal-module) on the different operating systems.

*NOTE: A developer can also just utilize this module within a C++ application if they so choose utilizing the C++ 20 module standard.*

# GETTING STARTED

## Environment Setup

The following are the items recommended for installation to properly make use of this repo in your development environment.

### GitHub

- [ ] [git](https://git-scm.com/downloads)
- [ ] [GitHub Desktop](https://desktop.github.com/)

### Programming Languages

- [ ] [C/C++](https://code.visualstudio.com/docs/languages/cpp)
- [ ] [Deno](https://deno.com/)
- [ ] [Flutter](https://flutter.dev/)
- [ ] [NodeJS](https://nodejs.org/en)
- [ ] [PowerShell Core](https://github.com/PowerShell/PowerShell)
- [ ] [Python](https://www.python.org/)

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

## Module Versioning

The versioning of the module will be captured via GitHub or the modules documentation method. It will utilize semantic versioning `X.Y.Z` with the following rules for the numbering scheme this project.

- **X:** Completion of a given set of use case (i.e. Async IO, Data, NPU, SDK, or User Interface).
- **Y:** Use case implemented, documented, tested, and ready for usage by a developer.
- **Z:** Bug fix or expansion of a use case.

## Build Script

The `build.ps1 --build` script provides the ability to build, test, and document the `codemelted_developer` repo modules. The `build.ps1 --deploy` deploys the [CodeMelted DEV](https://developer.codemelted.com) website.

# codemelted.dart Change Log

<iframe style="background-color: white" src="CHANGELOG.md" width="100%" height="350px"></iframe>

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