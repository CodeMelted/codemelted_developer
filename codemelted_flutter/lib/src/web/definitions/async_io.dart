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

import "package:web/web.dart" as web;

import 'package:codemelted_flutter/src/definitions/async_io.dart';

/// Implements the [CAsyncWorker] object for a dedicated web worker written
/// in JavaScript and hosted via the specified URL.
class CWebWorker extends CAsyncWorker {
  /// The url to the dedicated web worker.
  final String url;

  /// The dedicated Web Worker constructed from the URL.
  late web.Worker _worker;

  @override
  void postMessage([data]) => _worker.postMessage(data);

  @override
  void terminate() => _worker.terminate();

  CWebWorker(super.listener, this.url) {
    _worker = web.Worker(url);
    _worker.addEventListener(
      "message",
      (e) {
        onDataReceived(CAsyncWorkerData(false, (e as web.MessageEvent).data));
      } as web.EventListener?,
    );
    _worker.addEventListener(
      "messageerror",
      (e) {
        onDataReceived(CAsyncWorkerData(true, e.toString()));
      } as web.EventListener?,
    );
    _worker.addEventListener(
      "error",
      (e) {
        onDataReceived(CAsyncWorkerData(true, e.toString()));
      } as web.EventListener?,
    );
  }
}
