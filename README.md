<!--
TITLE: CodeMelted DEV | Modules
PUBLISH_DATE: 2025-01-11
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, wasm
DESCRIPTION: Software engineers are now required to learn multiple languages, technologies, and frameworks in order to fully support full stack engineering. This project aims to simplify this by developing a set of modules implementing a similar / identical Application Program Interface (API) regardless of the chosen technology covered by this project. It gives the ability to achieve maximum application reach by supporting the development of Progressive Web Applications (PWAs). The modules are specifically designed to target each area of the technology stack to deliver PWAs.
-->
<center>
  <img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-design.png" /> CodeMelted DEV | Modules</h1>

Software engineers are now required to learn multiple languages, technologies, and frameworks in order to fully support full stack engineering. This project aims to simplify this by developing a set of modules implementing a similar / identical Application Program Interface (API) regardless of the chosen technology covered by this project. It gives the ability to achieve maximum application reach by supporting the development of Progressive Web Applications (PWAs). The modules are specifically designed to target each area of the technology stack to deliver PWAs.

**LAST UPDATED:** 2025-01-11

<center>
  <br />
  <a href="https://www.buymeacoffee.com/codemelted" target="_blank">
    <img height="50px" src="https://codemelted.com/assets/images/icon-bmc-button.png" />
  </a>
  <br /><br />
  <p>Hope you enjoy the content. Any support is greatly appreciated. Thank you! 🙇</p>
