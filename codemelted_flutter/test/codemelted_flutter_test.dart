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

// import 'package:flutter_test/flutter_test.dart';

void main() {
  // group("Async IO Use Case Tests", () {
  //   test("CAsyncTask.background() Validation", () async {
  //     var answer = await CAsyncTask.background(
  //       data: 7,
  //       task: ([data]) {
  //         return data + 5;
  //       },
  //     );
  //     expect(answer.toString().asInt(), 12);
  //   });

  //   test("CAsyncTask.interval() Validation", () async {
  //     var counter = 0;
  //     var timer =
  //         CAsyncTask.interval(task: ([data]) => counter += 1, delay: 250);
  //     await CAsyncTask.sleep(1100);
  //     timer.cancel();
  //     expect(counter >= 4 && counter <= 6, isTrue);
  //   });

  //   test("CAsyncTask.timeout() Validation", () async {
  //     var answer = await CAsyncTask.timeout(
  //       data: 7,
  //       task: ([data]) {
  //         return data + 5;
  //       },
  //     );
  //     expect(answer.toString().asInt(), 12);
  //   });
  // });

  // group("Logger Use Case Tests", () {
  //   CLogger.init();
  //   test("CLogger Demo Some Logging", () {
  //     // Setup our test:
  //     var counter = 0;
  //     CLogger.logLevel = CLogger.warning;
  //     CLogger.onLoggedEvent = (r) => counter += 1;

  //     // Execute test
  //     CLogger.log(level: CLogger.debug, data: "debug");
  //     CLogger.log(level: CLogger.info, data: "info");
  //     CLogger.log(level: CLogger.warning, data: "warning");
  //     CLogger.log(level: CLogger.error, data: "error", st: StackTrace.current);

  //     // Validate results
  //     expect(CLogger.logLevel, equals(CLogger.warning));
  //     expect(counter, equals(2));
  //   });

  //   test("CLogger Demo All Logging", () {
  //     // Setup our test:
  //     var counter = 0;
  //     CLogger.logLevel = CLogger.debug;
  //     CLogger.onLoggedEvent = (r) => counter += 1;

  //     // Execute test
  //     logDebug(data: "debug");
  //     logInfo(data: "info");
  //     logWarning(data: "warning");
  //     logError(data: "error", st: StackTrace.current);

  //     // Validate results
  //     expect(CLogger.logLevel, equals(CLogger.debug));
  //     expect(counter, equals(4));
  //   });

  //   test("CLogger Demo Logging Off", () {
  //     // Setup our test:
  //     var counter = 0;
  //     CLogger.logLevel = CLogger.off;
  //     CLogger.onLoggedEvent = (r) => counter += 1;

  //     // Execute test
  //     logDebug(data: "debug");
  //     logInfo(data: "info");
  //     logWarning(data: "warning");
  //     logError(data: "error", st: StackTrace.current);

  //     // Validate results
  //     expect(CLogger.logLevel, equals(CLogger.off));
  //     expect(counter, equals(0));
  //   });
  // });
}
