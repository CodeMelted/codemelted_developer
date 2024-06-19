// @nodoc
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

import 'package:codemelted_flutter/codemelted_flutter.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Stubbed functions for the platform interface.
// The implementations for native and web are in the respective *.dart files.
// Utilized in the codemelted_flutter.dart module to facilitate between the
// different flutter targets as follows:
/*
import 'package:codemelted_flutter/platform/stub.dart'
    if (dart.library.io) 'package:codemelted_flutter/_lib/platform/native.dart'
    if (dart.library.js) 'package:codemelted_flutter/_lib/platform/web.dart'
    as platform;
*/
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Async IO Definitions] -----------------------------------------------------
// ----------------------------------------------------------------------------

/// Creates the dedicated FIFO Isolate for background processing on mobile /
/// native targets.
CAsyncWorker createIsolate({
  required CAsyncWorkerListener listener,
  required CIsolateConfig config,
}) {
  throw "Stub. Should not get this";
}

/// Creates the dedicated FIFO external process to the flutter app.
CAsyncWorker createProcess({
  required CAsyncWorkerListener listener,
  required CProcessConfig config,
}) {
  throw "Stub. Should not get this";
}

/// Creates the dedicated FIFO web worker.
CAsyncWorker createWorker({
  required CAsyncWorkerListener listener,
  required CWorkerConfig config,
}) {
  throw "Stub. Should not get this";
}

// ----------------------------------------------------------------------------
// [Dialog Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

/// Attempts to open the native web browser for the given platform.
void openWebBrowser({
  required String url,
  String? target,
  double? height,
  double? width,
}) =>
    throw "Stub. Should Not Get This";

// ----------------------------------------------------------------------------
// [Runtime Definitions] ------------------------------------------------------
// ----------------------------------------------------------------------------

/// Provides the ability to lookup environment variables
String? getEnvironment(String key) => throw 'Stub. Should not get this';

/// Web target only function to determine if the web app is installed as a
/// Progressive Web Application (PWA).
bool get isPWA => throw "Stub. Should Not Get This";

// ----------------------------------------------------------------------------
// [Widget Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

/// Creates an embedded web view for the mobile / web targets.
Widget createWebView(CWebViewController controller) {
  throw "Stub. Should Not Get This";
}

/// Creates a web view controller that can be utilized on mobile / web targets.
CWebViewController createWebViewController({
  required String url,
  CWebChannelCallback? onMessageReceived,
  CWebTargetConfig? webTargetOnlyConfig,
}) {
  throw "Stub. Should not get this.";
}
