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

import 'dart:io';

import 'package:codemelted_flutter/codemelted_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Will create an embeddable web view for a mobile native platform. Will fail
/// for desktop target.s
Widget createWebView({required String url, Key? key}) {
  return WebViewWidget(controller: WebViewController());
}

/// TBD
CAsyncWorker createWorker({
  String? url,
}) =>
    throw "NOT IMPLEMENTED YET";

/// Searches the platforms environment for the specified key and returns
/// its value if found or null if not found.
String? getEnvironment(String key) {
  return Platform.environment.containsKey(key)
      ? Platform.environment[key]
      : null;
}

/// Always returns false. Native apps cannot be PWAs.
bool get isPWA => false;

/// Will attempt to open a web browser depending on the app target.
void openWebBrowser({
  required String url,
  String? target,
  double? height,
  double? width,
}) {
  throw "NOT IMPLEMENTED YET";
}
