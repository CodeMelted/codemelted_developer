// ignore_for_file: unused_element, constant_identifier_names
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

/// A collection of extensions, utility objects, and widgets with only
/// dart/flutter team package dependencies. So you are using the raw just the
/// raw power power of flutter. Include this file into your project
/// along with the dart/flutter team dependencies and away you go.
library codemelted_flutter;

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logging/logging.dart';
import 'package:universal_html/html.dart';

/// Identifies the version of the module based on the CodeMelted - Module
/// design.
const moduleVersion = "X.Y.Z-alpha [2024-02-15]";

// ============================================================================
// [Async IO Use Case] ===========================================================
// ============================================================================

/// The task to run as part of the [CAsyncTask] utility object. It defines the
/// logic to run as part of the async call and possibly return a result.
typedef CAsyncTask = dynamic Function([dynamic]);

/// Utility class for handling async work. It provides a series of static
/// methods for working within Flutter's async architecture. It object itself
/// is returned for long living async tasks with the ability to post messages
/// and terminate them when completed.
class CAsyncIO {
  // Member Fields:
  late dynamic _asyncObj;
  late SendPort? _sendPort;
  late ReceivePort? _receivePort;

  CAsyncIO._({
    dynamic asyncObj,
    SendPort? sendPort,
    ReceivePort? receivePort,
  }) {
    _asyncObj = asyncObj;
    _sendPort = sendPort;
    _receivePort = receivePort;
  }

  /// Supports sending data to a dedicated isolate spawned via
  /// [CAsyncIO.worker].
  void postMessage([dynamic data]) {
    if (_asyncObj is Worker) {
      (_asyncObj as Worker).postMessage(data);
      return;
    }

    // Isolate, send the data.
    _sendPort!.send(data);
  }

  /// Supports the termination of long running async task spawned by
  /// [CAsyncIO.interval] or [CAsyncIO.worker].
  void terminate() {
    if (_asyncObj is Timer) {
      (_asyncObj as Timer).cancel();
    } else if (_asyncObj is Isolate) {
      (_asyncObj as Isolate).kill(priority: Isolate.immediate);
      _sendPort = null;
      _receivePort?.close();
      _receivePort = null;
    } else if (_asyncObj is Worker) {
      (_asyncObj as Worker).terminate();
    }
  }

  /// Spawns a background isolate to run the specified task and if part of the
  /// task, return the result. Only available on desktop and mobile platforms.
  static Future<dynamic> background({
    required CAsyncTask task,
    dynamic data,
  }) async {
    assert(!kIsWeb, "This is only available on native platforms");
    return Isolate.run<dynamic>(() => task(data));
  }

  /// Spawns a Timer for executing a repeating task. It is canceled via the
  /// [CAsyncIO.terminate] method.
  static CAsyncIO interval({
    required CAsyncTask task,
    required int delay,
  }) {
    final timer = Timer.periodic(Duration(milliseconds: delay), (timer) {
      task();
    });
    return CAsyncIO._(asyncObj: timer);
  }

  /// UNDER DEVELOPMENT - NOT IMPLEMENTED YET
  static CAsyncIO process() {
    assert(!kIsWeb, "CAsyncIO.process not available on web targets");
    throw "NOT IMPLEMENTED YET";
  }

  /// Provides the ability to await a specified number of milliseconds before
  /// proceeding to the next async task.
  static Future<void> sleep(int delay) async => await Future.delayed(
        Duration(milliseconds: delay),
      );

  /// Spawns a future task that can return a result when completed. Only
  /// executes the one time and cannot be canceled.
  static Future<dynamic> timeout({
    required CAsyncTask task,
    dynamic data,
    int delay = 0,
  }) async {
    return Future.delayed(
      Duration(milliseconds: delay),
      () => task(data),
    );
  }

  /// Provides the ability to spawn a dedicated worker. The task represents
  /// the background processor of the worker. The returned [CAsyncIO] wraps
  /// either an Isolate (mobile, desktop) or a Worker (web). Call
  /// [CAsyncIO.postMessage] to queue up data to be worked by the task.
  /// Call [CAsyncIO.terminate] to destroy the worker. Errors processed within
  /// the background will be received on the [CAsyncTask] onReceived as a
  /// String.
  static Future<CAsyncIO> worker({
    CAsyncTask? task,
    String? workerUrl,
    required CAsyncTask onReceived,
  }) async {
    return !kIsWeb
        ? await _buildIsolate(task!, onReceived)
        : _buildWorker(workerUrl!, onReceived);
  }

