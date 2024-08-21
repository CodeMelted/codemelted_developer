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

/// Provides the extensions necessary to take full advantage of the JSON and
/// validating your data.
library codemelted_json;

import "dart:convert";

import "package:flutter/foundation.dart";

/// Defines an array definition to match JSON Array construct.
typedef CArray = List<dynamic>;

/// Provides helper methods for the CArray.
extension CArrayExtension on CArray {
  /// Builds a map of ChangeNotifier objects to support notification via the
  /// [CArray] definition.
  static final _map = <dynamic, ChangeNotifier?>{};

  /// Adds an event listener so when changes are made via the
  /// [CObjectExtension.set] method.
  void addListener(void Function() listener) {
    if (_map[this] == null) {
      _map[this] = ChangeNotifier();
    }
    _map[this]!.addListener(listener);
  }

  /// Removes an event listener from the [CArray].
  void removeListener(void Function() listener) {
    _map[this]?.removeListener(listener);
  }

  /// Provides a method to set data elements on the [CArray].
  void set<T>(int index, T value, {bool notify = false}) {
    insert(index, value);
    if (notify) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      _map[this]?.notifyListeners();
    }
  }

  /// Provides the ability to extract a data element from the represented
  /// [CArray] at the given index.
  T get<T>(int index) => elementAt(index) as T;

  /// Creates a copy of the array.
  CArray copy() {
    var copy = <dynamic>[];
    copy.addAll(this);
    return copy;
  }

  /// Attempts to parse the serialized string data and turn it into a
  /// [CArray]. Any data previously held by this object is cleared. False is
  /// returned if it could not parse the data.
  bool parse(String data) {
    try {
      clear();
      addAll(jsonDecode(data));
      return true;
    } catch (ex) {
      return false;
    }
  }

  /// Converts the JSON object to a string returning null if it cannot
  String? stringify() => jsonEncode(this);
}

/// Defines an object definition to match a valid JSON Object construct.
typedef CObject = Map<String, dynamic>;

/// Provides helper methods for the [CObject] for set / get data, implementing
/// a [ChangeNotifier], and being able to serialize / deserialize between
/// JSON and string data.
extension CObjectExtension on CObject {
  /// Builds a map of ChangeNotifier objects to support notification via the
  /// [CObject] definition.
  static final _map = <dynamic, ChangeNotifier?>{};

  /// Adds an event listener so when changes are made via the
  /// [CObjectExtension.set] method.
  void addListener(void Function() listener) {
    if (_map[this] == null) {
      _map[this] = ChangeNotifier();
    }
    _map[this]!.addListener(listener);
  }

  /// Removes an event listener from the [CObject].
  void removeListener(void Function() listener) {
    _map[this]?.removeListener(listener);
  }

  /// Attempts to parse the serialized string data and turn it into a
  /// [CObject]. Any data previously held by this object is cleared. False is
  /// returned if it could not parse the data.
  bool parse(String data) {
    try {
      clear();
      addAll(jsonDecode(data));
      return true;
    } catch (ex) {
      return false;
    }
  }

  /// Converts the JSON object to a string returning null if it cannot.
  String? stringify() {
    try {
      return jsonEncode(this);
    } catch (ex) {
      return null;
    }
  }

  /// Provides a method to set data elements on the [CObject].
  void set<T>(String key, T value, {bool notify = false}) {
    this[key] = value;
    if (notify) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      _map[this]?.notifyListeners();
    }
  }

  /// Provides the ability to extract a data element from the represented
  /// [CObject].
  T get<T>(String key) {
    return this[key];
  }
}

/// Provides a series of asXXX() conversion from a string data type and do non
/// case sensitive compares.
extension CStringExtension on String {
  /// Will attempt to return an array object ir null if it cannot.
  CArray? asArray() {
    try {
      return jsonDecode(this) as CArray?;
    } catch (ex) {
      return null;
    }
  }

  /// Will attempt to convert to a bool from a series of strings that can
  /// represent a true value.
  bool asBool() {
    List<String> trueStrings = [
      "true",
      "1",
      "t",
      "y",
      "yes",
      "yeah",
      "yup",
      "certainly",
      "uh-huh"
    ];
    return trueStrings.contains(toLowerCase());
  }

  /// Will attempt to return a double from the string value or null if it
  /// cannot.
  num? asDouble() => double.tryParse(this);

  /// Will attempt to return a int from the string value or null if it cannot.
  num? asInt() => int.tryParse(this);

  /// Will attempt to return Map<String, dynamic> object or null if it cannot.
  CObject? asObject() {
    try {
      return jsonDecode(this) as CObject?;
    } catch (ex) {
      return null;
    }
  }

  /// Determines if a string is contained within this string.
  bool containsIgnoreCase(String v) => toLowerCase().contains(v.toLowerCase());

  /// Determines if a string is equal to another ignoring case.
  bool equalsIgnoreCase(String v) => toLowerCase() == v.toLowerCase();
}

/// Defines a set of utility methods for performing data conversions for JSON
/// along with data validation.
class CodeMeltedJSON {
  /// Determines if a [CObject] has a given property contained within.
  bool checkHasProperty({required CObject obj, required String key}) {
    return obj.containsKey(key);
  }

  /// Determines if the variable is of the expected type.
  bool checkType<T>({required dynamic data}) {
    return data is T;
  }

  /// Determines if the data type is a valid URL.
  bool checkValidUrl({required String data}) {
    return Uri.tryParse(data) != null;
  }

  /// Will convert data into a JSON [CObject] or return null if the decode
  /// could not be achieved.
  CObject? jsonParse({required String data}) {
    return data.asObject();
  }

  /// Will encode the JSON [CObject] into a string or null if the encode
  /// could not be achieved.
  String? jsonStringify({required CObject data}) {
    return data.stringify();
  }

  /// Same as [checkHasProperty] but throws an exception if the key
  /// is not found.
  void tryHasProperty({required CObject obj, required String key}) {
    if (!checkHasProperty(obj: obj, key: key)) {
      throw "obj does not contain '$key' key";
    }
  }

  /// Same as [checkType] but throws an exception if not of the
  /// expected type.
  void tryType<T>({required dynamic data}) {
    if (!checkType<T>(data: data)) {
      throw "variable was not of type '$T'";
    }
  }

  /// Same as [checkValidUrl] but throws an exception if not a valid
  /// URL type.
  void tryValidUrl({required String data}) {
    if (!checkValidUrl(data: data)) {
      throw "v was not a valid URL string";
    }
  }

  /// Holds the private instance of the API.
  static CodeMeltedJSON? _instance;

  /// Gets the single instance of the API.
  factory CodeMeltedJSON() => _instance ?? CodeMeltedJSON._();

  /// Sets up the internal instance for this object.
  CodeMeltedJSON._() {
    _instance = this;
  }
}

/// Sets up the namespace for the [CodeMeltedJSON] object.
final codemelted_json = CodeMeltedJSON();
