<!--
TITLE: CodeMelted Rust Crate
PUBLISH_DATE: 2025-May-31
AUTHOR: Mark Shaffer
KEYWORDS: CodeMeltedDEV, raspberry-pi, modules, cross-platform, gps, html-css-javascript, flutter-apps, pwsh, pwsh-lib, js-module, flutter-library, deno-module, pwsh-scripts, pwsh-module, rust, rust-lib
DESCRIPTION: The *CodeMelted Rust Crate* is an implementation of the CodeMelted DEV 14 identified domain use cases. These domains are areas a software engineer should be familiar with regardless of programming language, SDK, or chosen framework. This crate brings those use cases to the Rust programming language to aid software engineers in building native applications quickly and securely.
-->
<center>
  <br /><img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-rust.png" /> CodeMelted Rust Crate</h1>

*LAST UPDATED: 2025-May-31*

The *CodeMelted Rust Crate* is an implementation of the [CodeMelted DEV](https://codemelted.com/developer/codemelted_dev/index.html) 14 identified domain use cases. These domains are areas of study a software engineer should be familiar with regardless of programming language, SDK, or chosen framework. This crate brings those use cases to the Rust programming language to aid software engineers in building native applications quickly and securely.

**Table of Contents**

- [GETTING STARTED](#getting-started)
  - [Features](#features)
  - [Usage](#usage)
  - [Asynchronous Processing Notes](#asynchronous-processing-notes)
- [MODULE INFORMATION](#module-information)
  - [Crate Dependencies](#crate-dependencies)
  - [License](#license)

# GETTING STARTED

## Features

<center><img src="https://codemelted.com/developer/codemelted_dev/models/all/use-case-model.drawio.png" /></center>

1. The `codemelted.rs` is a single file implementing the [CodeMelted DEV](https://codemelted.com/developer/codemelted_dev/index.html) domain specific use cases.
2. These use cases straddle areas of knowledge software engineers should be familiar with regardless of a given programming language, SDK, or chosen framework.
3. Each of the use cases are implemented as a series of `uc_xxx` functions reflecting the use case diagram above.
4. The `codemelted.rs` is organized by each implemented use case with data definitions first and function implementations after.
5. Each use case function is fully documented to include example code and mermaid diagrams.
6. Any use case function that is currently being developed is marked as such.

## Usage

You can access the use case functions via the `codemelted::uc_xxx()`. The following example demonstrates utilizing the `codemelted` module.

```rust
// Access the module objects of interest. In this case the logger module objects.
use codemelted::{CLogLevel, CLogRecord, CLoggedEventHandler};

// Setup a log handler for post logging.
fn log_handler(data: CLogRecord) {
  // Do something, say post to the cloud about the event
}
codemelted::logger_set_log_handler(Some(log_handler));

// Set the log level
codemelted::logger_set_log_level(CLogLevel::Warning);

// Now later on in your code....
// This will be reported to the console and then to the CLoggedEventHandler.
codemelted::logger_log(CLogLevel::Error, "Oh Know!");
```

The above is a basic example. All modules are fully documented with examples as you use the *codemelted* crate.

## Asynchronous Processing Notes

1. The `codemelted` crate does not utilize `async` / `await` / `future` syntax.
2. Code is synchronous in the `codemelted` module allowing the software engineer to choose an appropriate thread model.
3. For asynchronous crates utilized by the `codemelted` module, they are transformed into synchronous APIs via the `tokio::Runtime`.
4. For items requiring threading within the `codemelted` crate, they provide a synchronous API and implement the minimum threading necessary to achieve the module API goal.

# MODULE INFORMATION

The following sub-sections cover various aspects the `codemelted.rs` module information. It is a single file implementation of the identified use cases.

## Crate Dependencies

The goal of the `codemelted.rs` is to limit 3rd party items. However, some CodeMelted DEV use cases, thanks to the hard work of the developers who maintain the crates below, would not have been possible.

- *<a href="https://crates.io/crates/btleplug" target="_blank">btleplug:</a>* Supports the *HW Domain Use Case* providing the necessary interface to Bluetooth devices.
- *<a href="https://crates.io/crates/chrono" target="_blank">chrono:</a>* Utilized to support the time formatting utilized in the *Logger Domain Use Case*.
- *<a href="https://crates.io/crates/json" target="_blank">json:</a>* Forms the entire backbone of the *Json Domain Use Case*. The main `json::JsonValue` is typed alias as `CObject` to match other CodeMelted DEV module implementations.
- *<a href="https://crates.io/crates/online" target="_blank">online:</a>* Utilized with the *Runtime Domain Use Case* to determine if an app has access to the Internet or not.
- *<a href="https://crates.io/crates/reqwest" target="_blank">reqwest:</a>* Supports the *Network Domain Use Case* fetch call forming the basis for both the request and response to a server REST API call.
- *<a href="https://crates.io/crates/rouille" target="_blank">rouille:</a>* Supports the `network_serve` and `network_upgrade_web_socket` calls of the *Network Domain Use Case* forming the basis to upgrade a HTTP request wanting to upgrade to a bi-directional web socket. This will create a `CWebSocketProtocol` that represents a bi-directional server socket. *FYI: The following  warning occurs with this crate. Will keep an eye out on updates with this crate, see if an assist can be made to the owner, or look for a new crate to utilize with the completed `codemelted.rs` module design.*
  > warning: the following packages contain code that will be rejected by a future version of Rust: buf_redux v0.8.4, multipart v0.18.0
  > note: to see what the problems were, use the option `--future-incompat-report`, or run `cargo report future-incompatibilities --id 1`
- *<a href="https://crates.io/crates/rpassword" target="_blank">rpassword:</a>* Supports the *Console Domain Use Case* to allow for getting a user's password from the console without reflecting it to the screen.
- *<a href="https://crates.io/crates/rusqlite" target="_blank">rusqlite:</a>* Supports the *DB Domain Use Case* providing the ability to have an embedded sqlite database. The crate takes care of "installing" the items necessary to build the sqlite database file.
- *<a href="https://crates.io/crates/simple-mermaid" target="_blank">simple-mermaid:</a>* Supports the crate documentation for the `codemelted.rs` file to include mermaid models where appropriate to help describe each of the modules.
- *<a href="https://crates.io/crates/serialport" target="_blank">serialport:</a>* Supports the *HW Domain Use Case* providing the necessary interface to Serial ports.
- *<a href="https://crates.io/crates/sysinfo" target="_blank">sysinfo:</a>* This provides backbone for the *Monitor Domain Use Case* objects that support monitoring different aspects of a host operating system..
- *<a href="https://crates.io/crates/tokio" target="_blank">tokio:</a>* Utilized to allow for the consumption of asynchronous crates and turn them into the `codemelted` crate synchronous design.
- *<a href="https://crates.io/crates/url" target="_blank">url:</a>* Supports url validation as part of the *JSON Domain Use Case*.

## Crate Versioning

The versioning of the `codemelted` crate will utilize a modified semantic versioning `X.Y.Z` with the following rules for the numbering scheme.

- **X:** Year of release. Each new year resets the `Y.Z` values to `1`
- **Y:** Breaking change to one of the use case functions or upgrade of dependencies requiring considerations within an app. A change in this value resets `.Z` to `1`.
- **Z:** Bug fix, new use case function implemented, or expansion of a use case function. Continuously updated by adding one with each new release unless reset by `X.Y` changes.

## License

MIT License

© 2025 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

<center>
  <br />
  <a href="https://www.buymeacoffee.com/codemelted" target="_blank">
    <img height="40px" src="https://codemelted.com/assets/images/icon-bmc-button.png" />
  </a>
  <br /><br />
  <p>If you find this module useful, any support is greatly appreciated. Thank you! 🙇</p>
</center>