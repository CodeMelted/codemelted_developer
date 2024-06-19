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
import 'dart:isolate';

import 'package:codemelted_flutter/codemelted_flutter.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ----------------------------------------------------------------------------
// [Async IO Definitions] -----------------------------------------------------
// ----------------------------------------------------------------------------

/// The flutter wrapped Isolate that implements the [CAsyncWorker] object
/// definition to support background processing on mobile / native targets.
class CIsolateWorker extends CAsyncWorker {
  /// The Isolate object constructed and held by this object.
  late Isolate _isolate;

  /// The port to send data via the postMessage method.
  late SendPort _sendPort;

  /// The receiver port to listen for incoming results from the Isolate and
  /// pass them back via the onDataReceived super method.
  late ReceivePort _receivePort;

  /// The task that serves as the event loop of the Isolate.
  late CAsyncTask _task;

  /// Singleton objects to support the [CAsyncTask] constructed within the
  /// Isolate thread / memory space and accessible within the _task.
  late void Function()? _factoryWorkers;

  @override
  void postMessage([data]) {
    _sendPort.send(data);
  }

  @override
  void terminate() {
    _isolate.kill(priority: Isolate.immediate);
    _receivePort.close();
  }

  /// Sets up the items necessary for the dedicated Isolate.
  CIsolateWorker(
    super.listener,
    CAsyncTask task,
    void Function()? factoryWorkers,
  ) {
    _task = task;
    _factoryWorkers = factoryWorkers;
    _init();
  }

  /// Private helper to setup the overall bi-directional nature of the Isolate.
  Future<void> _init() async {
    // Setup the receive port and spawn the isolate
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn<SendPort>((port) {
      // See if we have factory workers to create:
      if (_factoryWorkers != null) {
        _factoryWorkers!();
      }

      // Now setup the FIFO event loop processing for the Isolate.
      var receivePort = ReceivePort();
      port.send(receivePort.sendPort);
      receivePort.listen((data) async {
        try {
          var result = await _task(data);
          port.send(CAsyncWorkerData(false, result));
        } catch (ex) {
          port.send(CAsyncWorkerData(true, ex.toString()));
        }
      });
    }, _receivePort.sendPort);

    // Now setup our receive of data processed within the Isolate
    _receivePort.listen((result) {
      if (result is SendPort) {
        _sendPort = result;
      } else {
        onDataReceived(result);
      }
    });
    await Future.delayed(const Duration(seconds: 250));
  }
}

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
  throw "Not supported on mobile / native platforms. Only web.";
}

// ----------------------------------------------------------------------------
// [Dialog Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

/// Will attempt to open a web browser depending on the app target.
void openWebBrowser({
  required String url,
  String? target,
  double? height,
  double? width,
}) {
  throw "NOT IMPLEMENTED YET";
}

// ----------------------------------------------------------------------------
// [Runtime Definitions] ------------------------------------------------------
// ----------------------------------------------------------------------------

/// Searches the platforms environment for the specified key and returns
/// its value if found or null if not found.
String? getEnvironment(String key) {
  return Platform.environment.containsKey(key)
      ? Platform.environment[key]
      : null;
}

/// Always returns false. Native apps cannot be PWAs.
bool get isPWA => false;

// ----------------------------------------------------------------------------
// [Widget Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

/// Implements the [CWebViewController] specific for the mobile targets.
class _CWebViewController extends CWebViewController {
  /// The webview_flutter web view controller for our embeddable widget.
  late WebViewController controller;

  @override
  Future<void> onUrlChanged() async => controller.loadRequest(Uri.parse(url));

  @override
  Future<void> postMessage(String data) async {
    await controller.runJavaScript(
      '''
      if (CodeMeltedChannel.onMessageReceived != null) {
         CodeMeltedChannel.onMessageReceived($data);
      }''',
    );
  }

  /// Sets up the controller for mobile targets to change the URL web view and
  /// send / receive messages.
  _CWebViewController({
    required super.url,
    super.onMessageReceived,
    super.webTargetOnlyConfig,
  }) {
    controller = WebViewController();
    controller.setBackgroundColor(const Color(0x00000000));
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    if (onMessageReceived != null) {
      controller.addJavaScriptChannel(
        "CodeMeltedChannel",
        onMessageReceived: onMessageReceived!,
      );
    }
    controller.loadRequest(Uri.parse(url));
  }
}

/// Will create an embeddable web view for a mobile native platform. Will fail
/// for desktop targets.
Widget createWebView(CWebViewController controller) {
  assert(
    Platform.isAndroid || Platform.isIOS,
    "CWebViewController is only supported on mobile native platforms "
    "and not desktop.",
  );
  return WebViewWidget(
    controller: (controller as _CWebViewController).controller,
  );
}

/// Will create the web view controller to support the embedded web view for
/// mobile native targets.
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
  return _CWebViewController(
    url: url,
    onMessageReceived: onMessageReceived,
    webTargetOnlyConfig: webTargetOnlyConfig,
  );
}
