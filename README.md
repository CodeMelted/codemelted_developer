<!--
TITLE: CodeMelted DEV | Flutter Module
PUBLISH_DATE: 2025-03-02
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, wasm
DESCRIPTION: The `codemelted.dart` module provides the power of Flutter to build Single Page Applications (SPA) with an easy setup to install the SPA as a Progressive Web App (PWA). This module only targets the Flutter web implementing Flutter specific code to take full advantage of the widget toolkit and Flutter native code that can be utilized within the web. Code that has no native Flutter equivalent will be facilitated via the `codemelted.cpp` loading the compiled `*.wasm` and `*.js` outputs and calling those bindings within the `codemelted.dart` Flutter module.
-->
<center>
  <img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-codemelted-flutter.png" /> CodeMelted DEV | Flutter Module</h1>

The `codemelted.dart` module provides the power of Flutter to build Single Page Applications (SPA) with an easy setup to install the SPA as a Progressive Web App (PWA). This module only targets the Flutter web implementing Flutter specific code to take full advantage of the widget toolkit and Flutter native code that can be utilized within the web. Code that has no native Flutter equivalent will be facilitated via the `codemelted.cpp` loading the compiled `*.wasm` and `*.js` outputs and calling those bindings within the `codemelted.dart` Flutter module.

**LAST UPDATED:** 2025-03-02

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
- [FEATURES](#features)
- [USAGE](#usage)
  - [Async I/O Use Cases](#async-io-use-cases)
    - [Game](#game)
    - [Task](#task)
    - [Worker](#worker)
  - [Data Use Cases](#data-use-cases)
    - [Database](#database)
    - [Data Check](#data-check)
    - [Disk](#disk)
    - [File](#file)
    - [Firebase](#firebase)
    - [JSON](#json)
    - [String Parse](#string-parse)
    - [Storage](#storage)
    - [XML](#xml)
  - [NPU Use Cases](#npu-use-cases)
    - [Compute](#compute)
    - [Math](#math)
    - [Memory](#memory)
  - [SDK Use Cases](#sdk-use-cases)
    - [Events](#events)
    - [Hardware](#hardware)
    - [Logger](#logger)
    - [Network](#network)
    - [Runtime](#runtime)
    - [Schema](#schema)
    - [Share](#share)
  - [User Interface Use Cases](#user-interface-use-cases)
    - [App](#app)
    - [Audio](#audio)
    - [Dialog](#dialog)
    - [Theme](#theme)
    - [UI Widget](#ui-widget)
- [MODULE INFORMATION](#module-information)
  - [License](#license)
  - [Versioning](#versioning)
  - [codemelted.dart Change Log](#codemelteddart-change-log)

# GETTING STARTED

<mark>TBD</mark>

*NOTE: Module is in active development and not ready for primetime. Once stable, this section will be filled in.*

# FEATURES

<center><img style="width: 100%; max-width: 560px;" src="./design-notes/use-case-model.drawio.png" /></center>

# USAGE

<center><img style="width: 100%; max-width: 560px;" src="./design-notes/module-architecture.drawio.png" /></center>

The above module reflects how the `codemelted.dart` module communicates with the supporting `codemelted.js` and `codemelted.wasm` files. These are a result of the WASM `codemelted.cpp` compiled target. It provides the support functionality where no direct Flutter implementation exists. So the `codemelted.dart` module imports the module to provide that functionality. The sub-sections below will provide Flutter examples of each of the use case functions.

## Async I/O Use Cases

### Game

<mark>TBD</mark>

### Task

<mark>TBD</mark>

### Worker

<mark>TBD</mark>

## Data Use Cases

### Database

<mark>TBD</mark>

### Data Check

<mark>TBD</mark>

### Disk

<mark>TBD</mark>

### File

<mark>TBD</mark>

### Firebase

<mark>TBD</mark>

### JSON

<mark>TBD</mark>

### String Parse

<mark>TBD</mark>

### Storage

<mark>TBD</mark>

### XML

<mark>TBD</mark>

## NPU Use Cases

### Compute

<mark>TBD</mark>

### Math

<mark>TBD</mark>

### Memory

<mark>TBD</mark>

## SDK Use Cases

### Events

<mark>TBD</mark>

### Hardware

<mark>TBD</mark>

### Logger

<mark>TBD</mark>

### Network

<mark>TBD</mark>

### Runtime

<mark>TBD</mark>

### Schema

<mark>TBD</mark>

### Share

<mark>TBD</mark>


## User Interface Use Cases

### App

<mark>TBD</mark>

### Audio

<mark>TBD</mark>

### Dialog

<mark>TBD</mark>

### Theme

<mark>TBD</mark>

### UI Widget

<mark>TBD</mark>

# MODULE INFORMATION

The following sub-sections cover various aspects the `codemelted.dart` module information. It is a single file implementation of the identified use cases.

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

## codemelted.dart Change Log

<iframe style="background-color: white" src="CHANGELOG.md" width="100%" height="350px"></iframe>
