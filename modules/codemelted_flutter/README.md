<!--
TITLE: CodeMelted - Flutter Module
PUBLISH_DATE: 2024-04-25
AUTHOR: Mark Shaffer
KEYWORDS: modules, cross-platform, flutter-apps, flutter-library,
DESCRIPTION: Welcome to the CodeMelted - Flutter Module project. This project aims to provide a developer with the ability to build client applications regardless of deployment target. Those deployment targets include desktop, mobile, and web. By leveraging the CodeMelted - Developer identified use cases, you can be assured to building a powerful native application.
-->
<center>
  <a href="../../README.md"><img style="width: 100%; max-width: 375px;" src="https://cdn.codemelted.com/assets/images/logos/logo-developer-smaller.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="header.png" /> CodeMelted - Flutter Module</h1>

Welcome to the **CodeMelted - Flutter Module** project. This project aims to provide a developer with the ability to build client applications regardless of deployment target. Those deployment targets include desktop, mobile, and web. By leveraging the **CodeMelted - Developer** identified use cases, you can be assured to building a powerful native application.

**Table of Contents**

- [GETTING STARTED](#getting-started)
- [USAGE](#usage)
  - [Console](#console)
  - [Logger](#logger)
- [LICENSE](#license)
- [OTHER INFORMATION](#other-information)
  - [Change Log](#change-log)
  - [Coverage](#coverage)

## GETTING STARTED

Perform the following to pull the `codemelted_flutter` module into your project.

```yaml
dependencies:
  codemelted_flutter:
    git:
      url: https://github.com/CodeMelted/codemelted_developer.git
      ref: main
      # Or by tagged version
      # ref: flutter_X.Y.Z
      path: modules/codemelted_flutter
```
Then import it to use it.

```dart
import 'package:codemelted_flutter/codemelted_flutter.dart';
```

## USAGE

The following examples represent the implementation of the **CodeMelted - Developer Cross Platform Module** identified use cases.

### Console

Not applicable to this module.

### Logger

```dart
// First initialize the logger in your main()
CLogger.init();

// Then set a log level you care about.
CLogger.logLevel = CLogger.info;

// Setup post processing of log events if necessary
CLogger.onLoggedEvent = (CLogRecord r) {
  // Handle the log event
};

// Now log events either via logger
CLogger.log(
  level: CLogger.error,
  data: "It blew up",
  st: StackTrace.current,
);

CLogger.log(
  level: CLogger.info,
  data: "It worked",
);

// Or use the utility methods
logError(data: "It blew up", st: StackTrace.current);
logInfo(data: "It Worked");
```

## LICENSE

MIT License

© 2024 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## OTHER INFORMATION

### Change Log

<iframe frameborder="0" height="450" width="100%" src="CHANGELOG.md"></iframe>

### Coverage

<iframe frameborder="0" height="450" width="100%" src="coverage/index.html"></iframe>