  /// Helper method to build a dedicated worker Isolate.
  static Future<CAsyncIO> _buildIsolate(
    CAsyncTask task,
    CAsyncTask onReceived,
  ) async {
    // Setup the receive port and spawn the isolate.
    ReceivePort receive = ReceivePort();
    var isolate = await Isolate.spawn<SendPort>((port) {
      // TODO: Investigate an initialize to setup other object
      //       within the isolate and access to the send port
      //       to queue data for the listen.
      ReceivePort receivePort = ReceivePort();
      port.send(receivePort.sendPort);
      receivePort.listen((data) async {
        dynamic result;
        try {
          result = await task(data);
        } catch (ex, st) {
          CLogger.log(
            level: CLogger.error,
            data: ex.toString(),
            st: st,
          );
          result = ex.toString();
        }
        port.send(result);
      });
    }, receive.sendPort);

    // Now setup the receive listener.
    SendPort? sendPort;
    receive.listen((result) {
      if (result is SendPort) {
        sendPort = result;
      } else {
        onReceived(result);
      }
    });
    await sleep(250);

    // Return the build async io object.
    return CAsyncIO._(
      asyncObj: isolate,
      sendPort: sendPort,
      receivePort: receive,
    );
  }

  /// Helper method to build a dedicated web worker.
  static CAsyncIO _buildWorker(String workerUrl, CAsyncTask onReceived) {
    var worker = Worker(workerUrl);
    worker.addEventListener(
      "message",
      (event) => onReceived((event as MessageEvent).data),
    );
    worker.addEventListener(
      "messageerror",
      (event) {
        CLogger.log(
          level: CLogger.error,
          data: event.toString(),
          st: StackTrace.current,
        );
        onReceived(event.toString());
      },
    );
    worker.addEventListener(
      "error",
      (event) {
        CLogger.log(
          level: CLogger.error,
          data: event.toString(),
          st: StackTrace.current,
        );
        onReceived(event.toString());
      },
    );
    return CAsyncIO._(asyncObj: worker);
  }
}

// ============================================================================
// [Audio Player Use Case] ====================================================
// ============================================================================

/// Identifies the source for the [CAudioPlayer.file] for a file playback.
enum CAudioSource {
  /// A bundled asset with your application
  asset,

  /// A file on the file system probably chosen via file picker
  file,

  /// A internet resource to download and play
  url,
}

/// Identifies the state of the [CAudioPlayer] object.
enum CAudioState {
  /// Currently in a playback mode.
  playing,

  /// Audio has been paused.
  paused,

  /// Audio has been stopped and will reset with playing.
  stopped,
}

/// Provides the ability to play audio files or perform text to speech
/// within your application.
class CAudioPlayer {
  // Member Fields:
  CAudioState _state = CAudioState.stopped;
  late dynamic _data;
  late dynamic _player;

  CAudioPlayer._(dynamic player, dynamic data) {
    _data = data;
    _player = player;
  }

  /// Identifies the current state of the audio player.
  CAudioState get state => _state;

  /// Plays or resumes a paused audio source.
  Future<void> play() async {
    if (_state != CAudioState.paused || _state != CAudioState.stopped) {
      return;
    }

    if (_player is FlutterTts) {
      (_player as FlutterTts).speak(_data);
    } else {
      if (_state == CAudioState.paused) {
        (_player as AudioPlayer).resume();
      } else {
        (_player as AudioPlayer).play(_data);
      }
    }
    _state = CAudioState.playing;
  }

  /// Stops the playing audio source.
  Future<void> stop() async {
    if (_state != CAudioState.playing || _state != CAudioState.paused) {
      return;
    }

    if (_player is FlutterTts) {
      (_player as FlutterTts).stop();
    } else {
      (_player as AudioPlayer).stop();
    }
    _state = CAudioState.stopped;
  }

  /// Pauses a currently playing audio source.
  Future<void> pause() async {
    if (_state != CAudioState.playing) {
      return;
    }

    if (_player is FlutterTts) {
      (_player as FlutterTts).pause();
    } else {
      (_player as AudioPlayer).pause();
    }
    _state = CAudioState.paused;
  }

