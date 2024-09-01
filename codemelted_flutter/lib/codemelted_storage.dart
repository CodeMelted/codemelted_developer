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

/// Provides the hooks for working with the different browser storage methods
/// that don't require a full on database.
library codemelted_storage;

import "package:web/web.dart" as web;

/// Identifies the storage method for the data you wish to manage.
enum CStorageMethod {
  /// Will work with the browser cookie store with the browser.
  cookie,

  /// Will work with localStorage of the browser.
  local,

  /// Will work with sessionStorage of the browser.
  session;
}

/// Provides the ability to manage a key / value pair within the web
/// environment.
///
/// See https://developer.mozilla.org/en-US/docs/Web/API/Storage
/// See https://developer.mozilla.org/en-US/docs/Web/HTTP/Cookies
class CodeMeltedStorage {
  /// Clears all data from the identified [CStorageMethod].
  void clear({CStorageMethod method = CStorageMethod.local}) {
    if (method == CStorageMethod.local) {
      web.window.localStorage.clear();
    } else if (method == CStorageMethod.session) {
      web.window.sessionStorage.clear();
    } else {
      web.document.cookie = "";
    }
  }

  /// Gets data from the identified [CStorageMethod] via the specified key.
  String? getItem({
    CStorageMethod method = CStorageMethod.local,
    required String key,
  }) {
    if (method == CStorageMethod.local) {
      return web.window.localStorage.getItem(key);
    } else if (method == CStorageMethod.session) {
      return web.window.sessionStorage.getItem(key);
    } else {
      var name = "$key=";
      var ca = web.document.cookie.split(';');
      for (var i = 0; i < ca.length; i++) {
        var c = ca[i];
        while (c[0] == " ") {
          c = c.substring(1);
        }
        if (c.indexOf(name) == 0) {
          return c.substring(name.length, c.length);
        }
      }
      return null;
    }
  }

  /// Total items stored in the identified [CStorageMethod].
  int length({CStorageMethod method = CStorageMethod.local}) {
    if (method == CStorageMethod.local) {
      return web.window.localStorage.length;
    } else if (method == CStorageMethod.session) {
      return web.window.sessionStorage.length;
    } else {
      var ca = web.document.cookie.split(';');
      return ca.length;
    }
  }

  /// Gets the key from the index from the identified [CStorageMethod].
  String? key({
    CStorageMethod method = CStorageMethod.local,
    required int index,
  }) {
    if (method == CStorageMethod.local) {
      return web.window.localStorage.key(index);
    } else if (method == CStorageMethod.session) {
      return web.window.sessionStorage.key(index);
    } else {
      throw UnsupportedError("CStorageMethod.cookie does not support this.");
    }
  }

  /// Removes an item by key from the identified [CStorageMethod].
  void removeItem({
    CStorageMethod method = CStorageMethod.local,
    required String key,
  }) {
    if (method == CStorageMethod.local) {
      web.window.localStorage.removeItem(key);
    } else if (method == CStorageMethod.session) {
      web.window.sessionStorage.removeItem(key);
    } else {
      web.document.cookie = "$key=; expires=01 Jan 1970 00:00:00; path=/;";
    }
  }

  /// Sets an item by key within the identified [CStorageMethod].
  void setItem({
    CStorageMethod method = CStorageMethod.local,
    required String key,
    required String value,
  }) {
    if (method == CStorageMethod.local) {
      web.window.localStorage.setItem(key, value);
    } else if (method == CStorageMethod.session) {
      web.window.sessionStorage.setItem(key, value);
    } else {
      var d = DateTime(DateTime.now().year + 1);
      var expires = "expires=${d.toUtc().toString()}";
      web.document.cookie = "$key=$value; $expires; path=/";
    }
  }

  /// Gets the single instance of the API.
  static CodeMeltedStorage? _instance;

  /// Sets up the internal instance for this object.
  factory CodeMeltedStorage() => _instance ?? CodeMeltedStorage._();

  /// Sets up the namespace for the [CodeMeltedRuntime] object.
  CodeMeltedStorage._() {
    _instance = this;
  }
}

/// Sets up the namespace for the [CodeMeltedStorage] object.
final codemelted_storage = CodeMeltedStorage();
