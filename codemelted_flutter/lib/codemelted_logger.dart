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

/// Provides a basic logging facility to report issues to the browser console
/// along with post processing of events. Also hooks into the Flutter Engine
/// to catch and report any issues un-resolved.
library codemelted_logger;

import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import "package:web/web.dart" as web;

/// Handler to support the codemelted_flutter module for post processing of a
/// logged event.
typedef COnLogEventHandler = Future<void> Function(CLogRecord);

/// Identifies the supported log levels for the codemelted_flutter module.
enum CLogLevel {
  /// Give me everything going on with this application. I can take it.
  debug,

  /// Let someone know a services is starting or going away.
  info,

  /// We encountered something that can be handled or recovered from.
  warning,

  /// Danger will robinson, danger.
  error,

  /// It's too much, shut it off.
  off;
}

/// Wraps the handle logged event for logging and later processing.
class CLogRecord {
  /// The date and time of the log occurrence.
  final DateTime time;

  /// The log level of the logged event.
  final CLogLevel level;

  /// The data associated with the log event.
  final dynamic data;

  /// Optional stack trace for post analysis.
  final StackTrace? stackTrace;

  @override
  String toString() {
    var msg = "${time.toIso8601String()} [$level]: ${data.toString()}";
    msg = stackTrace != null ? "$msg\n${stackTrace.toString()}" : msg;
    return msg;
  }

  /// Constructor for the object.
  CLogRecord({
    required this.time,
    required this.level,
    required this.data,
    this.stackTrace,
  });
}

/// Sets up the logging facility along with hooking into the Flutter Engine for
/// any unhandled errors. Events logged are sent to the browser console with
/// the [onLogEvent] handling more advanced logging if set.
class CodeMeltedLogger {
  /// Holds the currently set logging level for the module
  CLogLevel level = CLogLevel.warning;

  /// Callback for handling log events after they are handled by the module
  /// assuming it meets the current module logging level.
  COnLogEventHandler? onLogEvent;

  /// Will log debug level messages via the module.
  Future<void> debug({dynamic data, StackTrace? stackTrace}) async {
    if (level.index <= CLogLevel.debug.index && level != CLogLevel.off) {
      var record = CLogRecord(
        time: DateTime.now(),
        level: CLogLevel.debug,
        data: data,
        stackTrace: stackTrace,
      );
      web.console.debug(record.toString().toJS);

      if (onLogEvent != null) {
        onLogEvent!(record);
      }
    }
  }

  /// Will log info level messages via the module.
  Future<void> info({dynamic data, StackTrace? stackTrace}) async {
    if (level.index <= CLogLevel.info.index && level != CLogLevel.off) {
      var record = CLogRecord(
        time: DateTime.now(),
        level: CLogLevel.info,
        data: data,
        stackTrace: stackTrace,
      );
      web.console.info(record.toString().toJS);

      if (onLogEvent != null) {
        onLogEvent!(record);
      }
    }
  }

  /// Will log warning level messages via the module.
  Future<void> warning({dynamic data, StackTrace? stackTrace}) async {
    if (level.index <= CLogLevel.warning.index && level != CLogLevel.off) {
      var record = CLogRecord(
        time: DateTime.now(),
        level: CLogLevel.info,
        data: data,
        stackTrace: stackTrace,
      );
      web.console.warn(record.toString().toJS);

      if (onLogEvent != null) {
        onLogEvent!(record);
      }
    }
  }

  /// Will log error level messages via the module.
  Future<void> error({dynamic data, StackTrace? stackTrace}) async {
    if (level.index <= CLogLevel.error.index && level != CLogLevel.off) {
      var record = CLogRecord(
        time: DateTime.now(),
        level: CLogLevel.info,
        data: data,
        stackTrace: stackTrace,
      );
      web.console.error(record.toString().toJS);

      if (onLogEvent != null) {
        onLogEvent!(record);
      }
    }
  }

  /// Holds the private instance of the API.
  static CodeMeltedLogger? _instance;

  /// Gets the single instance of the API.
  factory CodeMeltedLogger() => _instance ?? CodeMeltedLogger._();

  /// Sets up the internal instance for this object.
  CodeMeltedLogger._() {
    _instance = this;
    FlutterError.onError = (details) {
      error(data: details.exception.toString(), stackTrace: details.stack);
    };

    PlatformDispatcher.instance.onError = (err, st) {
      error(data: err.toString(), stackTrace: st);
      return true;
    };
  }
}

/// Sets up the utility namespace for the [CodeMeltedLogger].
final codemelted_logger = CodeMeltedLogger();
