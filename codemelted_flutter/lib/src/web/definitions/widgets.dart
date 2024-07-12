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

import 'package:codemelted_flutter/src/definitions/widgets.dart';
import "package:web/web.dart" as web;

/// Handles the message channel to mirror the native WebViewController
/// interface.
@JSExport()
class CodeMeltedChannel {
  /// The callback to process received messages from the JavaScript postMessage
  /// call into the flutter app.
  late CWebChannelCallback dartOnMessageReceived;

  /// The exposed postMessage function to the JavaScript page.
  void postMessage(JSAny v) => dartOnMessageReceived(v);

  /// Constructor for the class.
  CodeMeltedChannel(this.dartOnMessageReceived);
}

/// Controller specific implementation for the web target to mirror the
/// behavior of the native.dart WebViewController object.
class CWebTargetWebViewController extends CWebViewController {
  /// Reference to the HTMLIframeElement created via the createWebView call.
  late web.HTMLIFrameElement _iFrameElement;

  /// Reference to the [CodeMeltedChannel] exported JavaScript object.
  CodeMeltedChannel? channel;

  /// Sets the IFrame element post createWebView call.
  set iFrameElement(web.HTMLIFrameElement v) {
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
  CWebTargetWebViewController({
    required super.url,
    super.onMessageReceived,
    super.webTargetOnlyConfig,
  }) {
    if (onMessageReceived != null) {
      channel = CodeMeltedChannel(onMessageReceived!);
    }
  }
}
