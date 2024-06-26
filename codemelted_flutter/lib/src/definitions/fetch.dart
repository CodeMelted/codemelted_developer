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

import 'dart:typed_data';

import 'data_broker.dart';

/// The actions supported by the module fetch call.
enum CFetchAction { delete, get, post, put }

/// The response object that results from the module fetch call.
class CFetchResponse {
  /// The data received.
  final dynamic data;

  /// That status of the  call.
  final int status;

  /// Any text associated with the status.
  final String statusText;

  /// Data is assumed to be a [CObject] JSON format and is returned as such or
  /// null if it is not.
  CObject? get asObject => data as CObject?;

  /// Data is assumed to be a collection of bytes.
  Uint8List get asBytes => data as Uint8List;

  /// Data is assumed to be a String and is returned as such or null if it is
  /// not.
  String? get asString => data as String?;

  /// Constructs the [CFetchResponse] object.
  CFetchResponse(this.data, this.status, this.statusText);
}
