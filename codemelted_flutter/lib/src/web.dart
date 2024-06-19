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
import 'dart:ui_web';

import 'package:codemelted_flutter/codemelted_flutter.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart';

// ----------------------------------------------------------------------------
// [Async IO Definitions] -----------------------------------------------------
// ----------------------------------------------------------------------------

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

  CWebWorker(super.listener, this.url) {
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

/// Creates the dedicated FIFO Isolate for background processing on mobile /
/// native targets.
CAsyncWorker createIsolate({
  required CAsyncWorkerListener listener,
  required CIsolateConfig config,
}) {
  throw "Not supported on web platform. Only mobile / native platforms.";
}

/// Creates the dedicated FIFO external process to the flutter app.
CAsyncWorker createProcess({
  required CAsyncWorkerListener listener,
  required CProcessConfig config,
}) {
  throw "Not supported on web platform. Only mobile / native platforms.";
}

/// Creates the dedicated FIFO web worker.
CAsyncWorker createWorker({
  required CAsyncWorkerListener listener,
  required CWorkerConfig config,
}) {
  return CWebWorker(listener, config.url);
}

// ----------------------------------------------------------------------------
// [Dialog Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

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

// ----------------------------------------------------------------------------
// [Runtime Definitions] ------------------------------------------------------
// ----------------------------------------------------------------------------

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
  var urlParams = URLSearchParams(window.location.search as JSAny);
  return urlParams.get(key);
}

// ----------------------------------------------------------------------------
// [Widget Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

/// Handles the message channel to mirror the native WebViewController
/// interface.
@JSExport()
class _CodeMeltedChannel {
  /// The callback to process received messages from the JavaScript postMessage
  /// call into the flutter app.
  late CWebChannelCallback dartOnMessageReceived;

  /// The exposed postMessage function to the JavaScript page.
  void postMessage(JSAny v) => dartOnMessageReceived(v);

  /// Constructor for the class.
  _CodeMeltedChannel(this.dartOnMessageReceived);
}

/// Controller specific implementation for the web target to mirror the
/// behavior of the native.dart WebViewController object.
class _CWebViewController extends CWebViewController {
  /// Reference to the HTMLIframeElement created via the createWebView call.
  late HTMLIFrameElement _iFrameElement;

  /// Reference to the [_CodeMeltedChannel] exported JavaScript object.
  _CodeMeltedChannel? channel;

  /// Sets the IFrame element post createWebView call.
  set iFrameElement(HTMLIFrameElement v) {
    _iFrameElement = v;
    configureMessageChannel();
  }

  /// Handles the [_CodeMeltedChannel.postMessage] call to receive messages
  /// from the HTML page.
  void handlePostMessage(JSAny v) {
    if (onMessageReceived != null) {
      onMessageReceived!(v);
    }
  }

  /// Sets up the Message Channel to communicate with the web page.
  Future<void> configureMessageChannel() async {
    // See if we have a channel to hook up.
    if (channel != null) {
      // We do, make sure the iframe element gets constructed properly.
      while (_iFrameElement.contentWindow == null) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Now hookup the channel.
      await Future.delayed(const Duration(milliseconds: 50));
      _iFrameElement.contentWindow!.setProperty(
        "CodeMeltedChannel".toJS,
        createJSInteropWrapper(channel!),
      );
    }
  }

  @override
  Future<void> postMessage(String data) async {
    // Go get the IFrames content window.
    var channel = _iFrameElement.contentWindow?.getProperty(
      "CodeMeltedChannel".toJS,
    ) as JSObject?;

    // See if a channel has been setup.
    if (channel != null) {
      if (channel.hasProperty("onMessageReceived".toJS).toDart) {
        channel.callMethod("onMessageReceived".toJS, data.toJS);
      }
    }
  }

  @override
  Future<void> onUrlChanged() async {
    _iFrameElement.src = url;
    configureMessageChannel();
    await configureMessageChannel();
  }

  /// Constructor for the class.
  _CWebViewController({
    required super.url,
    super.onMessageReceived,
    super.webTargetOnlyConfig,
  }) {
    if (onMessageReceived != null) {
      channel = _CodeMeltedChannel(onMessageReceived!);
    }
  }
}

/// Creates an IFrame as an embeddable web view for the web target.
Widget createWebView(CWebViewController controller) {
  // Create the IFrame.
  var iFrameElement = HTMLIFrameElement();
  iFrameElement.style.height = "100%";
  iFrameElement.style.width = "100%";
  iFrameElement.style.border = 'none';

  // Configure based on the controller configuration.
  var webController = controller as _CWebViewController;
  iFrameElement.allow = webController.webTargetOnlyConfig!.allow;
  iFrameElement.allowFullscreen =
      webController.webTargetOnlyConfig!.allowFullScreen;
  for (var sandbox in webController.webTargetOnlyConfig!.sandbox) {
    iFrameElement.sandbox.add(sandbox.sandbox);
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

/// Creates a web view tailored to the web target.
CWebViewController createWebViewController({
  required String url,
  CWebChannelCallback? onMessageReceived,
  CWebTargetConfig? webTargetOnlyConfig,
}) {
  return _CWebViewController(
    url: url,
    onMessageReceived: onMessageReceived,
    webTargetOnlyConfig: webTargetOnlyConfig ?? const CWebTargetConfig(),
  );
}
