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
    var result = await codemelted.loadScript("/codemelted.js");
    expect(result.is_ok, isTrue);
    expect(result.is_error, isFalse);
    expect(codemelted.module, isNotNull);
  });

  // This is called once before EVERY test
  setUp(() {});

  // This is called once after ALL tests
  tearDownAll(() {});

  // This is called once after EVERY test
  tearDown(() {});

  // ==========================================================================
  // [ASYNC UC TESTING] =======================================================
  // ==========================================================================

  group("Async Use Case Tests", () {
    test("codemelted.async_sleep Validation", () async {
      var start = DateTime.now();
      await codemelted.async_sleep(1000);
      var delay =
          DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch;
      expect(delay, greaterThanOrEqualTo(950));
    });

    test("codemelted.async_task Validation", () async {
      // A good result.
      var result = await codemelted.async_task<int>(
        task: ([data]) async {
          return data + 5;
        },
        data: 37,
      );
      expect(result.is_ok, isTrue);
      expect(result.is_error, isFalse);
      expect(result.value, equals(42));

      // An error case
      result = await codemelted.async_task<int>(
        task: ([data]) {
          return data + 5;
        },
        data: "a",
      );
      expect(result.is_ok, isFalse);
      expect(result.is_error, isTrue);
      expect(result.value, isNull);
    });

    test("codemelted.async_timer Validation", () async {
      var count = 0;
      var timer = codemelted.async_timer(
        task: () {
          count += 1;
        },
        interval: 250,
      );
      expect(timer.isRunning, isTrue);
      await codemelted.async_sleep(1100);
      timer.stop();
      expect(count, greaterThanOrEqualTo(4));
      expect(timer.isRunning, isFalse);
    });
  });

  // ==========================================================================
  // [JSON UC TESTING] ========================================================
  // ==========================================================================

  group("JSON Use Case Tests", () {
    test("CArray Validation", () {
      var listenerCount = 0;
      onDataChanged() => listenerCount += 1;

      var array = codemelted.json_create_array();
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

      var obj = codemelted.json_create_object();
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

    test("codemelted.json_parse Validation", () {
      // bool parsing
      expect(codemelted.json_parse<bool>("42"), isFalse);
      expect(codemelted.json_parse<bool>("1"), isTrue);
      expect(codemelted.json_parse<bool>("yes"), isTrue);
      expect(codemelted.json_parse<bool>("no"), isFalse);

      // double validation
      expect(codemelted.json_parse<double>("a"), isNull);
      expect(codemelted.json_parse<double>("42.2"), isNotNull);
      expect(codemelted.json_parse<double>("42"), isNotNull);

      // int validation
      expect(codemelted.json_parse<int>("a"), isNull);
      expect(codemelted.json_parse<int>("42.2"), isNull);
      expect(codemelted.json_parse<int>("42"), isNotNull);
    });

    test("codemelted.json_has_key Validation", () {
      var obj = codemelted.json_create_object({
        "one": 1,
        "two": "two",
        "three": null,
      });

      expect(codemelted.json_has_key(obj: obj, key: "one"), isTrue);
      expect(codemelted.json_has_key(obj: obj, key: "4"), isFalse);
      try {
        codemelted.json_has_key(obj: obj, key: "4", shouldThrow: true);
        fail("should throw exception");
      } catch (ex) {
        expect(ex, isA<String>());
      }
    });

    test("codemelted.json_check_type Validation", () {
      expect(codemelted.json_check_type<String>(data: 42), isFalse);
      expect(codemelted.json_check_type<String>(data: "42"), isTrue);
      try {
        codemelted.json_check_type<String>(data: 42, shouldThrow: true);
        fail("should throw exception");
      } catch (ex) {
        expect(ex, isA<String>());
      }
    });

    test("codemelted.json_valid_url Validation", () {
      expect(codemelted.json_valid_url(url: "https://codemelted.com"), isTrue);
      expect(codemelted.json_valid_url(url: "j;,ht:/b;l42"), isFalse);
      try {
        codemelted.json_valid_url(url: "j;,ht:/b;l42", shouldThrow: true);
        fail("should throw exception");
      } catch (ex) {
        expect(ex, isA<String>());
      }
    });
  });

  // ==========================================================================
  // [RUNTIME UC TESTING] =====================================================
  // ==========================================================================

  group("Runtime UC Validation", () {
    test("codemelted.npu_math Test", () {
      expect(codemelted.npu_math(formula: MATH_FORMULA.TemperatureCelsiusToFahrenheit, args: [0.0]), equals(32.0));
    });

    test("codemelted.runtime_cpu_count() Test", () {
      expect(codemelted.runtime_cpu_count(), greaterThanOrEqualTo(1));
    });

    test("codemelted.runtime_environment() Test", () {
      expect(codemelted.runtime_environment("username"), isNull);
    });

    test("codemelted.runtime_event Test", () {
      try {
        void listener(web.Event e) { }
        codemelted.runtime_event(action: "add", type: "DOMContentLoaded", listener: listener);
        codemelted.runtime_event(action: "remove", type: "DOMContentLoaded", listener: listener);
      } catch (err) {
        fail("Should not throw");
      }
    });

    test("codemelted.runtime_hostname() Test", () {
      expect(codemelted.runtime_hostname(), equals("localhost"));
    });

    test("codemelted.runtime_name() Test", () {
      expect(codemelted.runtime_name(), equals("chrome"));
    });

    test("codemelted.runtime_online() Test", () {
      expect(codemelted.runtime_online(), isTrue);
    });
  });

  // ==========================================================================
  // [UI UC TESTING] ==========================================================
  // ==========================================================================

  group("UI Use Case Tests", ()  {
    test("codemelted.ui_is() Validation", ()  {
      expect(codemelted.ui_is(IS_REQUEST.PWA), isA<bool>());
      expect(codemelted.ui_is(IS_REQUEST.SecureContext), isA<bool>());
      expect(codemelted.ui_is(IS_REQUEST.TouchEnabled), isA<bool>());
    });
  });

}
