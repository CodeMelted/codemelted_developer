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

import 'package:codemelted_web/codemelted.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:web/web.dart' as web;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // This is called once after ALL tests
  setUpAll(() async {
    var result = await codemelted_js.loadScript("/codemelted.js");
    expect(result.is_ok, isTrue);
    expect(result.is_error, isFalse);
    expect(codemelted_js.module, isNotNull);
  });

  // This is called once before EVERY test
  setUp(() {});

  // This is called once after ALL tests
  tearDownAll(() {});

  // This is called once after EVERY test
  tearDown(() {});

  // ==========================================================================
  // [codemelted.js BINDING] ==================================================
  // ==========================================================================

  group("codemelted_js Validation", () {
    test("codemelted_js.npu_math Test", () {
      expect(codemelted_js.npu_math(formula: MATH_FORMULA.TemperatureCelsiusToFahrenheit, args: [0.0]), equals(32.0));
    });

    test("codemelted_js.runtime_cpu_count() Test", () {
      expect(codemelted_js.runtime_cpu_count(), greaterThanOrEqualTo(1));
    });

    test("codemelted_js.runtime_environment() Test", () {
      expect(codemelted_js.runtime_environment("username"), isNull);
    });

    test("codemelted_js.runtime_event Test", () {
      try {
        void listener(web.Event e) { }
        codemelted_js.runtime_event(action: "add", type: "DOMContentLoaded", listener: listener);
        codemelted_js.runtime_event(action: "remove", type: "DOMContentLoaded", listener: listener);
      } catch (err) {
        fail("Should not throw");
      }
    });

    test("codemelted_js.runtime_hostname() Test", () {
      expect(codemelted_js.runtime_hostname(), equals("localhost"));
    });

    test("codemelted_js.runtime_name() Test", () {
      expect(codemelted_js.runtime_name(), equals("chrome"));
    });

    test("codemelted_js.runtime_online() Test", () {
      expect(codemelted_js.runtime_online(), isTrue);
    });
  });

  // --------------------------------------------------------------------------
  // [JSON Use Case] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  group("Async Use Case Tests", () {
    test("asyncSleep Validation", () async {
      var start = DateTime.now();
      await asyncSleep(1000);
      var delay =
          DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      expect(delay, greaterThanOrEqualTo(950));
    });

    test("asyncTask Validation", () async {
      // A good result.
      var result = await asyncTask<int>(
        task: ([data]) async {
          return data + 5;
        },
        data: 37,
      );
      expect(result.is_ok, isTrue);
      expect(result.is_error, isFalse);
      expect(result.value, equals(42));

      // An error case
      result = await asyncTask<int>(
        task: ([data]) {
          return data + 5;
        },
        data: "a",
      );
      expect(result.is_ok, isFalse);
      expect(result.is_error, isTrue);
      expect(result.value, isNull);
    });

    test("asyncTimer Validation", () async {
      var count = 0;
      var timer = asyncTimer(
        task: () {
          count += 1;
        },
        interval: 250,
      );
      expect(timer.isRunning, isTrue);
      await asyncSleep(1100);
      timer.stop();
      expect(count, greaterThanOrEqualTo(4));
      expect(timer.isRunning, isFalse);
    });
  });

  group("JSON Use Case Tests", () {
    test("CArray Validation", () {
      var listenerCount = 0;
      onDataChanged() => listenerCount += 1;

      var array = jsonCreateArray();
      array.addListener(listener: onDataChanged);
      expect(array.isEmpty, isTrue);

      // Fire listener
      array.add(2);
      array.notifyAll();
      expect(array.isNotEmpty, isTrue);
      expect(listenerCount, equals(1));

      // Don't fire listener
      array.insert(0, "hello");
      expect(array.length, equals(2));
      expect(listenerCount, equals(1));

      // Now validate index works as expected.
      array.insert(1, true);
      array.notifyAll();
      expect(array.length, equals(3));
      expect(listenerCount, equals(2));
      expect(array[1], isTrue);
      expect(array[2], equals(2));
      expect(array[0], equals("hello"));

      // Make a copy and prove it is a copy
      var arrayCopy = array.copy();
      arrayCopy.add("another string");
      expect(array.length != arrayCopy.length, isTrue);

      var stringified = arrayCopy.stringify();
      expect(stringified!.contains("another"), isTrue);

      // Now validate the parse clears the data of the original array
      // and load the copies data as if it were serialized data read from
      // storage to be used.
      var success = array.parse(data: stringified);
      expect(success, isTrue);
    });

    test("CObject Validation", () {
      var listenerCount = 0;
      onDataChanged() => listenerCount += 1;

      var obj = jsonCreateObject();
      obj.addListener(listener: onDataChanged);
      expect(obj.isEmpty, isTrue);

      obj.set<String>(key: "test", value: "test", notify: true);
      expect(listenerCount, equals(1));
      expect(obj.isNotEmpty, isTrue);
      expect(obj.get<String>(key: "test"), equals("test"));

      obj.set<bool?>(key: "is_good", value: null);
      expect(obj.get<bool?>(key: "is_good"), isNull);
      expect(listenerCount, equals(1));

      obj.set<CArray>(key: "anArray", value: [1, true, "three"], notify: true);
      expect(listenerCount, equals(2));
      expect(obj.get<CArray>(key: "anArray").length, equals(3));

      var copy = obj.copy();
      copy.set<int>(key: "newKey", value: 2);
      expect(listenerCount, equals(2));
      expect(copy.entries.length != obj.entries.length, isTrue);

      var stringified = obj.stringify();
      expect(stringified, isNotNull);

      var success = obj.parse(initData: stringified!);
      expect(success, isTrue);
    });

    test("jsonParse Validation", () {
      // bool parsing
      expect(jsonParse<bool>("42"), isFalse);
      expect(jsonParse<bool>("1"), isTrue);
      expect(jsonParse<bool>("yes"), isTrue);
      expect(jsonParse<bool>("no"), isFalse);

      // double validation
      expect(jsonParse<double>("a"), isNull);
      expect(jsonParse<double>("42.2"), isNotNull);
      expect(jsonParse<double>("42"), isNotNull);

      // int validation
      expect(jsonParse<int>("a"), isNull);
      expect(jsonParse<int>("42.2"), isNull);
      expect(jsonParse<int>("42"), isNotNull);
    });

    test("jsonHasKey Validation", () {
      var obj = jsonCreateObject({
        "one": 1,
        "two": "two",
        "three": null,
      });

      expect(jsonHasKey(obj: obj, key: "one"), isTrue);
      expect(jsonHasKey(obj: obj, key: "4"), isFalse);
      try {
        jsonHasKey(obj: obj, key: "4", shouldThrow: true);
        fail("should throw exception");
      } catch (ex) {
        expect(ex, isA<String>());
      }
    });

    test("jsonCheckType Validation", () {
      expect(jsonCheckType<String>(data: 42), isFalse);
      expect(jsonCheckType<String>(data: "42"), isTrue);
      try {
        jsonCheckType<String>(data: 42, shouldThrow: true);
        fail("should throw exception");
      } catch (ex) {
        expect(ex, isA<String>());
      }
    });

    test("jsonValidUrl Validation", () {
      expect(jsonValidUrl(url: "https://codemelted.com"), isTrue);
      expect(jsonValidUrl(url: "j;,ht:/b;l42"), isFalse);
      try {
        jsonValidUrl(url: "j;,ht:/b;l42", shouldThrow: true);
        fail("should throw exception");
      } catch (ex) {
        expect(ex, isA<String>());
      }
    });
  });
}
