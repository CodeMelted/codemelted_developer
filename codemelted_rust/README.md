<!--
TITLE: CodeMelted Rust Crate
PUBLISH_DATE: 2025-May-01
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, pwsh-lib, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, rust, rust-lib
DESCRIPTION: The *CodeMelted Rust Crate* is an implementation of the CodeMelted DEV twelve identified domain use cases. These domains are areas a software engineer should be familiar with regardless of programming language, SDK, or chosen framework. This crate brings these twelve domains to the Rust programming language to aid software engineers in building native applications quickly and securely.
-->
<center>
  <img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-rust.png" /> CodeMelted Rust Crate</h1>

*LAST UPDATED: 2025-May-01*

The *CodeMelted Rust Crate* is an implementation of the [CodeMelted DEV](https://developer.codemelted.com/) twelve identified domain use cases. These domains are areas of study a software engineer should be familiar with regardless of programming language, SDK, or chosen framework. This crate brings these twelve domains to the Rust programming language to aid software engineers in building native applications quickly and securely.

**Table of Contents**

- [GETTING STARTED](#getting-started)
  - [Features](#features)
  - [Usage](#usage)
- [MODULE INFORMATION](#module-information)
  - [Crate Dependencies](#crate-dependencies)
  - [License](#license)
  - [Versioning](#versioning)

# GETTING STARTED

## Features

TODO: Move this to raw domain of https://codemelted.com/developer/design_notes/rust_model_architecture.drawio.png.
![](models/rust_module_architecture.drawio.png)

1. The `codemelted.rs` is a single file implementing the [CodeMelted DEV](https://developer.codemelted.com/design-notes) domain specific use cases.
2. These use cases straddle areas of knowledge software engineers should be familiar with regardless of a given programming language, SDK, or chosen framework.
3. Rust has a module system. Each of the use cases are implemented as a module module as shown in the diagram above.
4. Each module is divided into a "Module Use Statements", "Module Data Definitions", and "Module Function Definitions" if you are viewing the source code.
5. Each module is fully documented, has mermaid diagram introductions, and applicable unit tests.
6. Any module that is currently being developed is marked as such.

## Usage

Once the *codemelted* crate is installed to your project, you can access a module and its supported objects. The following example demonstrates utilizing the `codemelted::codemelted_logger` module.

```rust
// Access the module of interest. In this case the logger module.
use codemelted::codemelted_logger;
use codemelted::codemelted_logger::{CLogLevel, CLogRecord, CLoggedEventHandler};

// Setup a log handler for post logging.
fn log_handler(data: CLogRecord) {
  // Do something, say post to the cloud about the event
}
codemelted_logger::set_log_handler(Some(log_handler));

// Set the log level
codemelted_logger::set_log_level(CLogLevel::Warning);

// Now later on in your code....
// This will be reported to the console and then to the CLoggedEventHandler.
codemelted_logger::log(CLogLevel::Error, "Oh Know!");
```

The above is a basic example. All modules are fully documented with examples as you use the *codemelted* crate.

# MODULE INFORMATION

The following sub-sections cover various aspects the `codemelted.rs` module information. It is a single file implementation of the identified use cases.

## Crate Dependencies

The goal of the `codemelted.rs` is to limit 3rd party items. However, some CodeMelted DEV use cases, thanks to the hard work of the developers who maintain the crates below, would not have been possible.

- *[chrono](https://crates.io/crates/chrono):* Utilized to support the time formatting utilized in the `codemelted_logger` module.
- *[json](https://crates.io/crates/json):* Forms the entire backbone of the `codemelted_json` module. The main `json::JsonValue` is typed alias as `CObject` to match other CodeMelted DEV module implementations.
- *[online](https://crates.io/crates/online):* Utilized with the `codemelted_network` module to determine if an app has access to the Internet or not.
- *[rpassword](https://crates.io/crates/rpassword):* Supports the `codemelted_console` module to allow for getting a user's password from the console without reflecting it to the screen.
- *[simple-mermaid](https://crates.io/crates/simple-mermaid):* Supports the crate documentation for the `codemelted.rs` file to include mermaid models where appropriate to help describe each of the modules.
- *[sysinfo](https://crates.io/crates/sysinfo):* This provides backbone for the monitoring concept of each of the modules along with providing queryable parameters of given information.
- *[url](https://crates.io/crates/url):* Supports the url validation of the `codemelted_json` module.

## License

MIT License

© 2025 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Versioning

The versioning of the module will be captured via GitHub or the modules documentation method. It will utilize semantic versioning `X.Y.Z` with the following rules for the numbering scheme this project.

- **X:** When the 12 identified use cases are fully functional.
- **Y:** Use case implemented, documented, tested, and ready for usage by a developer.
- **Z:** Bug fix or expansion of a use case.

<center>
  <br />
  <a href="https://www.buymeacoffee.com/codemelted" target="_blank">
    <img height="40px" src="https://codemelted.com/assets/images/icon-bmc-button.png" />
  </a>
  <br /><br />
  <p>If you find this module useful, any support is greatly appreciated. Thank you! 🙇</p>
</center>