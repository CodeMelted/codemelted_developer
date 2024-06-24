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

import 'package:codemelted_flutter/src/codemelted_flutter_platform_interface.dart';
import 'package:flutter/material.dart';

/// Supports identifying the [codemelted_ui_button] widget constructed.
enum CButtonType { elevated, filled, icon, outlined, text }

/// Supports identifying what [codemelted_ui_image] is constructed when
/// utilized.
enum CImageType { asset, file, memory, network }

/// Defines a tab item to utilize with the [codemelted_ui_tab_view] method.
class CTabItem {
  /// The content displayed with the tab.
  final Widget content;

  /// An icon for the tab within the tab view.
  final dynamic icon;

  /// A title with the tab within the tab view.
  final String? title;

  CTabItem({
    required this.content,
    this.icon,
    this.title,
  }) {
    assert(
      icon != null || title != null,
      "At least icon or title must have a valid value",
    );
    assert(
      icon is IconData || icon is Image || icon == null,
      "icon can only be an Image / IconData / null type",
    );
  }
}

/// Sets up a channel for allowing the receipt of data from the web content.
typedef CWebChannelCallback = Future<void> Function(dynamic);

/// Enumerations set specifying the allowed actions within the embedded web
/// view when the compile target is web.
enum CSandboxAllow {
  forms("allow-forms"),
  modals("allow-modals"),
  orientationLock("allow-orientation-lock"),
  pointerLock("allow-pointer-lock"),
  popups("allow-popups"),
  popupsToEscapeSandbox("allow-popups-to-escape-sandbox"),
  presentation("allow-presentation"),
  sameOrigin("allow-same-origin"),
  scripts("allow-scripts"),
  topNavigation("allow-top-navigation"),
  topNavigationByUserActivation("allow-top-navigation-by-user-activation");

  final String sandbox;

  const CSandboxAllow(this.sandbox);
}

/// Represents configuration items for the [CWebViewController] specific for
/// the web target when constructing a [codemelted_ui_web_view] widget.
class CWebTargetConfig {
  /// The policy defines what features are available to the
  /// webview element (for example, access to the microphone, camera, battery,
  /// web-share, etc.) based on the origin of the request.
  final String allow;

  /// Whether to allow the embedded web view to request full screen access.
  final bool allowFullScreen;

  /// The set of [CSandboxAllow] permissions for the web view.
  final List<CSandboxAllow> sandbox;

  const CWebTargetConfig({
    this.allow = "",
    this.allowFullScreen = true,
    this.sandbox = const [],
  });
}

/// Sets up the abstract web view controller for being able to change the
/// web page of the embedded view and if necessary, communicate with the loaded
/// page when constructing a [codemelted_ui_web_view] widget.
abstract class CWebViewController {
  /// The [CWebChannelCallback] to receive messages.
  final CWebChannelCallback? onMessageReceived;

  /// A [CWebTargetConfig] when the embedded web view is for the web compiled
  /// target.
  final CWebTargetConfig? webTargetOnlyConfig;

  /// The URL currently loaded in the embedded view widget.
  late String _url;

  /// Sets / gets the currently loaded URL in the embedded web view.
  String get url => _url;
  set url(String v) {
    _url = v;
    onUrlChanged();
  }

  /// Handles the changing of the URL within the web view.
  Future<void> onUrlChanged();

  /// Posts a message to the currently loaded web page.
  Future<void> postMessage(String data);

  /// Utility method to construct a controller for the proper target of
  /// mobile / web.
  static CWebViewController create({
    required String url,
    CWebChannelCallback? onMessageReceived,
    CWebTargetConfig? webTargetOnlyConfig,
  }) {
    return CodeMeltedFlutterPlatform.instance.createWebViewController(
      url: url,
      onMessageReceived: onMessageReceived,
    );
  }

  /// Initial constructor for the controller.
  CWebViewController({
    required String url,
    this.onMessageReceived,
    this.webTargetOnlyConfig,
  }) {
    _url = url;
  }
}
