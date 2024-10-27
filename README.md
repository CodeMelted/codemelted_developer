<!--
TITLE: CodeMelted | Developer
PUBLISH_DATE: 2024-10-27
AUTHOR: Mark Shaffer
KEYWORDS: raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: Software engineers are now required to learn multiple languages, technologies, and frameworks in order to fully support full stack engineering. This project aims to simplify by developing a set of cross platform modules implementing a similar / identical Application Program Interface (API) regardless of the chosen technology covered by this project. This allows a developer to maximize their productivity because regardless of the technology, they are learning a similar module API for their solution.
-->
<center>
  <img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logos/codemelted-developer-logo.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icons/design.png" /> CodeMelted | Developer</h1>

"Write once, run anywhere (WORA)" was the famous slogan made by Sun Microsystems in 1995.  At the time, this technology allowed for easy full stack engineering allowing you to target dedicated workstations and on premise servers. So long as a Java Runtime Environment existed, you could run your code. Java was unable to keep to their slogan as web browsers became more advanced, mobile devices became ubiquitous, and companies no longer required dedicated servers.

Software engineers are now required to learn multiple languages, technologies, and frameworks in order to fully support full stack engineering. This project aims to simplify this by developing a set of cross platform modules implementing a similar / identical Application Program Interface (API) regardless of the chosen technology covered by this project. This allows a developer to maximize their productivity because regardless of the technology, they are learning a similar module API for their solution.

**Table of Contents**

- [FEATURES](#features)
  - [Baseline Use Cases](#baseline-use-cases)
  - [Future Use Cases](#future-use-cases)
- [GETTING STARTED](#getting-started)
- [USAGE](#usage)
  - [Cross Platform Modules](#cross-platform-modules)
  - [CodeMelted Pi Project](#codemelted-pi-project)
- [LICENSE](#license)

## FEATURES

<center><img style="width: 100%; max-width: 560px;" src="use_cases/assets/module-use-case-model.drawio.png" /></center>

### Baseline Use Cases

- [Async IO](use_cases/async.md): All programming happens synchronously (i.e. one instruction to the next). This occurs within the event loop of the main SDK execution thread. This use case will provide the ability to chunk work within this main event loop along with scheduling work within a background event loop thread.
- [Audio](use_cases/audio.md): Host systems provide the ability to either play audio files or translate a string into text-to-speech. This use case will expose this host processing to the developer.
- [Console](use_cases/console.md): The Console of a system supports STDIN / STDOUT / STDERR. This use case will expose these descriptors to support a developer making simple command line interface tools.
- [Database](use_cases/database.md): Databases provide the ability of storing complex data structures. The two main concepts for this is either relational database structures (SQL) or no-SQL indexed databases. These are available depending on the SDK environment. This use case will expose the ability to access these services for the given SDK.
- [Disk](use_cases/disk.md): Applications have access to hard disk which houses directories, files, and other information. This use case will expose the ability to manage the disk along with interface with said files from the disk.
- [Hardware](use_cases/hardware.md): Systems have the ability to interface with external hardware that connect via different protocols. This use case will expose these different protocols for exchanging information with these connected devices.
- [JSON](use_cases/json.md): JSON (JavaScript Object Notation) is a lightweight data-interchange format. Unlike XML (Extensible Markup Language), it is universal for data transport, manipulation, and representing complex data structures. This use case will expose functions for working / validating this set of datasets.
- [Logger](use_cases/logger.md): Logging is the most basic way of either debugging your application or relaying information to your user base. This use case will provide a logging service for this purpose.
- [Math](use_cases/math.md): All applications will have to exercise mathematical computations. This use case will setup a collection of of these mathematical formulas easily accessible for usage within an application.
- [Memory](use_cases/memory.md): The ability to measure memory usage and monitor your applications usage of memory is very powerful. It allows your application to perform at its peak performance when memory is used efficiently.
- [Network](use_cases/network.md): The Open Systems Interconnection (OSI) model describes seven layers that computer systems use to communicate over a network. It was the first standard model for network communications, adopted by all major computer and telecommunication companies in the early 1980s. Sockets and network protocols provide the means to communicate between client / server applications. This use case will expose these different network protocols to allow for application inter-communication over a network.
- [Runtime](use_cases/runtime.md): The runtime represents specific functionality to a specific language SDK. This use case will provide common properties common to all these SDKs. The use case will also expose functions that are specific to the given SDK.
- [Storage](use_cases/storage.md): The ability to store key / value pairs into storage is a easy simple way to quickly access information for an application. In combination with the Data Broker use case working with JSON data, this use case will provide the developer quick access to this storage concept.
- [User Interface](use_cases/ui.md): A SPA (single-page application) is an app implementation that loads only a single view, and then updates the body content of that single document view. This use case will provide this singular view concept regardless of the underlying UI architecture. It will also provide the ability to properly theme based on the SDK target so an entire app can be changed. Lastly, the use case will identify basic widget types and dialogs to support the SPA.

### Future Use Cases

- [Firebase](use_cases/firebase.md): Firebase is Googles Platform as a Service (PaaS) that exposes a subset of the Google Cloud infrastructure. This use case will wrap the common libraries from auth, writing to the database, calling cloud functions, and other features from the client apps point of view.
- [Game](use_cases/game.md): Game engines provide the logic for running simple side scroller, RPGs, and others. This use case will build a common game engine to apply across different type of apps / game genres. This will facilitate being able to quickly build new games within an application.

## GETTING STARTED

The [Getting Started](use_cases/getting_started.md) documents setup and utilize this repo once clone.

## USAGE

### Cross Platform Modules

The following are the cross platform modules implementing the identified use cases of this project. It provides several choices for your development needs. The following links take you to the specific module implementations for your given domain.


- <img style="width: 25px;" src="https://codemelted.com/assets/images/icons/codemelted-web-icon.png" /> [Web Modules](codemelted_web/README.md): UNDER DEVELOPMENT.
- <img style="width: 25px;" src="https://codemelted.com/assets/images/icons/codemelted-terminal-icon.png" /> [Terminal Modules](codemelted_terminal/README.md): UNDER DEVELOPMENT
- <img style="width: 25px;" src="https://codemelted.com/assets/images/icons/codemelted-iot-icon.png" /> [IoT Module](codemelted_iot/README.md): UNDER DEVELOPMENT.

### CodeMelted Pi Project

- <img style="width: 25px;" src="https://codemelted.com/assets/images/icons/raspberry-pi.png" /> [CodeMelted Pi Project](codemelted_pi/README.md): UNDER DEVELOPMENT.

## LICENSE

MIT License

© 2024 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.