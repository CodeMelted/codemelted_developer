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

import 'package:logging/logging.dart';

/// Handler to support the codemelted_flutter module for post processing of a
/// logged event.
typedef CLogEventHandler = void Function(CLogRecord);

/// Identifies the supported log levels for the codemelted_flutter module.
enum CLogLevel {
  /// Give me everything going on with this application. I can take it.
  debug(Level.FINE),

  /// Let someone know a services is starting or going away.
  info(Level.INFO),

  /// We encountered something that can be handled or recovered from.
  warning(Level.WARNING),

  /// Danger will robinson, danger.
  error(Level.SEVERE),

  /// It's too much, shut it off.
  off(Level.OFF);

  /// The associated logger level to our more simpler logger.
  final Level level;

  const CLogLevel(this.level);
}

/// Wraps the handle logged event for logging and later processing.
class CLogRecord {
  /// The log record handled by the module logging facility.
  late LogRecord _record;

  CLogRecord(LogRecord r) {
    _record = r;
  }

  /// The time the logged event occurred.
  DateTime get time => _record.time;

  /// The log level associated with the event as a string.
  CLogLevel get level {
    return CLogLevel.values.firstWhere(
      (element) => element.level == _record.level,
    );
  }

  /// The data associated with the logged event.
  String get data => _record.message;

  /// Optional stack trace in the event of an error.
  StackTrace? get stackTrace => _record.stackTrace;

  @override
  String toString() {
    var msg = "${time.toIso8601String()} ${_record.toString()}";
    msg = stackTrace != null ? "$msg\n${stackTrace.toString()}" : msg;
    return msg;
  }
}

/// Creates the first instance of the logger for usage within this module.
final _logger = Logger("CodeMelted-Logger");

/// Will log debug level messages via the module.
void logDebug({Object? data, StackTrace? st}) {
  _logger.log(CLogLevel.debug.level, data, null, st);
}

/// Will log info level messages via the module.
void logInfo({Object? data, StackTrace? st}) {
  _logger.log(CLogLevel.info.level, data, null, st);
}

/// Will log warning level messages via the module.
void logWarning({Object? data, StackTrace? st}) {
  _logger.log(CLogLevel.warning.level, data, null, st);
}

/// Will log error level messages via the module.
void logError({Object? data, StackTrace? st}) {
  _logger.log(CLogLevel.error.level, data, null, st);
}
