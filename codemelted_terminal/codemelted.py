#!/usr/bin/env python
# -----------------------------------------------------------------------------
# CodeMelted | Terminal Module Specification] ---------------------------------
# -----------------------------------------------------------------------------
"""
<style>
  .codemelted-dev-nav {
    display: grid;
    grid-template-columns: auto auto auto auto;
    width: 100%;
    max-width: 375px;
    border: none;
    border-top: 5px solid black;
    border-bottom: 5px solid black;
    margin: 0;
    padding: 0;
  }
  .codemelted-dev-nav a {
    padding: 5px;
    text-decoration: none;
    cursor: pointer;
  }
  .codemelted-dev-nav a:hover {
    background-color: maroon;
  }
  .codemelted-dev-nav img {
    height: 50px;
  }
</style>
<center>
<img width="100%;"
 src="https://codemelted.com/assets/images/logos/codemelted-developer-logo.png"
/>
<div class="codemelted-dev-nav">
  <a title="Web Module" href="https://codemelted.com/developer/codemelted_web">
    <img src="https://codemelted.com/assets/images/icons/codemelted-web-icon.png" />
  </a>
  <a title="Terminal Module" href="https://codemelted.com/developer/codemelted_terminal">
    <img src="https://codemelted.com/assets/images/icons/codemelted-terminal-icon.png" />
  </a>
  <a title="IoT Module" href="https://codemelted.com/developer/codemelted_iot">
    <img src="https://codemelted.com/assets/images/icons/codemelted-iot-icon.png" />
  </a>
  <a title="CodeMelted Pi Project" href="https://codemelted.com/developer/codemelted_pi">
    <img src="https://codemelted.com/assets/images/icons/raspberry-pi.png" />
  </a>
</div>
</center>
# CodeMelted | Terminal Module

```mermaid
---
title: CodeMelted | Terminal Module
config:
  layout: dagre
  look: handDrawn
  theme: forest
---
flowchart LR
    subgraph os["Operating System"]
        direction LR
        linux@{ shape: subproc, label: "Linux OS" }
        mac@{ shape: subproc, label: "Mac OS" }
        win@{ shape: subproc, label: "Windows OS" }
        note1@{ shape: "braces", label: "something" }
    end
    subgraph python["Native Terminal"]
        direction LR
        codemelted.cmd -- calls --> codemelted.py
        codemelted -- calls --> codemelted.py
        note2@{ shape: "braces", label: "something" }
    end
    subgraph pwsh["pwsh Terminal"]
        direction LR
        codemelted.ps1
        note3@{ shape: "braces", label: "something" }
    end
    os --executes--> pwsh
    os --executes--> python
```
<mark>UNDER DEVELOPMENT</mark>

## GETTING STARTED

<mark>UNDER DEVELOPMENT</mark>

## USAGE

<mark>UNDER DEVELOPMENT</mark>

## LICENSE

MIT License

© 2024 Mark Shaffer

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

**`codemelted.py` API DOCUMENTATION BELOW**
"""

# -----------------------------------------------------------------------------
# [Use Case Implementation] ---------------------------------------------------
# -----------------------------------------------------------------------------

def codemelted_async_task(something: str) -> None:
    """
    Executes an asynchronous task in a background thread returning with
    the expected result.
    """
    pass

# -----------------------------------------------------------------------------
# [CLI IMPLEMENTATION] --------------------------------------------------------
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    print(codemelted_async_task.__doc__)