<!--
TITLE: CodeMelted DEV | PWA Modules
PUBLISH_DATE: 2024-12-28
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: The CodeMelted DEV | PWA modules is comprised of three powerful modules for a developer to fully take advantage of what the web browser as a runtime has to offer. The `codemelted.js` module is the heart of these modules. It offers both backend processing via the Deno Runtime along with access to Web Browser APIs when constructing html SPAs. The `codemelted.dart` module brings the power of Flutter to the web with its rich widget toolset leveraging a professional polish and feel without needing HTML or CSS. Last is the `codemelted.wasm` module. This offers a Numeric Processing Unit (NPU) for number crunching large data sets.
-->
<center>
  <a title="Back To Developer Main" href="../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-codemelted-web.png" /> CodeMelted DEV | PWA Modules</h1>

The CodeMelted DEV | PWA modules is comprised of three powerful modules for a developer to fully take advantage of what the web browser as a runtime has to offer. The `codemelted.js` module is the heart of these modules. It offers both backend processing via the Deno Runtime along with access to Web Browser APIs when constructing html SPAs. The `codemelted.dart` module brings the power of Flutter to the web with its rich widget toolset leveraging a professional polish and feel without needing HTML or CSS. Last is the `codemelted.wasm` module. This offers a Numeric Processing Unit (NPU) for number crunching large data sets.

**LAST UPDATED:** 2024-12-28

**Table of Contents**

