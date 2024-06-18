// ignore_for_file: non_constant_identifier_names

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

/// A collection of extensions, utility functions, and objects with a minimum
/// set dart / flutter package dependencies. Allow for you to leverage the raw
/// power of flutter to build your cross platform applications for all
/// available flutter targets.
library codemelted_flutter;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:codemelted_flutter/src/stub.dart'
    if (dart.library.io) 'package:codemelted_flutter/src/native.dart'
    if (dart.library.js_interop) 'package:codemelted_flutter/src/web.dart'
    as platform;
import 'package:flutter/foundation.dart';

// ----------------------------------------------------------------------------
// [App View Definitions] -----------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Async IO Definition] ------------------------------------------------------
// ----------------------------------------------------------------------------

/// The task to run as part of the [codemelted_async_task] /
/// [codemelted_async_timer] functions. It defines the logic to run as part of
/// the async call and possibly return a result with the ability to pass the
/// data to process.
typedef CAsyncTask = dynamic Function([dynamic]);

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

/// Base definition class for the returned [codemelted_async_worker] function
/// call to post messages to a dedicated FIFO background worker. For native and
/// mobile targets, this will be an Isolate. For web, it will be a Web Worker.
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

/// Configuration for the [codemelted_async_worker] function when working on
/// native / mobile platforms to have a dedicated FIFO worker to not bog down
/// the main flutter thread.
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

/// Configuration for the [codemelted_async_worker] function when working with
/// an external program / service for your native / mobile environment.
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

/// Configuration for the [codemelted_async_worker] function when working with
/// the web target.
class CWorkerConfig {
  /// Identifies the dedicated JavaScript web worker to carry out our background
  /// processing.
  final String url;

  CWorkerConfig(this.url);
}

/// Will sleep an asynchronous task for the specified delay in milliseconds.
Future<void> codemelted_async_sleep(int delay) async {
  return (await Future.delayed(Duration(milliseconds: delay)));
}

/// Will process a one off asynchronous task either on the main flutter thread
/// or in a background isolate. The isBackground is only supported on native
/// and mobile platforms.
Future<dynamic> codemelted_async_task({
  required CAsyncTask task,
  dynamic data,
  int delay = 0,
  bool isBackground = false,
}) async {
  assert(
    !kIsWeb && isBackground,
    "background processing is only available on native platforms",
  );

  if (isBackground) {
    return (await Isolate.run<dynamic>(() => task(data)));
  }

  return (await Future.delayed(Duration(milliseconds: delay), task(data)));
}

/// Kicks off a timer to schedule tasks on the thread for which it is created
/// calling the task on the interval specified in milliseconds.
Timer codemelted_async_timer({
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

/// @nodoc
CAsyncWorker codemelted_async_worker({
  required CAsyncWorkerListener listener,
  required dynamic config,
}) {
  if (config is CIsolateConfig) {
    return platform.createIsolate(listener: listener, config: config);
  } else if (config is CProcessConfig) {
    return platform.createProcess(listener: listener, config: config);
  } else if (config is CWorkerConfig) {
    return platform.createWorker(listener: listener, config: config);
  }
  throw "codemelted_async_worker did not receive a supported "
      "configuration object";
}

// ----------------------------------------------------------------------------
// [Audio Player Definition] --------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Console] ------------------------------------------------------------------
// ----------------------------------------------------------------------------

// Console is not applicable to flutter as it is a widget based library.

// ----------------------------------------------------------------------------
// [Database Definition] ------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Data Broker Definitions] --------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Device Orientation Definition] --------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Dialog Definition] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Disk Manager Definition] --------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Fetch Definitions] --------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Hardware Device Definition] -----------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Link Opener Definition] ---------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Logger Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Math Definition] ----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Network Socket Definition] ------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Runtime Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Share Definition] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Storage Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Themes Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Web RTC Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Widget Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------
