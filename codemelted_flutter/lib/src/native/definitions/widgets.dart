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

import 'dart:ui';

import 'package:codemelted_flutter/src/definitions/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Implements the [CWebViewController] specific for the mobile targets.
class CNativeWebViewController extends CWebViewController {
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
  CNativeWebViewController({
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