</center>

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
    - [Compute](#compute)
    - [Math](#math)
    - [Memory](#memory)
  - [SDK Use Cases](#sdk-use-cases)
    - [Logger](#logger)
    - [Hardware](#hardware)
    - [Monitor](#monitor)
    - [Network](#network)
    - [Runtime](#runtime)
    - [Setup](#setup)
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
  - [Build Script](#build-script)
- [MODULE INFORMATION](#module-information)
  - [License](#license)
  - [Versioning](#versioning)
  - [codemelted.dart Change Log](#codemelteddart-change-log)
  - [codemelted.js Test Results](#codemeltedjs-test-results)
    - [Deno Runtime Coverage](#deno-runtime-coverage)
    - [Browser Mocha Test Runner](#browser-mocha-test-runner)
- [SDK REFERENCES](#sdk-references)
  - [codemelted.dart](#codemelteddart)
  - [codemelted.js](#codemeltedjs)
  - [codemelted.ps1](#codemeltedps1)
  - [codemelted.cpp](#codemeltedcpp)

# FEATURES

<center><img style="width: 100%; max-width: 560px;" src="./design-notes/use-case-model.drawio.png" /></center>

The use case model featured above identifies common developer use cases divided into five major areas of how to architect a PWA. Each of these use cases will be implemented with a similar API across the different across module technology stacks. This will allow developers to easily create solutions to support their PWA.

## Async I/O Use Cases

All programming happens synchronously (i.e. one instruction to the next). This occurs within the event loop of the main SDK execution thread. This use case will provide the ability for chunking up this work asynchronously.

The developer will be able to schedule one off tasks awaiting the result via a promise. They will have the ability to schedule repeating tasks. They will have the ability to communicate with other services via a process. Lastly they will have the ability to queue tasks for processing via a worker pool.

### Process

**Description:** A process is another running program or operating system service that your application can attach to or kick-off. Once running, your application can communicate with it via STDIN to send commands, or STDOUT / STDERR to process output. This is not the most efficient way to chunk up work but allows different applications to communicate. The process use case will facilitate kicking off, communicating, and killing of suck processes.

**Acceptance Criteria:**

1. The process use case will provide the ability to spawn a process and communicate with the process via STDIN, STDOUT, and STDERROR.
2. The process use case will provide the ability to kill any running process specifying a signo for the reason of the termination. *NOTE: While you can specify any running PID, your process may not have appropriate rights to terminate another running process. Only processes kicked off via the use case.*

### Task

**Description:** Computer code executes synchronously requiring one instruction to complete before another can begin. However you may need a task to run or repeat interrupting this synchronous flow of execution. The task use case will provide an ability to schedule tasks within the event loop of an application thereby breaking up work asynchronously allowing for other processing to occur.

*NOTE: Depending on SDK, asynchronous tasks will be run in the main, background, or both event loop threads of the runtime.*

**Acceptance Criteria:**

1. The task use case will provide the ability to run an asynchronous task and return an answer sometime in the future.
2. The task use case will provide the ability to start and stop a repeating interval task on a given millisecond boundary.
3. The task use case will provide the ability to sleep an asynchronous task in milliseconds.

### Worker

**Description:** The worker use case will be a dedicated set of background threaded First In First Out (FIFO) event looped threads executing the same processing logic. The processing logic will be a dedicated worker JavaScript module that will receive the task, run the logic for it, and return an answer. The number of workers is dependent on the number of processors available to the given computer platform.

**Acceptance Criteria:**

1. The worker use case will provide for the ability to start a pool of workers based on a dedicated JavaScript worker module. The pool will be equal to the available processors to the module.
2. The worker use case will provide the ability to post tasks for work and receive the results of that processed work via a FIFO queuing mechanism. *NOTE: The developer will have the power to identify what that work is as the task queuing is an JSON object.*
3. The worker use case will provide the ability to terminate the pool of workers.
4. The worker use case will provide the ability to intercept any errors that occur with a started worker pool.

## Data Use Cases

The number one reason developers write code is to take data in as input, process it, and then spit that data as output. Going along with this philosophy, these use cases will provide a developer the ability read, write, and process data. The input / output mechanisms will be via files, embedded database, and storage facilities for holding key / value pairs of data.

Given the dynamic nature of data, a series of type checks will be provided to the developer. Lastly JSON represents the most versatile data type that works between languages. The developer will have access to work with this data type with encoding / decoding capabilities between the JSON object and string formats.

### Database

**Database:** Unlike the other identified in the *Data Use Cases* that allow for storage of data in different manners and require a little more know how / wrapper logic for more complicated data, the *Database* use case will provide a use case to work with embedded database for more complicated data types and queries. The use case will work with the technology available to the SDK. So for PWA modules, this would be an IndexDB database. For the terminal module, this will be a SQLite embedded database.

**Acceptance Criteria:**

1. The database use case will provide the ability to manage the database structure. This includes creating, deleting, and updating data model structures.
2. The database use case will provide the ability to manage data via insert, delete, and update constructs.
3. The database use case will provide the ability to query for select data within the database.

### Disk

**Description:** When running a backend service or terminal task, you may need to manipulate items on disk. This includes files and directories. This use case will create a *disk* use case that attaches these management items along with queryable properties such as a user's home directory as an example.

**Acceptance Criteria:**

1. The disk use case will provide the ability to copy files / directories from one location to another.
2. The disk use case will determine if a given file / path exists on a disk.
3. The disk use case will provide the ability to determine the user's home directory.
4. The disk use case will provide the ability to get a listing of files from disk.
5. The disk use case will provide the ability to create a directory (including parent directories) on disk.
6. The disk use case will provide the ability to move a file / directory from one location to another on disk.
7. The disk use case will determine the path separator character for the given operating system. Backslash for windows, forward slash for all unix variants.
8. The disk use case will provide the ability to remove a filename / directory from disk.
9. The disk use case will provide the ability to determine the temporary directory path on disk.

### File

**Description:** Files allow for a complete user control of reading and writing information. The primary format for data is either binary or textual. This use case will facilitate the ability to create, append, read, and write to such files.

**Acceptance Criteria:**

1. The file use case will provide the ability read an entire file into memory whether binary or textual.
2. The file use case will provide the ability to write an entire file to disk whether memory binary or textual.
3. The file use case will provide the ability to read a file in chunks whether binary or textual. These chunks can be in sequence or random access.
4. The file use case will provide the ability to write a file in chunks whether binary or textual. These chunks can be appended or replace the entire file on disk.
5. The file use case will provide the ability for a user to select where to open or save a file. *NOTE: This is dictated to the runtime SDK being utilized.*

### JSON

**Description:** JavaScript Object Notation (JSON) represents a way of building complex data types and providing a universal way of serializing / deserializing the data as a string or object. JSON has become the goto data type for REST APIs, NoSQL database, and key / value pair storage of data. This use case will expose a use case and utility objects to fully take advantage of this data object notation.

**Acceptance Criteria:**

1. The json use case will support the conversion of string types to valid JSON constructs if they are of that type. These include array, boolean, number, and object types. Failure to convert will result in a `null` return.
2. The json use case will provide the ability to parse and stringify valid JSON constructs. Failure to parse or stringify the data will result in a `null` return.
3. The json use case will provide the ability to perform validity checks. These validity checks include determining if a JSON object has a given property, if a particular data type is of an expected type, and valid URLs. These checks can will return either a boolean of the check or throw exceptions.
4. The json use case will provide the ability to create JSON array / object types that work within the given SDK JSON datatype.

### Storage

**Description:** This use case is meant to provide a mechanism of storage utilize string key / value pair for accessing information. This in tandem with *JSON* use case provide a quick an easy mechanism for an application to manage data. With the *PWA Modules* this is facilitated with runtime APIs while with the *Terminal Module* a mechanism will be built out that mirrors the acceptance criteria.

**Acceptance Criteria:**

1. The storage use case will provide the ability to clear all data from the storage mechanism.
2. The storage use case will provide the ability to get an item via a specified key. Items not found will be returned as null.
3. The storage use case will identified how many items exist within the storage mechanism.
4. The storage use case will provide a mechanism for listing / retrieving the keys utilized within the storage mechanism.
5. The storage use case will provide an ability to remove a single item via the specified key.
6. The storage use case will provide the ability to set an items within the storage mechanism. If the item already exists, it is updated.

## NPU Use Cases

This is a specialized set of use cases representing a software Numerical Processing Unit (NPU). These will be designed in accordance with the [WASM Use Cases](https://webassembly.org/docs/use-cases/) in terms of interface definition and memory management. It will be a simplified interface that consumers of the NPU will need to write to. Meaning the use cases identified below are specific to how the NPU will handle items but consuming modules using it will also write interfaces to these use cases but expose friendlier interfaces.

### Compute

**Description:** The NPU will have a strict interface for performing work. The compute use case will perform complicated tasks that are not mathematical. To allow this will require the utilization of the [Memory](#memory) use case to first allocate a request. Once allocated, then requesting the computation of said request. Finally access the memory that contains the result. Only the supported request will be executed.

**Acceptance Criteria:**

1. The compute use case will execute only known allocated requests. It will signal success / failure of said request and deallocate the memory of the request.
2. The result of a completed computation will be available via the [Memory](#memory) use case.

### Math

**Description:** Every complicated mathematical concept and formula this use case will address. It will represent a collection of them with the ability to execute them by specifying the formula and passing the arguments for the formula. A failure of said formula will result in `NaN`.

**Acceptance Criteria:**

1. The math use case will execute a specified mathematical formula returning the result based on the passed arguments.
2. Any failure to calculate the mathematical formula will result in `NaN` return.

### Memory

**Description:** WASM works with a linear memory model so this use case will do the same constraining its memory to its own circular linear memory model. It will be controlled by only allowing request and results via the [Compute](#compute) use case. By performing this level of control will reduce the potential of memory leaks and the memory is only held by the module. This memory is only for this modules available requests and results of the computed requests.

**Acceptance Criteria:**

1. The memory use case will allocate memory when creating a request for the [Compute](#compute) use case.
2. The memory use case will allocate memory the [Compute](#compute) use case completes the computation of a request. *NOTE: The previously allocated request is free'd and returned back to memory.*
3. The memory use case will provide the ability to free the result of completed [Compute](#compute) use case once the data has been utilized in further processing.
4. The memory use case will return `null` when a failure to allocate memory occurs. *NOTE: Being a circular linear memory buffer, once at the end of a buffer, the allocation of memory will move back to the beginning of the linear memory. The size of the memory is based on the request / results of the compute use case.*
5. The memory use case will statistics of the memory as follows:
    - Size of the memory
    - Available memory
    - Allocated memory

## SDK Use Cases

A chosen SDK technology provides access to items specific to the runtime. This use case will expose those elements to the developer. This includes accessing data via hardware peripherals attached / available to a device and network services for communicating via the Internet. Also available will be logging facilities to gage the health of an application. Finally a collection of Runtime services specific to the SDK will also be exposed.

### Logger

**Description:** The ability to build and troubleshoot applications comes through a logging facility. This use case will provide such a facility by providing logging levels that log to the SDKs console along with providing the ability for post processing any logged events. This post processing will allow for building out other logging constructs say to a file or cloud facility.

**Acceptance Criteria:**

1. The logger use case will provide four logging levels of DEBUG, INFO, WARNING, and ERROR.
2. The logger use case will provide the ability to set the logging level. Meaning any log event below that level will not be processed.
3. The logger use case will provide a post processing capability of any logged event.
4. The logger use case will provide the ability to be turned off.

### Hardware

**Description:** The hardware use case will provide the mechanisms to interface with onboard sensors or connected peripherals to read / write data with said devices. These mechanisms will usually communicate with industry standard protocols vs. say a network connected device.

*NOTE: What a module provides as hardware is dependent on the runtime target. See the individual module implementations for details.*

**Acceptance Criteria:**

1. The hardware use case will provide the ability to know an applications location via WGS84 GPS nomenclature when location services / GPS hardware is available.
2. The hardware use case will provide the ability to know an application orientation in 3D space when appropriate sensors are available.
3. The hardware use case will provide the ability to read / write with peripherals attached via a serial (RS232) interface.
4. The hardware use case will provide the ability to read / write with peripherals attached via a bluetooth interface.
5. The hardware use case will provide the ability to read / write with peripherals attached via a MIDI interface.

### Monitor

**Description:** Knowing how your application is performing within a given SDK environment is key to fleshing out the optimal performance. This use case will provide the ability to querying and capture such information. The main targets will be CPU utilization, memory usage, and network analysis.

**Acceptance Criteria:**

1. The monitor use case will provide the ability to query / monitor CPU utilization of the overall platform and if possible, individual processes.
2. The monitor use case will provide the ability to query memory utilization of the overall platform and if possible individual processes.
3. The monitor use case will provide the ability to trace and monitor a platforms network stack.

### Network

**Description:** Networking provides the ability for applications to communicate with other applications running on a network / Internet. The most common way of communication is via server hosted REST APIs fetched from a client. From here you also have dedicated bi-directional communications, broadcasting capabilities, and setting up peer-to-peer communications. This use case will focus on these network protocols focused highly on Web based protocols.

*NOTE: Web based protocols mean protocols typically associated with the World Wide Web and web applications. Other networking protocols exist but since the this project's modules focus on PWAs, the protocols covered will be Internet WWW specific.*

**Acceptance Criteria:**

1. The network use case will provide a beacon capability allowing for performing a simple post to a server.
2. The network use case will provide a fetch capability allowing for performing REST API GET, PUT, POST, and DELETE actions with a server.
3. The network use case will provide the ability to determine if a public facing Internet connection is available to an application.
4. The network use case will provide the ability to hostname of the host platform.
5. The network use case will facilitate client / server based protocol connections reporting the state of those connections, providing the ability to read / write data, and eventually terminate the connection. The facilitated protocols are as follows:
    - *Broadcast Channels:* allows basic communication between browsing contexts (that is, windows, tabs, frames, or iframes) and workers on the same origin.
    - *Server Sent Events:* allows for a client to connect to a server and receive status from that server. This is one way communication. Think a firehose from the server to the client.
    - *Web Sockets*: makes it possible to open a two-way interactive communication session between the user's browser and a server. With this API, you can send messages to a server and receive responses without having to poll the server for a reply.
    - *WebRTC:* enables Web applications and sites to capture and optionally stream audio and/or video media, as well as to exchange arbitrary data between browsers without requiring an intermediary. The set of standards that comprise WebRTC makes it possible to share data and perform teleconferencing peer-to-peer, without requiring that the user install plug-ins or any other third-party software.

### Runtime

**Description:** Each individual SDK environment provides the ability to interact with the host platform. It also opens up items that are specific to the SDK environment. This use case will focus on providing the common items necessary each of the modules and exposing SDK specific items that are called out specifically in each module's generated SDK documentation.

**Acceptance Criteria:**

1. The runtime use case will provide the ability to load third-party libraries.
2. The runtime use case will provide the ability to query for platform environment settings.
3. The runtime use case will provide access to the specifics of the SDK runtime environment. *NOTE: This allows for utilizing other aspects of the SDK not covered by the modules.*
4. The runtime use case will provide a set of queryable properties that help identify capabilities of the SDK runtime and host platform.

### Setup

**Description:**  Each module implementation for this project has specific bindings / setups that occur within a given SDK. This use case simple identifies that fact. See the individual module [SDK documentation](#module-design) for the *GETTING STARTED* section for the specific setup identified implementations.

**Acceptance Criteria:** N/A

## User Interface Use Cases

The biggest thing all applications have is a way of interacting with a user. This use case will expose a common way for either building a Command Line Interface (CLI) prompting the user for input or building a complex Single Page App (SPA) interface. This will allow for a consistent experience of communicating with an application user.

*NOTE: This covers the ability to build applications with a dedicated user interface. Other APIs currently not covered but might be for the future include Gamepad, Virtual Reality, and graphics 2D/3D processing.*

### Audio

**Description:** This use case will cover two types of audio. The first is the ability play audio files. The second is tha ability to perform text-to-speech on loaded textual data.

**Acceptance Criteria:**

1. The audio use case will provide the ability to load a audio file or textual data for text-to-speech.
2. Once loaded, the audio use case will provide the ability play, pause, loop, and stop the given data. Stopping will provide the ability to play from the beginning.
3. The audio use case will provide the ability to control the pitch, rate, volume of the loaded media.
4. The audio use case will provide the ability to attach receive status of the loaded audio transaction. This includes any errors that may be encountered.

### Console

**Description:** A STDIN / STDOUT interaction is the barest bone user interface that one can present to a user. Unlike a Command Line Interface (CLI) where a user must know the different flags to invoke the interface, a STDIN / STDOUT interaction provides a continuous set of prompts and messages guiding the user. This is commonly referred to as a System Console. This use case will provide a console interface to facilitate such actions.

**Acceptance Criteria:**

1. The console use case will provide the ability to alert a user with a custom message that requires the *Enter* key press to continue processing.
2. The console use case will provide the ability for a Yes/No confirmation to a user where *Y* will return *true* and anything else will return *false*.
3. The console use case will provide the ability to choose from a set of options returning the index of the user selection. An invalid selection will result in attempting the choice again.
4. The console use case will provide the ability to enter a *password* concealing their entry via STDIN. The result returned will be a string.
5. The console use case will provide the ability to answer prompted questions. The result returned will be a string.
6. The console use case will provide the ability to write a line of text with newline to STDOUT.

### Dialog

**Description:** The ability to alert / interact with your user to events occurring in your application is key to any user interface. This use case will identify the different events for providing this ability to application user's of an application.

**Acceptance Criteria:**

1. The dialog use case will provide an ability to display an about page for an application.
2. The dialog use case will provide an ability to alerting event for the user when something occurs within the application.
3. The dialog use case will provide an ability for a confirmation event before proceeding with an action within the application.
4. The dialog use case will provide an ability for a choice event before proceeding with an action within the application.
5. The dialog use case will provide an ability for a loading event before proceeding with an action within the application.
6. The dialog use case will provide an ability for a prompting event before proceeding with an action within the application.
7. The dialog use case will provide an ability to load a full custom page form before proceeding with an action within the application.

### SPA

**Description:** The concept of a single page application is you have a main user interface divided into three main sections. The header / footer sections provide widgets for identifying and updating the content section. The content section is the *main* user interface containing widgets to perform a given task. Supporting these sections are drawers. Drawers are hidden away options that slide out on an action either from the left or the right of the user interface. Lastly is the concept of a floating action button. This is an omnipresent control applicable to the entire application regardless of the loaded content section. The main point is, you only have the SPA and update UI elements based on actions.

**Acceptance Criteria:**

1. The spa use case will provide the ability to define a user interface into header, content, footer, drawer, end drawer, and floating action sections.
2. The spa use case will only allow for one spa definition.
3. The spa use case will allow for defining other properties about the application to include, title, themes, queryable properties, and attaching to specific user interface events applicable to the overall spa and not an individual widget.

### Theming

**Description:** This is the action of styling your user interface. This use case will be in two parts. The first is the ability to define a theme for the overall user interface. The secondary is the ability to override the theme of a user interface element while maintaining the overall user interface theme.

**Acceptance Criteria:**

1. The theming use case will provide the ability to define an overall user interface spa theme.
2. The theming use case will provide the ability to override the theme of an individual element while maintaining the overall user interface spa theme.

### Widget

**Description:** Widgets are the individual user interface controls that make up the interface. Anything from buttons, labels, text fields, etc. allowing the user to interact with your application. The secondary part is the layout of those widgets. This use case provides those different widgets representing a standard set. These are highly specific to each SDK so see the [SDK documentation](#module-design) for details.

**Acceptance Criteria:** N/A

## Module Design

<center><img style="width: 100%; max-width: 560px;" src="./design-notes/module-architecture.drawio.png" /></center>

**Module Links**

- [PWA Modules](./pwa/README.md)
- [Terminal Module](./terminal/README.md)
- [NPU Module](./npu/README.md)

### PWA Modules

The call signature for these modules will be via a `codemelted` module signature of `codemelted.[function]()` with named parameters for the given function. Queryable items will be attached to the appropriate `codemelted` object as properties.

#### Flutter

The `codemelted.dart` module, which is the main root of this repo,provides a Flutter specific implementations of the identified use cases delivering the full power of Flutter to construct PWAs. Use cases with no direct Flutter binding will utilize the `codemelted.js` module providing a Flutter interface for that module's implementation. This allows for not duplicating code across module implementations.

#### JavaScript

The `codemelted.js` is a ES6 module that can operate in both a Web Browser and Deno runtime environments. It implements all the identified use cases for the different environments to provide the ability to deliver SPA/PWA solutions or support Dev Ops facilities using Deno. This is the heart of the *PWA Modules* as the `codemelted.dart` is not necessary to code a full web solution.

### Terminal Module

The `codemelted.ps1` script will provide a Command Line Interface (CLI) utility to facilitate common developer use cases on Mac, Linux, or Windows systems. When installed, the CLI will provide the `codemelted` command that can be accessed in a pwsh terminal or in `ps1` scripts that facilitate a set of automated tasks. A developer may also build a Terminal User Interface (TUI) for a text based user interface.

The call signature for the CLI will be as follows

```
codemelted [Action] [Params]
```

*WHERE*

- `[Action]`: A flag `--function-name` function that corresponds to one of the identified use cases.
- `[Params]`: A PowerShell hash table `@{}` that will setup named parameters and values associated with the selected `[Command]`.

*NOTE: This module will also provide a CLI interface for Raspberry Pi built services. See the module SDK documentation for details.*

### NPU Module

A `codemelted.cpp` C++ 20 module that will support the *WASM Module* use cases for its interface definition. It will be compiled as a `*.wasm` module to support the [PWA Modules](#pwa-modules) and as a static library to support the [Terminal Module](#terminal-module) on the different operating systems.

*NOTE: A developer can also just utilize this module within a C++ application if they so choose utilizing the C++ 20 module standard.*



# MODULE INFORMATION

The following sub-sections cover various aspects the `codemelted.dart` module information.It is a single file implementation of the identified use cases.

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
