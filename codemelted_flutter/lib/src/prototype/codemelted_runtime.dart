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

/// Collection of items related to the web runtime for the flutter app not
/// covered by any of the other modules specific use case.
library codemelted_runtime;

import 'dart:js_interop';

import 'package:codemelted_flutter/src/prototype/codemelted_logger.dart';
import 'package:flutter/services.dart';
import "package:web/web.dart" as web;

// TODO: share, properties, etc.

/// Represents an event listener for registering with web runtime events.
typedef CHtmlEventListener = void Function(web.Event);

/// Optional parameter for the mailto scheme to facilitate translating the more
/// complicated URL.
class CMailToParams {
  /// The list of email addresses to send the email.
  final List<String> mailto;

  /// The carbon copies to send the email.
  final List<String> cc;

  /// The blind carbon copies to send the email.
  final List<String> bcc;

  /// The subject of the email.
  final String subject;

  /// The body of the email.
  final String body;

  @override
  String toString() {
    var url = "";

    // Go format the mailto part of the url
    url += "$mailto;";
    url = url.substring(0, url.length - 1);

    // Go format the cc part of the url
    var delimiter = "?";
    if (cc.isNotEmpty) {
      url += "${delimiter}cc=";
      delimiter = "&";
      for (final e in cc) {
        url += "$e;";
      }
      url = url.substring(0, url.length - 1);
    }

    // Go format the bcc part of the url
    if (bcc.isNotEmpty) {
      url += "${delimiter}bcc=";
      delimiter = "&";
      for (final e in bcc) {
        url += "$e;";
      }
      url = url.substring(0, url.length - 1);
    }

    // Go format the subject part
    if (subject.trim().isNotEmpty) {
      url += "${delimiter}subject=${subject.trim()}";
      delimiter = "&";
    }

    // Go format the body part
    if (body.trim().isNotEmpty) {
      url += "${delimiter}body=${body.trim()}";
      delimiter = "&";
    }

    return url;
  }

  /// Constructs the object.
  CMailToParams({
    required this.mailto,
    this.cc = const <String>[],
    this.bcc = const <String>[],
    this.subject = "",
    this.body = "",
  });
}

/// Identifies the scheme to utilize as part of the module open
/// function.
enum CSchemeType {
  /// Will open the program associated with the file.
  file("file:"),

  /// Will open a web browser with http.
  http("http://"),

  /// Will open a web browser with https.
  https("https://"),

  /// Will open the default email program to send an email.
  mailto("mailto:"),

  /// Will open the default telephone program to make a call.
  tel("tel:"),

  /// Will open the default texting app to send a text.
  sms("sms:");

  /// Identifies the leading scheme to form a URL.
  final String leading;

  const CSchemeType(this.leading);

  /// Will return the formatted URL based on the scheme and the
  /// data provided.
  String getUrl(String data) => "$leading$data";
}

/// Binds a series of properties and utility methods that are specific to the
/// web runtime.
class CodeMeltedRuntime {
  /// Connects a [CHtmlEventListener] to either the window or an event target
  /// object.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/addEventListener
  void addEventListener({
    required String type,
    required CHtmlEventListener listener,
    web.EventTarget? obj,
  }) {
    if (obj == null) {
      web.window.addEventListener(type, listener.toJS);
    } else {
      obj.addEventListener(type, listener.toJS);
    }
  }

  /// Copies data to the system clipboard
  Future<void> copyToClipboard({required String data}) async {
    return Clipboard.setData(ClipboardData(text: data));
  }

  /// Searches the URLSearchParams for any passed key values.
  String? environment({required String key}) {
    var urlParams = web.URLSearchParams(web.window.location.search as JSAny);
    return urlParams.get(key);
  }

  /// Determines if the web app is an installed PWA or not.
  bool get isPWA {
    var queries = [
      '(display-mode: fullscreen)',
      '(display-mode: standalone)',
      '(display-mode: minimal-ui),'
    ];
    var pwaDetected = false;
    for (var query in queries) {
      pwaDetected = pwaDetected || web.window.matchMedia(query).matches;
    }
    return pwaDetected;
  }

  /// Loads a specified resource into a new or existing browsing context
  /// (that is, a tab, a window, or an iframe) under a specified name. These
  /// are based on the different [CSchemeType] supported protocol items.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/API/Window/open
  Future<web.Window?> open({
    required CSchemeType scheme,
    bool popupWindow = false,
    CMailToParams? mailtoParams,
    String? url,
    String target = "_blank",
    double? width,
    double? height,
  }) async {
    try {
      var urlToLaunch = "";
      if (scheme == CSchemeType.file ||
          scheme == CSchemeType.http ||
          scheme == CSchemeType.https ||
          scheme == CSchemeType.sms ||
          scheme == CSchemeType.tel) {
        urlToLaunch = scheme.getUrl(url!);
      } else {
        urlToLaunch = mailtoParams != null
            ? scheme.getUrl(mailtoParams.toString())
            : scheme.getUrl(url!);
      }

      if (popupWindow) {
        var w = width ?? 900.0;
        var h = height ?? 600.0;
        var top = (web.window.screen.height - h) / 2;
        var left = (web.window.screen.width - w) / 2;
        var settings = "toolbar=no, location=no, "
            "directories=no, status=no, menubar=no, "
            "scrollbars=no, resizable=yes, copyhistory=no, "
            "width=$w, height=$h, top=$top, left=$left";
        return web.window.open(
          urlToLaunch,
          "_blank",
          settings,
        );
      }

      return web.window.open(urlToLaunch, target);
    } catch (ex, st) {
      codemelted_logger.error(data: ex, stackTrace: st);
      return null;
    }
  }

  /// Will print the current web page.
  void print() {
    web.window.print();
  }

  /// Removes a [CHtmlEventListener] to either the window or an event target
  /// object.
  ///
  /// See https://developer.mozilla.org/en-US/docs/Web/API/EventTarget/removeEventListener
  void removeEventListener({
    required String type,
    required CHtmlEventListener listener,
    web.EventTarget? obj,
  }) {
    if (obj == null) {
      web.window.removeEventListener(type, listener.toJS);
    } else {
      obj.removeEventListener(type, listener.toJS);
    }
  }

  /// Gets the single instance of the API.
  static CodeMeltedRuntime? _instance;

  /// Sets up the internal instance for this object.
  factory CodeMeltedRuntime() => _instance ?? CodeMeltedRuntime._();

  /// Sets up the namespace for the [CodeMeltedRuntime] object.
  CodeMeltedRuntime._() {
    _instance = this;
  }
}

/// Sets up the namespace for the [CodeMeltedRuntime] object.
final codemelted_runtime = CodeMeltedRuntime();
