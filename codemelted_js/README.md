<!--
TITLE: CodeMelted - JS Module
PUBLISH_DATE: 2024-10-06
AUTHOR: Mark Shaffer
KEYWORDS: raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: Welcome to the CodeMelted - JS Module project. This project aims to give a common fullstack solution for Progressive Web Applications (PWA) utilizing the CodeMelted - Developer use cases. It utilizes the Deno Runtime to run as your backend service. This was chosen as it has a full range of services for your backend if you choose to utilize it. You can also take your backend and host it on a different platform. This allows you to not be locked into a vendor for your backend. It was also chosen because it implements the Browser Web APIs. This allows the module to implement backend and web frontend common code developing a more complete solution. Lastly, Deno provides the use of TypeScript natively out of the box. So you are able to utilize both JavaScript / TypeScript for your solution and roll with any build system.
-->
<center>
  <a title="Back To Developer Main" href="../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logos/logo-developer-smaller.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icons/deno-js.png" /> CodeMelted - JS Module</h1>

<center><a href="codemelted_test.html">Test Results</a></center>

Welcome to the **CodeMelted - JS Module** project. This project aims to give a common fullstack solution for Progressive Web Applications (PWA) utilizing the **CodeMelted - Developer** use cases. It utilizes the **Deno Runtime** to run as your backend service. This was chosen as it has a full range of services for your backend if you choose to utilize it. You can also take your backend and host it on a different platform. This allows you to not be locked into a vendor for your backend. It was also chosen because it implements the **Browser Web APIs**. This allows the module to implement backend and web frontend common code developing a more complete solution. Lastly, Deno provides the use of TypeScript natively out of the box. So you are able to utilize both JavaScript / TypeScript for your solution and roll with any build system.

## GETTING STARTED

The `codemelted.js` file implements ES6 module with namespace default exports. The namespaces access functions in accordance with the **CodeMelted - Developer** identified use cases. Once the module is imported, the `codemelted` object is available in your target runtime (Deno, Web Browser).

### From GitHub Repo

You can clone the repo:

```bash
git clone https://github.com/CodeMelted/codemelted_developer.git
```

You can download the tagged version [codemelted_js_X.Y.Z](https://github.com/CodeMelted/codemelted_developer/releases) and place it into your project structure.

Then include the module as follows:

**Dynamic Import:**

```javascript
const codemelted = (await import("codemelted_developer/codemelted_js/codemelted.js")).default;
```

**Module Import:**

```javascript
import codemelted from "codemelted_developer/codemelted_js/codemelted.js";
```

**HTML Import:**

```html
<!-- Can be placed in <head> or at the end of<body> -->
<script type="module">
  import codemelted from "codemelted_developer/codemelted_js/codemelted.js";
  // Do what you will do.
</script>
```

### From Web

If you want to be brave and utilize the latest deployed `codemelted.js` module you can simple import it from the web as follows:

**Dynamic Import:**

```javascript
const codemelted = (await import("codemelted_developer/codemelted_js/codemelted.js")).default;
```

**Module Import:**

```javascript
import codemelted from "https://codemelted.com/developer/codemelted_js/codemelted.js";
```

**HTML Import:**

```html
<!-- defer or async will work. Could be placed in <head> or at the end of<body> -->
<script type="module">
  import codemelted from "https://codemelted.com/developer/codemelted_js/codemelted.js";
</script>
```
¬## USAGE

The following examples represent the implementation of the **CodeMelted - Developer Cross Platform Module** identified use cases.

*NOTE: Items marked UNDER DEVELOPMENT are considered unstable. They may have implementations simple not documented as they are being developed. Use at your own risk. Items documented have been through a level of testing and are considered stable enough for usage.*

### Async IO

<mark>UNDER DEVELOPMENT</mark>

### Audio

<mark>UNDER DEVELOPMENT</mark>

### Console

*NOTE: This is only valid on the Deno runtime. Calling this on web target will result in a SyntaxError.*

```javascript
// Alert a message to STDOUT with [Enter] prompt to continue processing.
// Non string message will result in SyntaxError
codemelted.console.alert("Hello");
// Pause processing no message.
codemelted.console.alert();

/// Confirm a choice. True if y and false if N
const answer = codemelted.console.confirm("Are You Sure");
/// With no message specified you get a generic CONFIRM message.
const answer = codemelted.console.confirm();

/// To select a set of choices and get the index of that choice.
const answer = codemelted.console.choose("Which Jeep", ["Jeep 1", "Jeep 2", "Jeep 3"]);
/// With no message specified you get a generic CHOOSE message.
const answer = codemelted.console.choose(["Jeep 1", "Jeep 2", "Jeep 3"]);

// To get someone's password
const password = codemelted.console.password("System Password");
// With no message specified, you get a generic PASSWORD message.
const password = codemelted.console.password();

// To prompt for general user input returned as a string
const answer = codemelted.console.prompt("Who's on First?");
// With no message specified, you get a generic PROMPT: message.
const answer = codemelted.console.prompt();

// To write a general message to STDOUT with no pausing
codemelted.console.writeln("It Worked!");
// With no message specified, you get a new line written to STDOUT.
codemelted.console.writeln();
```

### Database

<mark>UNDER DEVELOPMENT</mark>

### Disk

*NOTE: Only readEntireFile() and writeEntireFile() will work in web runtime.*

```javascript
/// Query for disk properties (Deno only)
const homePath = codemelted.disk.homePath;
const pathSeparator = codemelted.disk.pathSeparator;
const diskPath = codemelted.disk.tempPath;

/// Now lets do some disk work
let success = codemelted.disk.cp("src", "dest");
let fileInfo = codemelted.disk.exists("filename");
let files = codemelted.disk.ls("path");
success = codemelted.disk.mkdir("path");
success = codemelted.disk.mv("src", "dest");
success = codemelted.disk.rm("filename");

// Read and write entire files
// See specific SDK documentation for
// details of items related to web.
await codemelted.disk.writeEntireFile({
  filename: "filename",
  data: "The data",
  append: true,
});
const data = codemelted.disk.readEntireFile({
  filename: "filename",
  isTextFile: true,
});
```

### Firebase

<mark>UNDER DEVELOPMENT</mark>

### Game

<mark>UNDER DEVELOPMENT</mark>

### Hardware

<mark>UNDER DEVELOPMENT</mark>

### JSON

<mark>UNDER DEVELOPMENT</mark>

### Logger

<mark>UNDER DEVELOPMENT</mark>

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