- [GETTING STARTED](#getting-started)
  - [codemelted.dart Module](#codemelteddart-module)
  - [codemelted.js Module](#codemeltedjs-module)
    - [From GitHub Repo](#from-github-repo)
    - [From Web](#from-web)
- [USAGE](#usage)
  - [codemelted.dart Module](#codemelteddart-module-1)
    - [console Namespace](#console-namespace)
    - [disk Namespace](#disk-namespace)
    - [json Namespace](#json-namespace)
  - [codemelted.js Module](#codemeltedjs-module-1)
    - [console Namespace](#console-namespace-1)
    - [disk Namespace](#disk-namespace-1)
    - [json Namespace](#json-namespace-1)
- [Test Results](#test-results)
  - [Deno Runtime Coverage](#deno-runtime-coverage)
  - [Browser Mocha Test Runner](#browser-mocha-test-runner)
- [LICENSE](#license)

# GETTING STARTED

## codemelted.dart Module

Add the following item to your `pubspec.yaml` file to pull the repo into your Flutter web project.

```yaml
dependencies:
  codemelted_developer:
    git:
      url: https://github.com/CodeMelted/codemelted_developer.git
      ref: main # branch or tag as codemelted.dart_X.Y.Z
```

Once added, when you deploy, the `codemelted.js` and `codemelted.wasm` modules are available to your flutter web app via the `codemelted.dart` module but you can also directly access them in your own JavaScript files via:

- `assets/packages/codemelted_developer/pwa/codemelted.js`
- `assets/packages/codemelted_developer/npu/codemelted.wasm`

*NOTE: This is how your flutter web app deploys where assets is the root directory of your domain deployment. As*

## codemelted.js Module

The `codemelted.js` module implements ES6 module with namespace default exports. The namespaces access functions in accordance with the CodeMelted DEV module use cases. Once the module is imported, the `codemelted` object is available in your target runtime (Deno, Web Browser).

### From GitHub Repo

You can clone the repo:

```bash
git clone https://github.com/CodeMelted/codemelted_developer.git
```

You can download the tagged version [codemelted.js_X.Y.Z](https://github.com/CodeMelted/codemelted_developer/releases) and place it into your project structure.

Then include the module as follows:

**Dynamic Import:**

```javascript
const codemelted = (await import("codemelted_developer/pwa/codemelted.js")).default;
```

**Module Import:**

```javascript
import codemelted from "codemelted_developer/pwa/codemelted.js";
```

**HTML Import:**

```html
<!-- Can be placed in <head> or at the end of<body> -->
<script type="module">
  import codemelted from "codemelted_developer/pwa/codemelted.js";
  // Do what you will do.
</script>
```

### From Web

If you want to be brave and utilize the latest deployed `codemelted.js` module you can simple import it from the web as follows:

**Dynamic Import:**

```javascript
const codemelted = (await import("https://codemelted.com/developer/pwa/codemelted.js")).default;
```

**Module Import:**

```javascript
import codemelted from "https://codemelted.com/developer/pwa/codemelted.js";
```

**HTML Import:**

```html
<!-- defer or async will work. Could be placed in <head> or at the end of<body> -->
<script type="module">
  import codemelted from "https://codemelted.com/developer/pwa/codemelted.js";
</script>
```

# USAGE

Both the `codemelted.dart` and `codemelted.js` modules use named parameters for all namespaced functions. The following are the examples. The key differences between Dart / JavaScript is as follows:

```dart
// No {} in the function call.
codemelted.namespace.function(
  param1: "something",
  param2: true
);
```

```javascript
// {} required as the "named" part is an object literal.
codemelted.namespace.function({
  param1: "something",
  param2: true
});
```
## codemelted.dart Module

The following are examples when building a Flutter web app utilizing the `codemelted.dart` module.

### console Namespace

Not applicable to this module.

### disk Namespace

- <mark>TODO: readEntireFile / writeEntireFile are applicable. Need to integrate into the module</mark>

### json Namespace

- The `typedef CArray` along with the `extension CArrayExtension` provides the different `CArray` methods along with a `ChangeNotifier` to alert when data changes occur via the `notifyAll()`.
- The `typedef CObject` along with the `extension CObjectExtension` provides the different `CObject` methods for type checking along with a `ChangeNotifier` to alert when data changes occur via the `notifyAll()`.
- The `CStringExtension` provides all the `asXXX()` methods for converting to other JSON data types or returning `null` during conversion failure. It also contains some comparison methods.
- The `CJsonAPI` which provides the namespace has wrappers for the above along with the validity methods for validating `dynamic` data.

## codemelted.js Module

The following are examples when building browser / deno script files utilizing the `codemelted.dart` module.

### console Namespace

```js
// Provides just a [Enter] prompt
codemelted.console.alert();
// With custom message
codemelted.console.alert({message: "Thing Happened"});

// Provides just a CONFIRM [y/N] prompt
let continue = codemelted.console.confirm();
// With custom message
let continue = codemelted.console.confirm({message: "Are you sure"});

// Provide a choice selection
// ------
// CHOOSE
// ------
//
// 0. Jeep
// 1. Dodge
// 2. Car
//
// Make a Selection [0 - 2]:
let choice = codemelted.console.choose({
  choices: ["Jeep", "Dodge", "Car"]
});
// With custom message
let choice = codemelted.console.choose({
  message: "The Best Car Is",
  choices: ["Jeep", "Dodge", "Car"]
});

// Prompt for a password
let password = codemelted.console.password();
// With custom message
let password = codemelted.console.password({message: "Enter Password"});

// Prompt for an answer
let answer = codemelted.console.prompt();
// With custom message
let answer = codemelted.console.prompt({message: "Answer to Life:"});

// Write a blank line
codemelted.console.writeln();
// Write a line of text
codemelted.console.writeln({message: "Yo"});
```

### disk Namespace

```javascript
// Queryable properties
let homePath = codemelted.disk.homePath;
let pathSeparator = codemelted.disk.pathSeparator;
let tempPath = codemelted.disk.tempPath;

// Management of the system disk.
let success = codemelted.disk.cp({
  src: "source path or file",
  dest: "dest path or file",
});

let success = codemelted.disk.exists({
  filename: "file or directory",
});

let files = codemelted.disk.ls({
  filename: "directory to list or singular file"
});

let success = codemelted.disk.mkdir({
  filename: "directory to create"
});

let success = codemelted.disk.mv({
  src: "source path or file",
  dest: "dest path or file",
});

let success = codemelted.disk.rm({
  filename: "directory or file",
});

// Read / Write Entire files
let data = await codemelted.disk.readEntireFile({
  filename: `${tempPath}/results/writeTextFile.txt`
});
await codemelted.disk.writeEntireFile({
  filename: `${tempPath}/results/writeFile.txt`,
  data: new Uint8Array([42]),
});
```

### json Namespace

```javascript
// Convert string to other types of data
let isTrue = codemelted.json.asBool({data: "yes"});
let aNumber = codemelted.json.asDouble({data: "42.2"});
// Will truncate if a double
let aNumber = codemelted.json.asInt({data: "42"});

// Validating JSON data types
// Use the tryXXXX equivalents to throw exceptions on invalid data.
let success = codemelted.json.checkHasProperty({
  obj: testObj,
  key: "field6",
});
let success = codemelted.json.checkType({
  type: "function",
  data: (a, b) => {},
  count: 2,
});
let success = codemelted.json.checkValidUrl({
  data: "https://codemelted.com"
});

// Create JSON appropriate arrays and objects
// Exclude the data parameter to get an empty object.
let data = codemelted.json.createArray({
  data: ["1", 2, true, null]
});
let data = codemelted.json.createObject({
  data: {
    field1: "field1",
    field2: 2,
    field3: true,
    field4: ["1", 2, true, null]
    field5: {}
    field6: null,
  }
});

// Stringify and parse to transmit / receive JSON data
let stringified = codemelted.json.stringify({
  data: {
    field1: "field1",
  }
});
let obj = codemelted.json.parse({data: stringified});
```

<mark>TBD</mark>

# Test Results

## Deno Runtime Coverage

<iframe src="coverage/index.html" width="100%" height="350px"></iframe>

## Browser Mocha Test Runner

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