  /// Disposes of the audio player and resources.
  Future<void> dispose() async {
    if (_player is FlutterTts) {
      await (_player as FlutterTts).stop();
      _player = null;
      _data = null;
    } else {
      await (_player as AudioPlayer).stop();
      await (_player as AudioPlayer).dispose();
      _player = null;
      _data = null;
    }
  }

  /// Builds a [CAudioPlayer] identifying an audio source and specifying the
  /// location of said audio source.
  static Future<CAudioPlayer> file({
    required String data,
    required CAudioSource source,
    double volume = 0.5,
    double balance = 0.0,
    double rate = 1.0,
    AudioPlayer? mock,
  }) async {
    final player = mock ?? AudioPlayer();
    await player.setVolume(volume);
    await player.setPlaybackRate(rate);
    await player.setBalance(balance);
    var audioSource = source == CAudioSource.asset
        ? AssetSource(data)
        : source == CAudioSource.file
            ? DeviceFileSource(data)
            : UrlSource(data);
    player.onLog.listen((event) {
      CLogger.log(level: CLogger.error, data: event, st: StackTrace.current);
    });
    return CAudioPlayer._(player, audioSource);
  }

  /// Builds a [CAudioPlayer] to perform text to speech of the specified data.
  static Future<CAudioPlayer> tts({
    required String data,
    double volume = 0.5,
    double pitch = 1.0,
    double rate = 0.5,
    FlutterTts? mock,
  }) async {
    final player = mock ?? FlutterTts();
    await player.setPitch(pitch);
    await player.setVolume(volume);
    await player.setSpeechRate(rate);
    player.setErrorHandler((message) {
      CLogger.log(level: CLogger.error, data: message, st: StackTrace.current);
    });
    return CAudioPlayer._(player, data);
  }
}

// ============================================================================
// [Data Use Case] ============================================================
// ============================================================================

/// Defines an array definition to match JSON Array construct.
typedef CArray = List<dynamic>;

/// Provides helper methods for the CArray.
extension CArrayExtension on CArray {
  /// Converts the JSON object to a string returning null if it cannot
  String? stringify() => jsonEncode(this);
}

/// Defines an object definition to match a valid JSON Object construct.
typedef CObject = Map<String, dynamic>;

/// Provides helper methods for the CObject
extension CObjectExtension on CObject {
  /// Converts the JSON object to a string returning null if it cannot.
  String? stringify() => jsonEncode(this);
}

/// Provides a series of asXXX() conversion from a string data type and do non
/// case sensitive compares.
extension CStringExtension on String {
  /// Will attempt to return an array object ir null if it cannot.
  CArray? asArray() {
    try {
      return jsonDecode(this) as CArray?;
    } catch (ex) {
      return null;
    }
  }

  /// Will attempt to convert to a bool from a series of strings that can
  /// represent a true value.
  bool asBool() {
    List<String> trueStrings = [
      "true",
      "1",
      "t",
      "y",
      "yes",
      "yeah",
      "yup",
      "certainly",
      "uh-huh"
    ];
    return trueStrings.contains(toLowerCase());
  }

  /// Will attempt to return a int from the string value or null if it cannot.
  int? asInt() => int.tryParse(this);

  /// Will attempt to return a double from the string value or null if it
  /// cannot.
  double? asDouble() => double.tryParse(this);

  /// Will attempt to return Map<String, dynamic> object or null if it cannot.
  CObject? asObject() {
    try {
      return jsonDecode(this) as CObject?;
    } catch (ex) {
      return null;
    }
  }

  /// Determines if a string is contained within this string.
  bool containsIgnoreCase(String v) => toLowerCase().contains(v.toLowerCase());

  /// Determines if a string is equal to another ignoring case.
  bool equalsIgnoreCase(String v) => toLowerCase() == v.toLowerCase();
}

/// Utility object to validate, serialize, and deserialize JSON data. This
/// works in conjunction with the [CStringExtension]. Utilize those extensions
/// on string to convert between basic data types.
class CDataBroker {
  /// Determines if a [CObject] has a given property contained within.
  static bool checkHasProperty(CObject obj, String key) => obj.containsKey(key);

  /// Determines if the variable is of the expected type.
  static bool checkType<T>(dynamic v) => v is T;

