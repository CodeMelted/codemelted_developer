/*
===============================================================================
MIT License

© 2023 Mark Shaffer. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
===============================================================================
*/

import {
    assert,
    assertThrows,
    assertFalse,
} from "https://deno.land/std@0.192.0/testing/asserts.ts";
import codemelted from "./codemelted.js";

// ----------------------------------------------------------------------------
// [Data Broker Tests] --------------------------------------------------------
// ----------------------------------------------------------------------------

Deno.test("checkType() Validation", async () => {
    // Setup our test data
    const str = "hello";
    const num = 2;
    const success = false;
    const obj = {};

    const handler = function(_a, _b) {};
    const array = [];

    // String validation
    assert(codemelted.checkType("string", str));
    assertFalse(codemelted.checkType("string", num));
    assertFalse(codemelted.checkType("string", success));
    assertFalse(codemelted.checkType("string", obj));
    assertFalse(codemelted.checkType("string", handler));
    assertFalse(codemelted.checkType("string", array));

    let test = await import("./codemelted.js");
    console.log(test);
    assert(test.default.checkType("string", str));
});