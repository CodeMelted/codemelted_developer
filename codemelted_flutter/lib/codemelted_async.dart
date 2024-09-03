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

/// Provides the ability perform asynchronous programming with flutter in a
/// web environment.
library codemelted_async;

import 'dart:async';
import 'dart:js_interop';

import 'package:codemelted_flutter/codemelted_json.dart';
import "package:web/web.dart" as web;

/// The task to run as part of the different module async functions.
typedef CAsyncTask = Future<dynamic> Function([dynamic]);

/// Message handler that receives a JSON object with two fields. "type" which
/// equals either "error" or "data". Then "data" which contains the actual data
/// received.
typedef CAsyncWorkerListener = void Function(CObject);

/// Definition class for a dedicated FIFO thread separated worker /
/// process. Data is queued to this worker via [CAsyncWorker.postMessage]
/// method and terminated via the [CAsyncWorker.terminate] method.
class CAsyncWorker {
  /// Holds the constructed web worker.
  late web.Worker _worker;

  /// Posts dynamic data to the background worker.
  void postMessage([dynamic data]) => _worker.postMessage(data);

  /// Terminates the dedicated background worker.
  void terminate() => _worker.terminate();

  /// Constructor for this object.
  CAsyncWorker._(CAsyncWorkerListener onDataReceived, String url) {
    _worker = web.Worker(url.toJS);
    _worker.addEventListener(
      "message",
      (e) {
        onDataReceived({
          "type": "data",
          "data": (e as web.MessageEvent).data,
        });
      }.toJS,
    );
    _worker.addEventListener(
      "messageerror",
      (e) {
        onDataReceived({
          "type": "error",
          "data": e.toString(),
        });
      }.toJS,
    );
    _worker.addEventListener(
      "error",
      (e) {
        onDataReceived({
          "type": "error",
          "data": e.toString(),
        });
      }.toJS,
    );
  }
}

/// Implements the Async IO API collecting ways of properly doing asynchronous
/// programming with Flutter within a web environment.
class CodeMeltedAsync {
  /// Identifies the number of processors to facilitate dedicated workers.
  int get hardwareConcurrency => web.window.navigator.hardwareConcurrency;

  /// Will sleep an asynchronous task for the specified delay in milliseconds.
  Future<void> sleep({required int delay}) async {
    return (await Future.delayed(Duration(milliseconds: delay)));
  }

  /// Will process a one off asynchronous task on the main flutter thread.
  Future<dynamic> task({
    required CAsyncTask task,
    dynamic data,
    int delay = 0,
  }) async {
    return (
      await Future.delayed(
        Duration(milliseconds: delay),
        () => task(data),
      ),
    );
  }

  /// Kicks off a timer to schedule tasks on the thread for which it is created
  /// calling the task on the interval specified in milliseconds.
  Timer timer({
    required CAsyncTask task,
    required int interval,
  }) {
    assert(interval > 0, "interval specified must be greater than 0.");
    return Timer.periodic(
      Duration(milliseconds: interval),
      (timer) {
        task();
      },
    );
  }

  /// Creates the [CAsyncWorker] dedicated FIFO worker for background work to
  /// the client. This worker will be written in JavaScript.
  CAsyncWorker worker({
    required CAsyncWorkerListener onDataReceived,
    required String workerUrl,
  }) {
    return CAsyncWorker._(onDataReceived, workerUrl);
  }

  /// Gets the single instance of the API.
  static CodeMeltedAsync? _instance;

  /// Sets up the internal instance for this object.
  factory CodeMeltedAsync() => _instance ?? CodeMeltedAsync._();

  /// Sets up the namespace for the [CodeMeltedAsync] object.
  CodeMeltedAsync._() {
    _instance = this;
  }
}

/// Sets up the namespace for the [CodeMeltedAsync] object.
final codemelted_async = CodeMeltedAsync();
