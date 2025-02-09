<!--
TITLE: CodeMelted DEV | C++ Module
PUBLISH_DATE: 2025-02-09
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, c-library, cpp-lib
DESCRIPTION: The `codemelted.cpp` is a C++20 module that serves as a swiss army knife of the CodeMelted DEV modules. It has two primary compilation targets. The first is WASM providing the necessary JS and C++ bindings to support Single Page Application (SPA) development in either pure JS or using C++ and compiling the page. The second is as a C++20 module imported into a developer's C++ native application. The public namespaced interface will provide native implementations of the CodeMelted DEV module use cases where appropriate. The final compilation target is as a static library for usage primarily by the `codemelted.ps1` module.
-->
<center>
  <a title="Back To Developer Main" href="../../README.md"><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /></a><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-codemelted-wasm.png" /> CodeMelted DEV | C++ Module</h1>

The `codemelted.cpp` is a C++20 module that serves as a swiss army knife of the CodeMelted DEV modules. It has two primary compilation targets. The first is WASM providing the necessary JS and C++ bindings to support Single Page Application (SPA) development in either pure JS or using C++ and compiling the page. The second is as a C++20 module imported into a developer's C++ native application. The public namespaced interface will provide native implementations of the CodeMelted DEV module use cases where appropriate. The final compilation target is as a static library for usage primarily by the `codemelted.ps1` module.

**LAST UPDATED:** 2025-02-09

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
- [MODULE INFORMATION](#module-information)
  - [License](#license)
  - [Versioning](#versioning)

# GETTING STARTED

TBD

# FEATURES

<center><img style="width: 100%; max-width: 560px;" src="../../design-notes/use-case-model.drawio.png" /></center>

TBD

# USAGE

TBD

# MODULE INFORMATION

The following sub-sections cover various aspects the `codemelted.cpp` module information. It is a single file implementation of the identified use cases.

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
