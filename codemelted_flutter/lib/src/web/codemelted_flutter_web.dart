// ignore: avoid_web_libraries_in_flutter
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
import 'dart:ui_web';

import 'package:codemelted_flutter/src/codemelted_flutter_platform_interface.dart';
import 'package:codemelted_flutter/src/definitions/async_io.dart';
import 'package:codemelted_flutter/src/definitions/widgets.dart';
import 'package:codemelted_flutter/src/web/definitions/async_io.dart';
import 'package:codemelted_flutter/src/web/definitions/widgets.dart';
import 'package:flutter/material.dart';
import "package:flutter_web_plugins/flutter_web_plugins.dart";
import "package:web/web.dart" as web;

/// A web implementation of the CodeMeltedFlutterPlatform of the
/// CodeMeltedFlutter plugin.
class CodeMeltedFlutterWeb extends CodeMeltedFlutterPlatform {
  // --------------------------------------------------------------------------
  // [Async IO Definitions] ---------------------------------------------------
  // --------------------------------------------------------------------------

  @override
  CAsyncWorker createIsolate({
    required CAsyncWorkerListener listener,
    required CIsolateConfig config,
  }) {
    throw UnsupportedError("Isolate not supported on web target");
  }

  @override
  CAsyncWorker createProcess({
    required CAsyncWorkerListener listener,
    required CProcessConfig config,
  }) {
    throw UnsupportedError("Process not supported on web target");
  }

  @override
  CAsyncWorker createWorker({
    required CAsyncWorkerListener listener,
    required CWorkerConfig config,
  }) {
    return CWebWorker(listener, config.url);
  }

// ----------------------------------------------------------------------------
// [Dialog Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

  @override
  void openWebBrowser({
    required String url,
    String? target,
    double? height,
    double? width,
  }) {
    if (target == null) {
      // Target not specified, it is a popup window.
      final w = width ?? 900;
      final h = height ?? 600;
      final top = (web.window.screen.height - h) / 2;
      final left = (web.window.screen.width - w) / 2;
      web.window.open(
        url,
        "_blank",
        "toolbar=no, location=no, directories=no, status=no, "
            "menubar=no, scrollbars=no, resizable=yes, copyhistory=no, "
            "width=$w, height=$h, top=$top, left=$left",
      );
      return;
    } else {
      // Target specified, we are redirecting somewhere.
      web.window.open(url, target);
    }
  }

  // --------------------------------------------------------------------------
  // [Runtime Definitions] ----------------------------------------------------
  // --------------------------------------------------------------------------

  @override
  String? environment(String key) {
    var urlParams = web.URLSearchParams(web.window.location.search as JSAny);
    return urlParams.get(key);
  }

  @override
  Future<bool> get isPlatformConnected async => true;

  @override
  bool get isPWA {
    var queries = [
      '(display-mode: fullscreen)',
      '(display-mode: standalone)',
      '(display-mode: minimal-ui),'
    ];
    var isPWA = false;
    for (var query in queries) {
      isPWA = isPWA || web.window.matchMedia(query).matches;
    }
    return isPWA;
  }

  // --------------------------------------------------------------------------
  // [Widget Definitions] -----------------------------------------------------
  // --------------------------------------------------------------------------

  @override
  Widget createWebView(CWebViewController controller) {
    // Create the IFrame.
    var iFrameElement = web.HTMLIFrameElement();
    iFrameElement.style.height = "100%";
    iFrameElement.style.width = "100%";
    iFrameElement.style.border = 'none';

    // Configure based on the controller configuration.
    var webController = controller as CWebTargetWebViewController;
    if (webController.webTargetOnlyConfig != null) {
      iFrameElement.allow = webController.webTargetOnlyConfig!.allow;
      iFrameElement.allowFullscreen =
          webController.webTargetOnlyConfig!.allowFullScreen;
      for (var sandbox in webController.webTargetOnlyConfig!.sandbox) {
        iFrameElement.sandbox.add(sandbox.sandbox);
      }
    }

    iFrameElement.src = webController.url;

    // Register it and return it.
    var viewType = UniqueKey();
    platformViewRegistry.registerViewFactory(
      viewType.toString(),
      (int viewId) => iFrameElement,
    );
    webController.iFrameElement = iFrameElement;
    return HtmlElementView(
      viewType: viewType.toString(),
    );
  }

  @override
  CWebViewController createWebViewController({
    required String url,
    CWebChannelCallback? onMessageReceived,
    CWebTargetConfig? webTargetOnlyConfig,
  }) {
    return CWebTargetWebViewController(
      url: url,
      onMessageReceived: onMessageReceived,
      webTargetOnlyConfig: webTargetOnlyConfig ?? const CWebTargetConfig(),
    );
  }

  // --------------------------------------------------------------------------
  // [Object Setup] -----------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Constructs a CodeMeltedFlutterWeb
  CodeMeltedFlutterWeb();

  static void registerWith(Registrar registrar) {
    CodeMeltedFlutterPlatform.instance = CodeMeltedFlutterWeb();
  }
}
