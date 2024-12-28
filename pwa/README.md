<!--
TITLE: CodeMelted DEV | PWA Modules
PUBLISH_DATE: 2024-12-14
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: TBD
-->
<center>
  <a title="Back To Developer Main" href="../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-codemelted-web.png" /> CodeMelted DEV | PWA Modules</h1>

**LAST UPDATED:** 2024-12-14

<mark>TBD</mark>

**Table of Contents**

- [GETTING STARTED](#getting-started)
- [USAGE](#usage)
  - [codemelted.json Namespace](#codemeltedjson-namespace)
    - [Flutter](#flutter)
    - [JavaScript](#javascript)
- [LICENSE](#license)

# GETTING STARTED

<mark>TBD</mark>

# USAGE

Both the `codemelted.dart` and `codemelted.js` modules use named parameters for all namespaced functions. The following are the examples.

**Flutter Named Parameters Example:**

```dart
var obj = {};
var hasProperty = codemelted.json.checkHasProperty(obj: ogj, key: "fieldName");
```

**JavaScript Named Parameters Example:**

```javascript
// TBD
```

## codemelted.json Namespace

### Flutter

- The `typedef CArray` along with the `extension CArrayExtension` provides the different `CArray` methods along with a `ChangeNotifier` to alert when data changes occur via the `notifyAll()`.
- The `typedef CObject` along with the `extension CObjectExtension` provides the different `CObject` methods for type checking along with a `ChangeNotifier` to alert when data changes occur via the `notifyAll()`.
- The `CStringExtension` provides all the `asXXX()` methods for converting to other JSON data types or returning `null` during conversion failure. It also contains some comparison methods.
- The `CJsonAPI` which provides the namespace has wrappers for the above along with the validity methods for validating `dynamic` data.

### JavaScript

<mark>TBD</mark>

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
