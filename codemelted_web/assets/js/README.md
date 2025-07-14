<center>
  <img style="width: 100%; max-width: 375px;" src="https://codemelted.com/assets/images/logo-codemelted-developer.png" /><br />
</center>
<h1><img style="height: 35px;" src="https://codemelted.com/assets/images/icon-js.png" /> codemelted.js Module</h1>

The `codemelted.js` module will be an ES6 module that supports its usage within Deno / NodeJS V8 runtimes for backend services along with Web browsers to support regular HTML / CSS / JS Single Page Application (SPA) development. The module will make heavy usage of JSDoc typing to ensure it works with available TypeScript type checkers within a software engineers chosen development platform. Finally this module serves as the main support to the `codemelted.dart` module serving as its backend where Flutter specific logic does not exist as to not duplicate code.

TODO: Explain module approach for working in multiple runtimes.

*BY: Mark Shaffer / LAST UPDATED: 2025-Jul-05*

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
  - [Features](#features)
    - [Breakdown](#breakdown)
    - [Runtime Support](#runtime-support)
  - [Usage](#usage)
- [MODULE INFORMATION](#module-information)
  - [Versioning](#versioning)
  - [License](#license)

# GETTING STARTED

## Features

<center><img src="https://codemelted.com/developer/codemelted_dev/models/all/use-case-model.drawio.png" /></center>

The use case model above is a breakdown of <a href="https://codemelted.com/developer/" target="_self">CodeMelted DEV</a> domain specific use cases. It forms a swiss army knife of use case functions allowing software engineers to quickly solve common domain problems. This module can be used in multiple runtimes and frameworks without hindering its operations. It utilizes `jsdoc` syntax to support `TypeScript` type checkers. The sub-sections below further describes the module.

### Breakdown

1. The `codemelted.js` module is a ES6 module that supports the Browser, Deno, NodeJS, and Worker runtimes.
2. The `codemelted.js` module is organized as a singular file separating the use case implementations in sections separated by `//===` comment blocks
3. Each section is organized first with data elements then the functions themselves with each area organized alphabetically.
4. Each documented function will identify inputs, outputs, an example, and a general `@throws` that explains the module error cases representing module API violations.
5. The <a href="./test_browser.html" target="_self">codemelted.js Module | Test Results</a> represents the different testing mechanisms to validate the module.

### Runtime Support

The table below identifies what use case functions are supported in which JavaScript runtimes. Calling a function in a non-supported runtime will result in a thrown `SyntaxError`.

| Function                   |  B  |  D  |  N  |  W  |
| -------------------------- | --- | --- | --- | --- |
| async_sleep                |  X  |  X  |     |  X  |
| async_task                 |  X  |  X  |     |  X  |
| async_timer                |  X  |  X  |     |  X  |
| console_alert              |     |  X  |     |     |
| console_choose             |     |  X  |     |     |
| console_confirm            |     |  X  |     |     |
| console_password           |     |  X  |     |     |
| console_prompt             |     |  X  |     |     |
| console_writeln            |     |  X  |     |     |
| hw_open_device_orientation |  X  |     |     |     |
| hw_serial_ports_supported  |  X  |  X  |  X  |  X  |
| json_check_type            |  X  |  X  |  X  |  X  |
| json_has_key               |  X  |  X  |  X  |  X  |
| json_parse                 |  X  |  X  |  X  |  X  |
| json_stringify             |  X  |  X  |  X  |  X  |
| json_valid_url             |  X  |  X  |  X  |  X  |
| logger_handler             |  X  |  X  |  X  |  X  |
| logger_level               |  X  |  X  |  X  |  X  |
| logger_log                 |  X  |  X  |  X  |  X  |
| npu_math                   |  X  |  X  |  X  |  X  |
| runtime_cpu_arc            |     |  X  |  X  |     |
| runtime_cpu_count          |  X  |  X  |  X  |  X  |
| runtime_environment        |  X  |  X  |  X  |     |
| runtime_event_listener     |  X  |  X  |  X  |  X  |
| runtime_home_path          |     |  X  |  X  |     |
| runtime_hostname           |  X  |  X  |     |     |
| runtime_is_browser         |  X  |  X  |  X  |  X  |
| runtime_is_deno            |  X  |  X  |  X  |  X  |
| runtime_is_nodejs          |  X  |  X  |  X  |  X  |
| runtime_is_worker          |  X  |  X  |  X  |  X  |
| runtime_name               |  X  |  X  |  X  |  X  |
| runtime_newline            |     |  X  |  X  |     |
| runtime_online             |  X  |     |     |     |
| runtime_os_name            |     |  X  |     |     |
| runtime_path_separator     |     |  X  |  X  |     |
| runtime_temp_path          |     |  X  |  X  |     |
| runtime_user               |     |  X  |  X  |     |
| storage_clear              |  X  |  X  |     |     |
| storage_get                |  X  |  X  |     |     |
| storage_length             |  X  |  X  |     |     |
| storage_remove             |  X  |  X  |     |     |
| storage_set                |  X  |  X  |     |     |
| ui_height                  |  X  |     |     |     |
| ui_is_pwa                  |  X  |     |     |     |
| ui_open                    |  X  |     |     |     |
| ui_print                   |  X  |     |     |     |
| ui_share                   |  X  |     |     |     |
| ui_touch_enabled           |  X  |     |     |     |
| ui_width                   |  X  |     |     |     |

## Usage

<mark>TBD - IN DEVELOPMENT</mark>

# MODULE INFORMATION

The following sub-sections cover various aspects the `codemelted.js` module information. It is a single file implementation of the identified use cases.

## Versioning

The versioning of the `codemelted.js` module will utilize a modified semantic versioning `X.Y.Z` with the following rules for the numbering scheme.

- `X`: Year of release. Each new year resets the `Y.Z` values to 1
- `Y`: Breaking change to one of the use case functions or upgrade of dependencies requiring considerations within an app. A change in this value resets `.Z` to `1`.
- `Z`: Bug fix, new use case function implemented, or expansion of a use case function. Continuously updated by adding one with each new release unless reset by `X.Y` changes.

## License

MIT License

© 2025 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