  /// Determines if the data type is a valid URL.
  static bool checkValidURL(String v) => Uri.tryParse(v) != null;

  /// Will convert data into a JSON [CObject] or return null if the decode
  /// could not be achieved.
  static CObject? jsonParse(String data) => data.asObject();

  /// Will encode the JSON [CObject] into a string or null if the encode
  /// could not be achieved.
  static String? jsonStringify(CObject data) => data.stringify();

  /// Same as [checkHasProperty] but throws an exception if the key is not
  /// found.
  static void tryHasProperty(CObject obj, String key) {
    if (!checkHasProperty(obj, key)) {
      throw "obj does not contain '$key' key";
    }
  }

  /// Same as [checkType] but throws an exception if not of the expected
  /// type.
  static void tryType<T>(dynamic v) {
    if (!checkType<T>(v)) {
      throw "variable was not of type '$T'";
    }
  }

  /// Same as [checkValidURL] but throws an exception if not a valid URL type.
  static void tryValidURL(String v) {
    if (!checkValidURL(v)) {
      throw "v was not a valid URL string";
    }
  }
}

// ============================================================================
// [Database Use Case] ========================================================
// ============================================================================

class CDatabase {}

// ============================================================================
// [Logger Use Case] ==========================================================
// ============================================================================

/// Handler to support the [CLogger] for post processing of a logged event.
typedef CLoggedEventHandler = void Function(CLogRecord);

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
  CLogger get level {
    return CLogger.values.firstWhere(
      (element) => element._level == _record.level,
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

/// This enumeration provides a basic logging utility for your flutter
/// application. The static methods attached to the enum allow for setting
/// the module log level and attach any post processing of the logger.
enum CLogger {
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
  final Level _level;

  const CLogger(this._level);

  // Utility member fields
  static final _logger = Logger("CodeMelted-Logger");

  /// Establishes the [CLoggedEventHandler] to facilitate post log processing
  /// of a module logged event.
  static CLoggedEventHandler? onLoggedEvent;

  /// Initializes the logging facility hooking into the Flutter runtime
  /// for any possible errors along with setting the initial log level to
  /// warning and hooking up a console print capability for debug mode
  /// of your application.
  static void init() {
    // Hookup into the flutter runtime error handlers so any error it
    // encounters, is also reported.
    FlutterError.onError = (details) {
      log(level: CLogger.error, data: details.exception, st: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, st) {
      log(level: CLogger.error, data: error.toString(), st: st);
      return true;
    };

    // Now configure our logger items.
    Logger.root.level = CLogger.warning._level;
    Logger.root.onRecord.listen((v) {
      var record = CLogRecord(v);
      if (kDebugMode) {
        print(record);
      }

      if (onLoggedEvent != null) {
        onLoggedEvent!(record);
      }
    });
  }

  /// Sets / gets the logging level of the module logging facility
  static set logLevel(CLogger v) => Logger.root.level = v._level;
  static CLogger get logLevel {
    return CLogger.values.firstWhere(
      (element) => element._level == Logger.root.level,
    );
  }

  /// Utility method to log an event within your application.
  static void log({required CLogger level, Object? data, StackTrace? st}) {
    _logger.log(level._level, data, null, st);
  }
}

// ============================================================================
// [Math Use Case] ============================================================
// ============================================================================

/// Support definition for the [CMath.calculate] utility method.
typedef CMathFormula = double Function(List<double>);

/// Utility providing a collection of mathematical formulas that you can get
/// the answer to life's biggest questions.
class CMath {
  /// Kilometers squared to meters squared
  static const String area_km2_to_m2 = "area_km2_to_m2";

  /// Sets up the mapping of formulas for the calculate method.
  static final _map = <String, CMathFormula>{
    area_km2_to_m2: (v) => v[0] * 1e+6,
  };

  /// Executes the given formula with the specified variables.
  static double calculate(String formula, List<double> vars) {
    assert(
      _map[formula] != null,
      "CMath.calc() formula specified does not exist",
    );
    return _map[formula]!(vars);
  }
}

// // ============================================================================
// // [RestAPI Use Case] ===========================================================
// // ============================================================================

// class CRestAPI {}

// ============================================================================
// [Runtime Use Case] ==========================================================
// ============================================================================
// run command