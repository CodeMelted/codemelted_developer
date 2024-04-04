<!--
TITLE: TITLE
PUBLISH_DATE: dd mmm yyyy
AUTHOR:
KEYWORDS:
DESCRIPTION:
-->
<h1><img style="height: 35px;" src="header.png" /> CodeMelted - Flutter Module</h1>

Welcome to the **CodeMelted - Flutter Module** project. This project aims to provide a developer with the ability to build client applications regardless of deployment target. Those deployment targets include desktop, mobile, and web. By targeting the identified use cases in the [FEATURES](#features) section, you will be able to build and scale your applications quickly.

**Table of Contents**

- [FEATURES](#features)
  - [Async IO](#async-io)
  - [Audio Player](#audio-player)
  - [Console](#console)
  - [Data Broker](#data-broker)
  - [Logger](#logger)
- [GETTING STARTED](#getting-started)
  - [Include in Flutter Project](#include-in-flutter-project)
  - [Module Versioning](#module-versioning)
- [USAGE](#usage)
- [TEST COVERAGE](#test-coverage)
- [LICENSE](#license)

## FEATURES

<center><img style="width: 100%; max-width: 800px;" src="https://cdn.codemelted.com/developer/design/use-case-model.drawio.png" /></center>

The model above depicts the most common use cases for the modern web enabled era that applications will most likely interface. The use cases that apply will be built into this module. The use cases will be specific to the Flutter SDK and utilize its strengths. No one off items will be built with this project and the module will aim to target as many deployment platforms as possible.

### Async IO

Asynchronous processing is the ability to carve up work so that other processing can occur while your task is in flight. In flutter you can carve this work up either on the main thread or in the background. As such, a utility object will be built that provides this asynchronous processing capabilities.

### Audio Player

Applications now a days need the ability to perform audio playback or text to speech. This use case exposes the SDK facilities to perform such operations in a common manner taking care of the harder setup.

### Console

Not applicable to this module as it is a UI based framework for desktop, mobile, and web applications.

### Data Broker

These days you have the ability to work with dynamic data. This means the type is not known and can be anything. This use case will build a series extensions and functions that provide conversions, type checking, and serialization / deserialization of JSON data. JSON data is the data of the web.

### Logger

Logging provides the ability to diagnosis issues with your application. A simple logger will be built into the module that provides this capability along with post processing if you so choose. Post processing can include saving to file or reporting to a backend server.

## GETTING STARTED

### Include in Flutter Project

TBD

### Module Versioning

```
X.Y.Z (dd mmm yyyy):
^ All module use cases are implemented
  ^ An individual use case becomes available
    ^ Use case fixes / tweaks
```

As this module is developed, it will be versioned as identified above. A use case is considered available when a sufficient portion of its functionality is developed, tested, and documented. This will reset the `.Z` for any fixes made to existing available module use cases. `v1.0.0` is attained once all the [FEATURES](#features) use cases applicable to the module are completed.

## USAGE

TBD

## TEST COVERAGE

<center>
<iframe style="width: 100%; height: 460px;" frameborder="0" src="coverage/index.html"></iframe>
</center>

## LICENSE

MIT License

© 2024 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.