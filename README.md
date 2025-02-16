<!--
TITLE: CodeMelted DEV | Flutter Module
PUBLISH_DATE: 2025-02-09
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, wasm
DESCRIPTION: The `codemelted.dart` module provides the power of Flutter to build Single Page Applications (SPA) with an easy setup to install the SPA as a Progressive Web App (PWA). This module only targets the Flutter web implementing Flutter specific code to take full advantage of the widget toolkit and Flutter native code that can be utilized within the web. Code that has no native Flutter equivalent will be facilitated via the `codemelted.cpp` loading the compiled `*.wasm` and `*.js` outputs and calling those bindings within the `codemelted.dart` Flutter module.
-->
<center>
  <img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-codemelted-flutter.png" /> CodeMelted DEV | Flutter Module</h1>

The `codemelted.dart` module provides the power of Flutter to build Single Page Applications (SPA) with an easy setup to install the SPA as a Progressive Web App (PWA). This module only targets the Flutter web implementing Flutter specific code to take full advantage of the widget toolkit and Flutter native code that can be utilized within the web. Code that has no native Flutter equivalent will be facilitated via the `codemelted.cpp` loading the compiled `*.wasm` and `*.js` outputs and calling those bindings within the `codemelted.dart` Flutter module.

**LAST UPDATED:** 2025-02-16

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
  - [Async IO Use Cases](#async-io-use-cases)
  - [Data Use Cases](#data-use-cases)
  - [NPU Use Cases](#npu-use-cases)
  - [SDK Use Cases](#sdk-use-cases)
  - [User Interface Use Cases](#user-interface-use-cases)
- [USAGE](#usage)
  - [Async IO Use Cases](#async-io-use-cases-1)
    - [Task](#task)
    - [Worker](#worker)
  - [Data Use Cases](#data-use-cases-1)
    - [Database](#database)
    - [Data Check](#data-check)
    - [Disk](#disk)
    - [File](#file)
    - [JSON](#json)
    - [String Parse](#string-parse)
    - [Storage](#storage)
    - [XML](#xml)
  - [NPU Use Cases](#npu-use-cases-1)
    - [Compute](#compute)
    - [Math](#math)
    - [Memory](#memory)
  - [SDK Use Cases](#sdk-use-cases-1)
    - [Events](#events)
    - [Hardware](#hardware)
    - [Logger](#logger)
    - [Network](#network)
    - [Orientation](#orientation)
    - [Runtime](#runtime)
    - [Schema](#schema)
    - [Share](#share)
    - [WebRTC](#webrtc)
  - [User Interface Use Cases](#user-interface-use-cases-1)
    - [Audio](#audio)
    - [Dialog](#dialog)
    - [Gamepad](#gamepad)
    - [SPA](#spa)
    - [Theming](#theming)
    - [Widget](#widget)
- [MODULE INFORMATION](#module-information)
  - [License](#license)
  - [Versioning](#versioning)
  - [codemelted.dart Change Log](#codemelteddart-change-log)

# GETTING STARTED

<mark>TBD</mark>

*NOTE: Module is in active development and not ready for primetime. Once stable, this section will be filled in.*

# FEATURES

<center><img style="width: 100%; max-width: 560px;" src="./design-notes/use-case-model.drawio.png" /></center>

## Async IO Use Cases

All programming happens synchronously (i.e. one instruction to the next). This occurs within the event loop of the main SDK execution thread. These use cases will provide the ability for chunking up this work asynchronously.

The developer will be able to schedule one off tasks awaiting the result via a promise. They will have the ability to schedule repeating tasks. Lastly they will have the ability to queue tasks for processing via a worker pool.

**Use Cases:**

- *Task:* Computer code executes synchronously requiring one instruction to complete before another can begin. However you may need a task to run or repeat interrupting this synchronous flow of execution. The task use case will provide an ability to schedule tasks within the event loop of an application thereby breaking up work asynchronously allowing for other processing to occur.
- *Worker:* The worker use case will be a dedicated set of background threaded First In First Out (FIFO) event looped threads executing the same processing logic. The processing logic will be a dedicated worker JavaScript file that will receive the task, run the logic for it, and return an answer. The number of workers is dependent on the number of processors available to the given computer platform. The developer is responsible for identifying the work task and the answer returned.

## Data Use Cases

The number one reason developers write code is to take data in as input, process it, and then spit out that data as output. Going along with this philosophy, these use cases will provide a developer the ability read, write, and process data. The input / output mechanisms will be via files, embedded database, and storage facilities for holding key / value pairs of data.

Given the dynamic nature of data, a series of type checks and string conversions will be provided to the developer. This will support the two data representations within the application.

JSON represents the most versatile data type that works between languages. The developer will have access to work with this data type with encoding / decoding capabilities between the JSON object and string formats. XML represents a legacy format providing a markup of data containing tags, attributes, and values associated with them.

**Use Cases:**

- *Database:* This use case will provide the ability to work with the web browser embedded IndexDB. This will allow for the creation, deletion, storage, querying, and updating of complex data models not serviced by the other more simplified use cases.
- *Data Check:* Given the dynamic nature of data on the web, a series of validity checks are wise. This use case will expose such checks to ensure data received is of a given type, properties exist within JSON objects, and URLs are valid.
- *Disk:* TBD.
- *File:* TBD.
- *JSON:* JavaScript Object Notation (JSON) represents a way of building complex data types and providing a universal way of serializing / deserializing the data as a string or object. JSON has become the goto data type for REST APIs, NoSQL database, and key / value pair storage of data. This use case will expose the functionality to facilitate this format.
- *String Parse:* Strings represent the most common serializable data type. This use case will provide the mechanism for translating strings into appropriate data types.
- *Storage:* This use case is meant to provide a mechanism of storage utilize string key / value pair for accessing information. This in tandem with *JSON* use case provide a quick an easy mechanism for an application to manage data. The web browser provides the storage mechanism of cookies (text files stored in browser cache on user's computer), local (persisted data within the browser), and session (data cleared when the app is closed) storage.
- *XML:* TBD.

## NPU Use Cases

This is a specialized set of use cases representing a software Numerical Processing Unit (NPU). These will be designed in accordance with the [WASM Use Cases](https://webassembly.org/docs/use-cases/) in terms of interface definition and memory management. The use cases associated with this will expose the features available for such processing.

**Use Cases:**

- *Compute:* The NPU will have a strict interface for performing work. The compute use case will perform complicated tasks that are either not mathematical or a more complicated mathematical sequence. All requests made via this use case will utilize the [Memory](#memory) use case to allocate, compute, and then free any results.
- *Math:* Every complicated mathematical concept and formula this use case will address. It will represent a collection of them with the ability to execute them by specifying the formula and passing the arguments for the formula. A failure of said formula will result in `NaN`.
- *Memory:* WASM works with a linear memory model so this use case will do the same constraining its memory to its own circular linear memory model. It will be controlled by only allowing request and results via the [Compute](#compute) use case. By performing this level of control will reduce the potential of memory leaks and the memory is only held by the module.

## SDK Use Cases

A chosen SDK technology provides access to items specific to the runtime. These use cases will expose those elements to the developer. This includes accessing data via hardware peripherals attached / available to a device and network services for communicating via the Internet. Also available will be logging facilities to gage the health of an application. Finally a collection of Runtime services specific to the SDK will also be exposed.

**Use Cases:**

- *Events:* Web applications have the ability to attach to global or individual object event listeners. This use case will facilitate attaching such event listeners for the web application.
- *Logger:* The ability to build and troubleshoot applications comes through a logging facility. This use case will provide such a facility by providing logging levels that log to the SDKs console along with providing the ability for post processing of any logged events. This post processing will allow for building out other logging constructs say to a file or cloud facility.
- *Hardware:* This use case will provide the mechanisms to interface with connected peripherals to read / write data with said devices. These mechanisms will usually communicate with industry standard protocols vs. say a network connected device.
- *Network:* Networking provides the ability for applications to communicate with other applications running on a network / Internet. The most common way of communication is via server hosted REST APIs fetched from a client. From here you also have dedicated bi-directional communications, broadcasting capabilities, and setting up peer-to-peer communications. This use case will focus on these network web based protocols.
- *Orientation:* Onboard mobile sensors or Internet protocols provide the ability for a web app to determine its orientation in three-dimensional space. This use case will provide the ability to subscribe for this orientation data.
- *Runtime:* The web platform provides access to queryable parameters about the host system along with one off function execution. this use case will provide the mechanism to query, search, and execute such functions.
- *Schema:* The web provides the ability to work with different schemas and open associated desktop services with those schemas. This use case will expose the supported web schemas to facilitate these services from an application.
- *Share:* Browsers provide the ability to share content facilitated by the host browser and operating system. This use case will expose this capability allowing the ability to share content from a web app to other hosted services.
- *WebRTC:* TBD

## User Interface Use Cases

The biggest thing all applications need is a way of interacting with a user. These use cases will expose the common mechanisms for interacting with a user to facilitate input / output processing of data.

**Use Cases:**

- *Audio:* This use case will cover two types of audio. The first is the ability play audio files. The second is the ability to perform text-to-speech on loaded textual data.
- *Dialog:* TBD.
- *Gamepad:* TBD.
- *SPA:* The concept of a single page application is you have a main user interface divided into three main sections. The header / footer sections provide widgets for identifying and updating the content section. The content section is the *main* user interface containing widgets to perform a given task. Supporting these sections are drawers. Drawers are hidden away options that slide out on an action either from the left or the right of the user interface. Lastly is the concept of a floating action button. This is an omnipresent control applicable to the entire application regardless of the loaded content section. The main point is, you only have the SPA and update UI elements based on actions.
- *Theming:* This is the action of styling your user interface. This use case will be in two parts. The first is the ability to define a theme for the overall user interface. The secondary is the ability to override the theme of a user interface element while maintaining the overall user interface theme.
- *Widget:* Widgets are the individual user interface controls that make up the interface. Anything from buttons, labels, text fields, etc. allowing the user to interact with your application. The secondary part is the layout of those widgets. This use case provide a standard set of these widgets taking full advantage of the Flutter widget set. It will also not limit the usage of any custom widgets. It simply exposes a standard set.

# USAGE

<center><img style="width: 100%; max-width: 560px;" src="./design-notes/module-architecture.drawio.png" /></center>

The above module reflects how the `codemelted.dart` module communicates with the supporting `codemelted.js` and `codemelted.wasm` files. These are a result of the WASM `codemelted.cpp` compiled target. It provides the support functionality where no direct Flutter implementation exists. So the `codemelted.dart` module imports the module to provide that functionality. The sub-sections below will provide Flutter examples of each of the use case functions.

## Async IO Use Cases

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

### Orientation

<mark>TBD</mark>

### Runtime

<mark>TBD</mark>

### Schema

<mark>TBD</mark>

### Share

<mark>TBD</mark>

### WebRTC

<mark>TBD</mark>

## User Interface Use Cases

### Audio

<mark>TBD</mark>

### Dialog

<mark>TBD</mark>

### Gamepad

<mark>TBD</mark>

### SPA

<mark>TBD</mark>

### Theming

<mark>TBD</mark>

### Widget

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
