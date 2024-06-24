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

import "package:codemelted_flutter/src/definitions/async_io.dart";
import "package:codemelted_flutter/src/definitions/widgets.dart";
import "package:codemelted_flutter/src/native/codemelted_flutter_native.dart";
import "package:flutter/material.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

/// Say something
abstract class CodeMeltedFlutterPlatform extends PlatformInterface {
  /// Constructs a CodeMeltedFlutterPlatform.
  CodeMeltedFlutterPlatform() : super(token: _token);

  // --------------------------------------------------------------------------
  // [Async IO Definitions] ---------------------------------------------------
  // --------------------------------------------------------------------------

  /// Creates the dedicated FIFO Isolate for background processing on mobile /
  /// native targets.
  CAsyncWorker createIsolate({
    required CAsyncWorkerListener listener,
    required CIsolateConfig config,
  }) {
    throw UnimplementedError("stub for target platform");
  }

  /// Creates the dedicated FIFO external process to the flutter app.
  CAsyncWorker createProcess({
    required CAsyncWorkerListener listener,
    required CProcessConfig config,
  }) {
    throw UnimplementedError("stub for target platform");
  }

  /// Creates the dedicated FIFO web worker.
  CAsyncWorker createWorker({
    required CAsyncWorkerListener listener,
    required CWorkerConfig config,
  }) {
    throw UnimplementedError("stub for target platform");
  }

  // --------------------------------------------------------------------------
  // [Dialog Definitions] -----------------------------------------------------
  // --------------------------------------------------------------------------

  /// Attempts to open the native web browser for the given platform.
  void openWebBrowser({
    required String url,
    String? target,
    double? height,
    double? width,
  }) {
    throw UnimplementedError("stub for target platform");
  }

  // --------------------------------------------------------------------------
  // [Runtime Definitions] ----------------------------------------------------
  // --------------------------------------------------------------------------

  /// Searches the platforms environment for the specified key and returns
  /// its value if found or null if not found.
  String? environment(String key) {
    throw UnimplementedError("stub for target platform");
  }

  /// Web target only function to determine if the web app is installed as a
  /// Progressive Web Application (PWA).
  bool get isPWA => throw UnimplementedError("stub for target platform");

// ----------------------------------------------------------------------------
// [Widget Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

  /// Creates an embedded web view for the mobile / web targets.
  Widget createWebView(CWebViewController controller) {
    throw UnimplementedError("stub for target platform");
  }

  /// Creates a web view controller that can be utilized on mobile / web targets.
  CWebViewController createWebViewController({
    required String url,
    CWebChannelCallback? onMessageReceived,
    CWebTargetConfig? webTargetOnlyConfig,
  }) {
    throw UnimplementedError("stub for target platform");
  }

  // --------------------------------------------------------------------------
  // [Object Setup] -----------------------------------------------------------
  // --------------------------------------------------------------------------

  // EXAMPLE TO GET TO NATIVE
  // Future<String?> getPlatformVersion() {
  //   throw UnimplementedError("platformVersion() has not been implemented.");
  // }

  /// Holds the token of the object.
  static final Object _token = Object();

  /// The instance of the registered target interface.
  static CodeMeltedFlutterPlatform _instance = CodeMeltedNative();

  /// The default instance of [CodeMeltedFlutterPlatform] to use.
  ///
  /// Defaults to [CodeMeltedNative].
  static CodeMeltedFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CodeMeltedFlutterPlatform] when
  /// they register themselves.
  static set instance(CodeMeltedFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }
}
