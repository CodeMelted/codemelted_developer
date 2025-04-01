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

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:codemelted_developer/codemelted.dart';
import 'package:flutter_test/flutter_test.dart';

import "package:web/web.dart" as web;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // This is called once after ALL tests
  setUpAll(() async {
    await CodeMeltedAPI().initCodeMeltedJS(
      codemeltedJsModuleUrl: "./codemelted.js",
    );
    var success = web.window.hasProperty("codemelted".toJS).toDart;
    expect(success, isTrue);
  });

  // This is called once before EVERY test
  setUp(() {});

  // This is called once after ALL tests
  tearDownAll(() {});

  // This is called once after EVERY test
  tearDown(() {});

  // --------------------------------------------------------------------------
  // [JSON Use Case] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  // group("codemelted.json Tests", () {
  //   test("CArray Validation", () {
  //     var listenerCount = 0;
  //     onDataChanged() => listenerCount += 1;

  //     var array = codemelted.createArray();
  //     array.addListener(listener: onDataChanged);
  //     expect(array.isEmpty, isTrue);

  //     // Fire listener
  //     array.add(2);
  //     array.notifyAll();
  //     expect(array.isNotEmpty, isTrue);
  //     expect(listenerCount, equals(1));

  //     // Don't fire listener
  //     array.insert(0, "hello");
  //     expect(array.length, equals(2));
  //     expect(listenerCount, equals(1));

  //     // Now validate index works as expected.
  //     array.insert(1, true);
  //     array.notifyAll();
  //     expect(array.length, equals(3));
  //     expect(listenerCount, equals(2));
  //     expect(array[1], isTrue);
  //     expect(array[2], equals(2));
  //     expect(array[0], equals("hello"));

  //     // Make a copy and prove it is a copy
  //     var arrayCopy = array.copy();
  //     arrayCopy.add("another string");
  //     expect(array.length != arrayCopy.length, isTrue);

  //     var stringified = arrayCopy.stringify();
  //     expect(stringified!.contains("another"), isTrue);

  //     // Now validate the parse clears the data of the original array
  //     // and load the copies data as if it were serialized data read from
  //     // storage to be used.
  //     var success = array.parse(data: stringified);
  //     expect(success, isTrue);
  //   });

  //   test("CObject Validation", () {
  //     var listenerCount = 0;
  //     onDataChanged() => listenerCount += 1;

  //     var obj = codemelted.createObject();
  //     obj.addListener(listener: onDataChanged);
  //     expect(obj.isEmpty, isTrue);

  //     obj.set<String>(key: "test", value: "test", notify: true);
  //     expect(listenerCount, equals(1));
  //     expect(obj.isNotEmpty, isTrue);
  //     expect(obj.get<String>(key: "test"), equals("test"));

  //     obj.set<bool?>(key: "is_good", value: null);
  //     expect(obj.get<bool?>(key: "is_good"), isNull);
  //     expect(listenerCount, equals(1));

  //     obj.set<CArray>(key: "anArray", value: [1, true, "three"], notify: true);
  //     expect(listenerCount, equals(2));
  //     expect(obj.get<CArray>(key: "anArray").length, equals(3));

  //     var copy = obj.copy();
  //     copy.set<int>(key: "newKey", value: 2);
  //     expect(listenerCount, equals(2));
  //     expect(copy.entries.length != obj.entries.length, isTrue);

  //     var stringified = obj.stringify();
  //     expect(stringified, isNotNull);

  //     var success = obj.parse(initData: stringified!);
  //     expect(success, isTrue);
  //   });

  //   test("asXXX() Validation", () {
  //     // Bool validation
  //     expect(codemelted.asBool(data: "42"), isFalse);
  //     expect(codemelted.asBool(data: "1"), isTrue);
  //     expect(codemelted.asBool(data: "yes"), isTrue);
  //     expect(codemelted.asBool(data: "no"), isFalse);

  //     // double validation
  //     expect(codemelted.asDouble(data: "a"), isNull);
  //     expect(codemelted.asDouble(data: "42.2"), isNotNull);
  //     expect(codemelted.asDouble(data: "42"), isNotNull);

  //     // int validation
  //     expect(codemelted.asInt(data: "a"), isNull);
  //     expect(codemelted.asInt(data: "42.2"), isNull);
  //     expect(codemelted.asInt(data: "42"), isNotNull);
  //   });

  //   test("checkXXX() / tryXXX() Validation", () {
  //     var obj = codemelted.createObject(data: {
  //       "one": 1,
  //       "two": "two",
  //       "three": null,
  //     });

  //     expect(codemelted.checkHasProperty(obj: obj, key: "one"), isTrue);
  //     expect(codemelted.checkHasProperty(obj: obj, key: "4"), isFalse);
  //     try {
  //       codemelted.tryHasProperty(obj: obj, key: "4");
  //       fail("should throw exception");
  //     } catch (ex) {
  //       expect(ex, isA<String>());
  //     }

  //     expect(codemelted.checkType<String>(data: 42), isFalse);
  //     expect(codemelted.checkType<String>(data: "42"), isTrue);
  //     try {
  //       codemelted.tryType<String>(data: 42);
  //       fail("should throw exception");
  //     } catch (ex) {
  //       expect(ex, isA<String>());
  //     }

  //     expect(codemelted.checkValidUrl(data: "https://codemelted.com"), isTrue);
  //     expect(codemelted.checkValidUrl(data: "j;,ht:/b;l42"), isFalse);
  //     try {
  //       codemelted.tryValidUrl(data: "j;,ht:/b;l42");
  //       fail("should throw exception");
  //     } catch (ex) {
  //       expect(ex, isA<String>());
  //     }
  //   });
  // });
}
