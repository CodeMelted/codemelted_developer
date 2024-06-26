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

import 'package:url_launcher/url_launcher.dart';

/// Represents how the module launches a [CSchemeType].
typedef LaunchUrlStringHandler = Future<bool> Function(
  String urlString, {
  LaunchMode mode,
  WebViewConfiguration webViewConfiguration,
  String? webOnlyWindowName,
});

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
    for (final e in mailto) {
      url += "$e;";
    }
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
