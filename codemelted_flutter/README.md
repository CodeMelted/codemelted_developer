<!--
TITLE: CodeMelted - Flutter Module
PUBLISH_DATE: 2024-08-05
AUTHOR: Mark Shaffer
KEYWORDS: raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module
DESCRIPTION: Welcome to the CodeMelted - Flutter Module project. This project aims to provide a developer with the ability to build client applications regardless of deployment target. Those deployment targets include desktop, mobile, and web. By leveraging the CodeMelted - Developer identified use cases, you can be assured to building a powerful native application.
-->
<center>
  <a href="../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logos/logo-developer-smaller.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="header.png" /> CodeMelted - Flutter Module</h1>

Welcome to the **CodeMelted - Flutter Module** project. This project aims to provide a developer with the ability to build client applications regardless of deployment target. Those deployment targets include desktop, mobile, and web. By leveraging the **CodeMelted - Developer** identified use cases, you can be assured to building a powerful native application.

**Table of Contents**

- [GETTING STARTED](#getting-started)
- [USAGE](#usage)
  - [Async](#async)
  - [Audio](#audio)
  - [Console](#console)
  - [Database](#database)
  - [Disk](#disk)
  - [Firebase](#firebase)
  - [Game](#game)
  - [Hardware](#hardware)
  - [JSON](#json)
  - [Logger](#logger)
  - [Math](#math)
  - [Network](#network)
  - [Runtime](#runtime)
  - [Storage](#storage)
  - [UI](#ui)
- [LICENSE](#license)

## GETTING STARTED

Perform the following to pull the `codemelted_flutter` module into your project.

```yaml
dependencies:
  codemelted_flutter:
    git:
      url: https://github.com/CodeMelted/codemelted_developer.git
      ref: main
      # Or by tagged version
      # ref: codemelted_flutter_X.Y.Z
      path: codemelted_flutter
```

## USAGE

The following examples represent the implementation of the **CodeMelted - Developer Cross Platform Module** identified use cases.

### Async

<mark>UNDER DEVELOPMENT</mark>

### Audio

<mark>UNDER DEVELOPMENT</mark>

### Console

<mark>UNDER DEVELOPMENT</mark>

### Database

Not applicable to this module.

### Disk

<mark>UNDER DEVELOPMENT</mark>

### Firebase

<mark>UNDER DEVELOPMENT</mark>

### Game

<mark>UNDER DEVELOPMENT</mark>

### Hardware

<mark>UNDER DEVELOPMENT</mark>

### JSON

<mark>UNDER DEVELOPMENT</mark>

### Logger

```dart
// Import it.
import 'package:codemelted_flutter/codemelted_logger.dart';

// Set it up
codemelted_logger.level = CLogLevel.warning;
codemelted_logger.onLogEvent = (rec) async {
  // Handle the CLogRecord object.
};

// Log stuff
codemelted_logger.debug(data: 'debug', stackTrace: StackTrace.current);
codemelted_logger.info(data: 'info', stackTrace: StackTrace.current);
codemelted_logger.warning(data: 'warning', stackTrace: StackTrace.current);
codemelted_logger.error(data: 'error', stackTrace: StackTrace.current);
```

### Math

<mark>UNDER DEVELOPMENT</mark>

### Network

<mark>UNDER DEVELOPMENT</mark>

### Runtime

<mark>UNDER DEVELOPMENT</mark>

### Storage

<mark>UNDER DEVELOPMENT</mark>

### UI

<mark>UNDER DEVELOPMENT</mark>

## LICENSE

MIT License

© 2024 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
