/*
===============================================================================
MIT License

© 2024 Mark Shaffer. All Rights Reserved.

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

import 'package:codemelted_developer/codemelted.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // This is called once after ALL tests
  setUpAll(() async {
    var success = await codemelted.init(npuModuleUrl: "codemelted.wasm");
    expect(success, isTrue);
  });

  // This is called once before EVERY test
  setUp(() {});

  // This is called once after ALL tests
  tearDownAll(() {});

  // This is called once after EVERY test
  tearDown(() {});

  group("codemelted.math Tests", () {
    test("Temperature Conversion Validation", () {
      var answer = codemelted.math.calculate(
        formula: Formula_t.temperature_celsius_to_fahrenheit,
        arg1: 0.0,
      );
      expect(answer, moreOrLessEquals(32.0));
    });
  });
}
