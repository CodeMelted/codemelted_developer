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

import 'package:codemelted_flutter/codemelted_flutter.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart';

/// Creates an IFrame as an embeddable web view for the web target.
Widget createWebView({required String url, Key? key}) {
  var iFrameElement = HTMLIFrameElement();
  iFrameElement.allow = "web-share";
  iFrameElement.sandbox.add("allow-forms");
  iFrameElement.sandbox.add("allow-popups");
  iFrameElement.sandbox.add("allow-scripts");
  iFrameElement.sandbox.add("allow-modals");
  iFrameElement.sandbox.add("allow-same-origin");
  iFrameElement.style.height = "100%";
  iFrameElement.style.width = "100%";
  iFrameElement.src = url;
  iFrameElement.style.border = 'none';
  iFrameElement.allowFullscreen = true;
  platformViewRegistry.registerViewFactory(
    url,
    (int viewId) => iFrameElement,
  );
  return HtmlElementView(
    key: key,
    viewType: url,
  );
}

/// Implements the [CAsyncWorker] object for a dedicated web worker written
/// in JavaScript and hosted via the specified URL.
class CWebWorker extends CAsyncWorker {
  /// The url to the dedicated web worker.
  final String url;

  /// The dedicated Web Worker constructed from the URL.
  late Worker _worker;

  @override
  void postMessage([data]) => _worker.postMessage(data);

  @override
  void terminate() => _worker.terminate();

  CWebWorker(this.url, super.listener) {
    _worker = Worker(url);
    _worker.addEventListener(
      "message",
      (e) {
        onDataReceived(CAsyncWorkerData(false, (e as MessageEvent).data));
      } as EventListener?,
    );
    _worker.addEventListener(
      "messageerror",
      (e) {
        onDataReceived(CAsyncWorkerData(true, e.toString()));
      } as EventListener?,
    );
    _worker.addEventListener(
      "error",
      (e) {
        onDataReceived(CAsyncWorkerData(true, e.toString()));
      } as EventListener?,
    );
  }
}

/// Creates the [CAsyncWorker] wrapped web worker.
CAsyncWorker createWorker({
  String? url,
}) =>
    throw "NOT IMPLEMENTED YET";

/// Determines if the web targeted app is a PWA installed or not.
bool get isPWA {
  var queries = [
    '(display-mode: fullscreen)',
    '(display-mode: standalone)',
    '(display-mode: minimal-ui),'
  ];
  var isPWA = false;
  for (var query in queries) {
    isPWA = isPWA || window.matchMedia(query).matches;
  }
  return isPWA;
}

/// Looks for search parameters in the browser href when the app is started.
String? getEnvironment(String key) {
  var urlParams = URLSearchParams(window.location.href as JSAny);
  return urlParams.get(key);
}

/// Opens the native web browser based on the target specified.
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
    final top = (window.screen.height - h) / 2;
    final left = (window.screen.width - w) / 2;
    window.open(
      url,
      "_blank",
      "toolbar=no, location=no, directories=no, status=no, "
          "menubar=no, scrollbars=no, resizable=yes, copyhistory=no, "
          "width=$w, height=$h, top=$top, left=$left",
    );
    return;
  } else {
    // Target specified, we are redirecting somewhere.
    window.open(url, target);
  }
}
