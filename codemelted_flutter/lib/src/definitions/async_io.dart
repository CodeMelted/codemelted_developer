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

/// The task to run as part of the different module async functions.
typedef CAsyncTask = Future<dynamic> Function([dynamic]);

/// Identifies the data reported via the [CAsyncWorkerListener] so appropriate
/// action can be taken.
class CAsyncWorkerData {
  /// Signals whether the data is an error or not.
  final bool isError;

  /// The data processed by the [CAsyncWorker].
  final dynamic data;

  /// Constructor for the object.
  CAsyncWorkerData(this.isError, this.data);
}

/// Listener for data received via the dedicated [CAsyncWorker] so an
/// application can respond to those events.
typedef CAsyncWorkerListener = void Function(CAsyncWorkerData);

/// Base definition class for a dedicated FIFO thread separated worker /
/// process. Data is queued to this worker via [CAsyncWorker.postMessage] method
/// and terminated via the [CAsyncWorker.terminate] method.
abstract class CAsyncWorker {
  /// Posts dynamic data to the background worker.
  void postMessage([dynamic data]);

  /// Terminates the dedicated background worker.
  void terminate();

  /// Holds the listener for the dedicated worker.
  final CAsyncWorkerListener onDataReceived;

  /// Super constructor for the base object.
  CAsyncWorker(this.onDataReceived);
}

/// Configuration to support native workers spawned as Isolates within your
/// Flutter application implementing the [CAsyncWorker] interface.
class CIsolateConfig {
  /// The task that represents the main Isolate worker logic within the loop.
  /// The returned result from the task will be communicated via the
  /// [CAsyncWorkerListener] setup as part of the [CAsyncWorker] object.
  final CAsyncTask task;

  /// Optional function to create a set of singleton objects that will support
  /// the [CAsyncTask] task that are built and accessible in the Isolate event
  /// loop.
  final void Function()? factoryWorkers;

  CIsolateConfig({required this.task, this.factoryWorkers});
}

/// Configuration for communicating with an external program / service on your
/// native platform via the [CAsyncWorker] interface.
class CProcessConfig {
  /// The outside command to interface the application with.
  final String executable;

  /// The arguments to associate when kicking off the command.
  final List<String> arguments;

  /// Identify the working directory for the command when executed.
  final String? workingDirectory;

  /// Specify environment variables for the process to have access.
  final Map<String, String>? environment;

  /// Whether to include the parent working environment of the flutter app
  /// kicking off the process.
  final bool includeParentEnvironment;

  /// Whether to run the process in a shell or not.
  final bool runInShell;

  /// The mode to execute the process in.
  final ProcessStartMode mode;

  CProcessConfig({
    required this.executable,
    this.arguments = const [],
    this.workingDirectory,
    this.environment,
    this.includeParentEnvironment = true,
    this.runInShell = false,
    this.mode = ProcessStartMode.normal,
  });
}

/// Configuration for working with a dedicated Web Worker written in JavaScript
/// when working on the web target.
class CWorkerConfig {
  /// Identifies the dedicated JavaScript web worker to carry out our background
  /// processing.
  final String url;

  CWorkerConfig(this.url);
}
