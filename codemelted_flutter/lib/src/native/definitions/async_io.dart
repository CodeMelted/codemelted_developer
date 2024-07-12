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

import 'dart:isolate';

import 'package:codemelted_flutter/src/definitions/async_io.dart';

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

/// TBD
class CProcessWorker extends CAsyncWorker {
  CProcessWorker(super.onDataReceived);

  @override
  void postMessage([data]) {
    // TODO: implement postMessage
  }

  @override
  void terminate() {
    // TODO: implement terminate
  }
}
