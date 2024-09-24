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

// import 'package:codemelted_flutter/src/prototype/codemelted_logger.dart';
// import 'package:flutter_test/flutter_test.dart';

// ----------------------------------------------------------------------------
// [Mocks] --------------------------------------------------------------------
// ----------------------------------------------------------------------------

// var count = 0;
// Future<void> onLogEvent(CLogRecord r) async {
//   count += 1;
// }

// ----------------------------------------------------------------------------
// [Execution] ----------------------------------------------------------------
// ----------------------------------------------------------------------------

// void main() {
  // group('codemelted_logger Tests', () {
  //   test('codemelted_logger.level = debug Validation', () async {
  //     codemelted_logger.level = CLogLevel.debug;
  //     codemelted_logger.onLogEvent = onLogEvent;

  //     count = 0;
  //     await codemelted_logger.debug(data: 'debug');
  //     await codemelted_logger.info(data: 'info');
  //     await codemelted_logger.warning(data: 'warning');
  //     await codemelted_logger.error(
  //         data: 'error', stackTrace: StackTrace.current);
  //     expect(count, equals(4));
  //   });

  //   test('codemelted_logger.level = info Validation', () async {
  //     codemelted_logger.level = CLogLevel.info;
  //     codemelted_logger.onLogEvent = onLogEvent;

  //     count = 0;
  //     await codemelted_logger.debug(data: 'debug');
  //     await codemelted_logger.info(data: 'info');
  //     await codemelted_logger.warning(data: 'warning');
  //     await codemelted_logger.error(
  //         data: 'error', stackTrace: StackTrace.current);
  //     expect(count, equals(3));
  //   });

  //   test('codemelted_logger.level = warning Validation', () async {
  //     codemelted_logger.level = CLogLevel.warning;
  //     codemelted_logger.onLogEvent = onLogEvent;

  //     count = 0;
  //     await codemelted_logger.debug(data: 'debug');
  //     await codemelted_logger.info(data: 'info');
  //     await codemelted_logger.warning(data: 'warning');
  //     await codemelted_logger.error(
  //         data: 'error', stackTrace: StackTrace.current);
  //     expect(count, equals(2));
  //   });

  //   test('codemelted_logger.level = error Validation', () async {
  //     codemelted_logger.level = CLogLevel.error;
  //     codemelted_logger.onLogEvent = onLogEvent;

  //     count = 0;
  //     await codemelted_logger.debug(data: 'debug');
  //     await codemelted_logger.info(data: 'info');
  //     await codemelted_logger.warning(data: 'warning');
  //     await codemelted_logger.error(
  //         data: 'error', stackTrace: StackTrace.current);
  //     expect(count, equals(1));
  //   });

  //   test('codemelted_logger.level = off Validation', () async {
  //     codemelted_logger.level = CLogLevel.error;
  //     codemelted_logger.onLogEvent = onLogEvent;

  //     count = 0;
  //     codemelted_logger.debug(data: 'debug');
  //     codemelted_logger.info(data: 'info');
  //     codemelted_logger.warning(data: 'warning');
  //     codemelted_logger.error(data: 'error', stackTrace: StackTrace.current);
  //     expect(count, equals(1));
  //   });
  // });
// }
