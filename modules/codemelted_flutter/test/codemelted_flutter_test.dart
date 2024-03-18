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

import 'package:flutter_test/flutter_test.dart';
import 'package:codemelted_flutter/codemelted_flutter.dart';

void main() {
  group("CAsyncIO Tests", () {
    test("CAsyncIO.background() Validation", () async {
      var answer = await CAsyncIO.background(
        data: 7,
        task: ([data]) {
          return data + 5;
        },
      );
      expect(answer.toString().asInt(), 12);
    });

    test("CAsyncIO.interval() Validation", () async {
      var counter = 0;
      var timer = CAsyncIO.interval(task: ([data]) => counter += 1, delay: 250);
      await CAsyncIO.sleep(1100);
      timer.terminate();
      expect(counter >= 4 && counter <= 6, isTrue);
    });

    test("CAsyncIO.timeout() Validation", () async {
      var answer = await CAsyncIO.timeout(
        data: 7,
        task: ([data]) {
          return data + 5;
        },
      );
      expect(answer.toString().asInt(), 12);
    });

    test("CAsyncIO.worker() Validation", () async {
      var answer = 0;
      var error = "";
      var worker = await CAsyncIO.worker(
        task: ([data]) {
          if (data is int) {
            return data + 5;
          }
          throw "unexpected type";
        },
        onReceived: ([data]) {
          if (data is int) {
            answer += data;
          } else {
            error = data;
          }
        },
      );
      worker.postMessage(7);
      await CAsyncIO.sleep(1000);
      expect(answer, 12);
      expect(error.isNotEmpty, isFalse);
      worker.postMessage(12);
      await CAsyncIO.sleep(1000);
      expect(answer, 29);
      expect(error.isNotEmpty, isFalse);
      worker.postMessage("hello");
      await CAsyncIO.sleep(1000);
      expect(error.isNotEmpty, isTrue);
    });
  });

  group("CLogger Tests", () {
    CLogger.init();
    test("CLogger Demo Some Logging", () {
      // Setup our test:
      var counter = 0;
      CLogger.logLevel = CLogger.warning;
      CLogger.onLoggedEvent = (r) => counter += 1;

      // Execute test
      CLogger.log(level: CLogger.debug, data: "debug");
      CLogger.log(level: CLogger.info, data: "info");
      CLogger.log(level: CLogger.warning, data: "warning");
      CLogger.log(level: CLogger.error, data: "error", st: StackTrace.current);

      // Validate results
      expect(CLogger.logLevel, equals(CLogger.warning));
      expect(counter, equals(2));
    });

    test("CLogger Demo All Logging", () {
      // Setup our test:
      var counter = 0;
      CLogger.logLevel = CLogger.debug;
      CLogger.onLoggedEvent = (r) => counter += 1;

      // Execute test
      CLogger.log(level: CLogger.debug, data: "debug");
      CLogger.log(level: CLogger.info, data: "info");
      CLogger.log(level: CLogger.warning, data: "warning");
      CLogger.log(level: CLogger.error, data: "error", st: StackTrace.current);

      // Validate results
      expect(CLogger.logLevel, equals(CLogger.debug));
      expect(counter, equals(4));
    });

    test("CLogger Demo Logging Off", () {
      // Setup our test:
      var counter = 0;
      CLogger.logLevel = CLogger.off;
      CLogger.onLoggedEvent = (r) => counter += 1;

      // Execute test
      CLogger.log(level: CLogger.debug, data: "debug");
      CLogger.log(level: CLogger.info, data: "info");
      CLogger.log(level: CLogger.warning, data: "warning");
      CLogger.log(level: CLogger.error, data: "error", st: StackTrace.current);

      // Validate results
      expect(CLogger.logLevel, equals(CLogger.off));
      expect(counter, equals(0));
    });
  });
}
