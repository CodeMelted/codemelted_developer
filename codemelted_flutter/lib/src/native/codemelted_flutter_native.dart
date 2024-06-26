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

import "dart:io";

import "package:codemelted_flutter/src/codemelted_flutter_platform_interface.dart";
import "package:codemelted_flutter/src/definitions/async_io.dart";
import "package:codemelted_flutter/src/definitions/widgets.dart";
import "package:codemelted_flutter/src/native/definitions/widgets.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:webview_flutter/webview_flutter.dart";

/// An implementation of [CodeMeltedFlutterPlatform] that uses method channels.
class CodeMeltedNative extends CodeMeltedFlutterPlatform {
  // --------------------------------------------------------------------------
  // [Async IO Definitions] ---------------------------------------------------
  // --------------------------------------------------------------------------
  @override
  CAsyncWorker createIsolate({
    required CAsyncWorkerListener listener,
    required CIsolateConfig config,
  }) {
    throw UnimplementedError("IN DEVELOPMENT");
  }

  @override
  CAsyncWorker createProcess({
    required CAsyncWorkerListener listener,
    required CProcessConfig config,
  }) {
    throw UnimplementedError("IN DEVELOPMENT");
  }

  @override
  CAsyncWorker createWorker({
    required CAsyncWorkerListener listener,
    required CWorkerConfig config,
  }) {
    throw UnsupportedError("WebWorker not supported on native target");
  }

  // --------------------------------------------------------------------------
  // [Dialog Definitions] -----------------------------------------------------
  // --------------------------------------------------------------------------

  @override
  void openWebBrowser({
    required String url,
    String? target,
    double? height,
    double? width,
  }) {
    throw UnimplementedError("IN DEVELOPMENT");
  }

  // --------------------------------------------------------------------------
  // [Runtime Definition] -----------------------------------------------------
  // --------------------------------------------------------------------------
  @override
  String? environment(String key) {
    return Platform.environment.containsKey(key)
        ? Platform.environment[key]
        : null;
  }

  @override
  bool get isPWA => false;

  // --------------------------------------------------------------------------
  // [Widget Definitions] -----------------------------------------------------
  // --------------------------------------------------------------------------

  @override
  Widget createWebView(CWebViewController controller) {
    assert(
      Platform.isAndroid || Platform.isIOS,
      "CWebViewController is only supported on mobile native platforms "
      "and not desktop.",
    );
    return WebViewWidget(
      controller: (controller as CNativeWebViewController).controller,
    );
  }

  @override
  CWebViewController createWebViewController({
    required String url,
    CWebChannelCallback? onMessageReceived,
    CWebTargetConfig? webTargetOnlyConfig,
  }) {
    assert(
      Platform.isAndroid || Platform.isIOS,
      "CWebViewController is only supported on mobile native platforms "
      "and not desktop.",
    );
    return CNativeWebViewController(
      url: url,
      onMessageReceived: onMessageReceived,
      webTargetOnlyConfig: webTargetOnlyConfig,
    );
  }

  // --------------------------------------------------------------------------
  // [Object Setup] -----------------------------------------------------------
  // --------------------------------------------------------------------------

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel("codemelted_flutter");

  // DEMO OF HOW TO CALL INTO NATIVE CODE
  // @override
  // Future<String?> getPlatformVersion() async {
  //   final version =
  //       await methodChannel.invokeMethod<String>("getPlatformVersion");
  //   return version;
  // }
}
