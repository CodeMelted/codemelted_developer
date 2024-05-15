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

/// A collection of extensions, utility objects, and widgets with a minimum set
/// dart/flutter package dependencies. Allow for you to leverage the raw power
/// of flutter to build your cross platform applications for all available
/// flutter targets.
library codemelted_flutter;

// import 'dart:async';
import 'dart:convert';

import 'package:codemelted_flutter/platform/stub.dart'
    if (dart.library.io) 'package:codemelted_flutter/platform/native.dart'
    if (dart.library.js) 'package:codemelted_flutter/platform/web.dart'
    as platform;

// import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:http/http.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

// ============================================================================
// [Core Use Cases] ===========================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [Async IO] -----------------------------------------------------------------
// ----------------------------------------------------------------------------

// /// The task to run as part of the [CAsyncTask] utility object. It defines the
// /// logic to run as part of the async call and possibly return a result.
// typedef CAsyncTaskFunction = dynamic Function([dynamic]);

// /// Utility class for handling one off [CAsyncTaskFunction] work. It can be
// /// handled via [CAsyncTask.background] for spawning a background isolate
// /// (only available on native), [CAsyncTask.timeout] for spawning it on the
// /// main thread, or as a [CAsyncTask.interval] repeating task. You can also
// /// [CAsyncTask.sleep] a task.
// class CAsyncTask {
//   /// Spawns a background isolate to run the specified task and if part of the
//   /// task, return the result. Only available on desktop and mobile platforms.
//   static Future<dynamic> background({
//     required CAsyncTaskFunction task,
//     dynamic data,
//   }) async {
//     assert(!kIsWeb, "This is only available on native platforms");
//     return Isolate.run<dynamic>(() => task(data));
//   }

//   /// Spawns a Timer for executing a repeating task. It is canceled via the
//   /// [Timer.cancel] method.
//   static Timer interval({
//     required CAsyncTaskFunction task,
//     required int delay,
//   }) {
//     final timer = Timer.periodic(Duration(milliseconds: delay), (timer) {
//       task();
//     });
//     return timer;
//   }

//   /// Provides the ability to await a specified number of milliseconds before
//   /// proceeding to the next async task.
//   static Future<void> sleep(int delay) async => await Future.delayed(
//         Duration(milliseconds: delay),
//       );

//   /// Spawns a future task that can return a result when completed. Only
//   /// executes the one time and cannot be canceled.
//   static Future<dynamic> timeout({
//     required CAsyncTaskFunction task,
//     dynamic data,
//     int delay = 0,
//   }) async {
//     return Future.delayed(
//       Duration(milliseconds: delay),
//       () => task(data),
//     );
//   }
// }

// /// Supports the receipt of data via the [CAsyncWorker] dedicated background
// /// FIFO queued processor.
// typedef CAsyncWorkerListener = void Function(dynamic);

// /// Creates a dedicated FIFO queued background worker for processing data
// /// off the main thread communicating those results via the
// /// [CAsyncWorkerListener].
// class CAsyncWorker {
//   // Member Fields:
//   late dynamic _asyncObj;

//   /// Constructor for the object.
//   CAsyncWorker._({
//     dynamic asyncObj,
//     SendPort? sendPort,
//     ReceivePort? receivePort,
//   }) {
//     _asyncObj = asyncObj;
//   }

//   /// Supports sending data specific to the background worker to process and
//   /// return the results via the [CAsyncWorkerListener].
//   void postMessage([dynamic data]) {
//     if (_asyncObj is html.Worker) {
//       (_asyncObj as html.Worker).postMessage(data);
//     }
//   }

//   /// Terminates this dedicated worker object making it no longer available.
//   void terminate() {
//     if (_asyncObj is html.Worker) {
//       (_asyncObj as html.Worker).terminate();
//     }
//   }

//   /// @nodoc
//   static CAsyncWorker process() {
//     assert(!kIsWeb, "CAsyncIO.process not available on web targets");
//     throw "NOT IMPLEMENTED YET";
//   }

//   /// Spawns a dedicated web worker written in JavaScript represented by the
//   /// specified url. This is only valid for the web target.
//   static CAsyncWorker webWorker({
//     required String url,
//     required CAsyncWorkerListener onReceived,
//   }) {
//     assert(
//       kIsWeb,
//       "CAsyncWorker.webWorker() is only available on the web target.",
//     );
//     var worker = html.Worker(url);
//     worker.addEventListener(
//       "message",
//       (event) => onReceived((event as html.MessageEvent).data),
//     );
//     worker.addEventListener(
//       "messageerror",
//       (event) {
//         CLogger.log(
//           level: CLogger.error,
//           data: event.toString(),
//           st: StackTrace.current,
//         );
//         onReceived(event.toString());
//       },
//     );
//     worker.addEventListener(
//       "error",
//       (event) {
//         CLogger.log(
//           level: CLogger.error,
//           data: event.toString(),
//           st: StackTrace.current,
//         );
//         onReceived(event.toString());
//       },
//     );
//     return CAsyncWorker._(asyncObj: worker);
//   }
// }

// ----------------------------------------------------------------------------
// [Data Broker] --------------------------------------------------------------
// ----------------------------------------------------------------------------

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

/// [CObject] wrapper allowing for using generics to map the data along with
/// extending a [ChangeNotifier] allowing for alerting listeners to data
/// changes with the internal data object.
class CObjectDataNotifier extends ChangeNotifier {
  /// Holds the [CObject] data map.
  final _data = CObject();

  /// Constructor for the object with the ability to initialize it from the
  /// named parameters
  CObjectDataNotifier({CObject? objData, String? strData}) {
    assert(
      (objData != null && strData == null) ||
          (objData == null && strData != null) ||
          (objData == null && strData == null),
      "Only one object can be used for initialization or none at all",
    );
    if (objData != null) {
      _data.addAll(objData);
    } else if (strData != null) {
      final data = strData.asObject();
      if (data != null) {
        _data.addAll(data);
      }
    }
  }

  /// Provides a method to set data elements within the internal [CObject].
  void set<T>(String key, T value, {bool notify = false}) {
    _data[key] = value;
    if (notify) {
      notifyListeners();
    }
  }

  /// Provides the ability to extract the data element from the internal
  /// [CObject].
  T get<T>(String key) {
    return _data[key];
  }

  /// Utility to get a String representation of the [CObject]
  String? stringify() => _data.stringify();
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

  /// Will attempt to return a double from the string value or null if it
  /// cannot.
  num? asDouble() => double.tryParse(this);

  /// Will attempt to return a int from the string value or null if it cannot.
  num? asInt() => int.tryParse(this);

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

// ----------------------------------------------------------------------------
// [File Explorer] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Logger] -------------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Handler to support the [CLogger] for post processing of a logged event.
typedef CLogEventHandler = void Function(CLogRecord);

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
  static CLogEventHandler? onLoggedEvent;

  /// Tracks if the logger has been properly initialized.
  static bool _isInitialized = false;

  /// Initializes the logging facility hooking into the Flutter runtime
  /// for any possible errors along with setting the initial log level to
  /// warning and hooking up a console print capability for debug mode
  /// of your application.
  static void init() {
    if (!_isInitialized) {
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
      _isInitialized = true;
    }
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
    assert(_isInitialized, "CLogger.init() was not called to setup CLogger");
    _logger.log(level._level, data, null, st);
  }
}

/// Wrapper for the CLogger.log(Level: CLogger.debug, ...)
void logDebug({Object? data, StackTrace? st}) => CLogger.log(
      level: CLogger.debug,
      data: data,
      st: st,
    );

/// Wrapper for the CLogger.log(Level: CLogger.error, ...)
void logError({Object? data, StackTrace? st}) => CLogger.log(
      level: CLogger.error,
      data: data,
      st: st,
    );

/// Wrapper for the CLogger.log(Level: CLogger.info, ...)
void logInfo({Object? data, StackTrace? st}) => CLogger.log(
      level: CLogger.info,
      data: data,
      st: st,
    );

/// Wrapper for the CLogger.log(Level: CLogger.warning, ...)
void logWarning({Object? data, StackTrace? st}) => CLogger.log(
      level: CLogger.warning,
      data: data,
      st: st,
    );

// ----------------------------------------------------------------------------
// [Math] ---------------------------------------------------------------------
// ----------------------------------------------------------------------------

// /// Support definition for the [CMath.calculate] utility method.
// typedef CMathFormula = double Function(List<double>);

// /// Utility providing a collection of mathematical formulas that you can get
// /// the answer to life's biggest questions.
// class CMath {
//   /// Kilometers squared to meters squared
//   static const String area_km2_to_m2 = "area_km2_to_m2";

//   /// Sets up the mapping of formulas for the calculate method.
//   static final _map = <String, CMathFormula>{
//     area_km2_to_m2: (v) => v[0] * 1e+6,
//   };

//   /// Executes the given formula with the specified variables.
//   static double calculate(String formula, List<double> vars) {
//     assert(
//       _map[formula] != null,
//       "CMath.calculate() formula specified does not exist",
//     );
//     return _map[formula]!(vars);
//   }
// }

// ----------------------------------------------------------------------------
// [Rest API] -----------------------------------------------------------------
// ----------------------------------------------------------------------------

// /// Implements the ability to either create a Rest API endpoint within your
// /// application or to fetch data from an Rest API endpoint.
// class CRestAPI {
//   /// The data resulting from the REST API client call.
//   final dynamic data;

//   /// The HTTP status code for the REST API client call.
//   ///
//   /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
//   final int status;

//   /// The status text associated with the HTTP status code.
//   final String statusText;

//   /// Data is assumed to be a [CObject] JSON format and is returned as such or
//   /// null if it is not.
//   CObject? get asObject => data as CObject?;

//   /// Data is assumed to be a String and is returned as such or null if it is
//   /// not.
//   String? get asString => data as String?;

//   /// Constructor for the object.
//   CRestAPI._(this.data, this.status, this.statusText);

//   /// Implements the ability to fetch a server's REST API endpoint to retrieve
//   /// and manage data. The supported actions are "delete", "get", "post", and
//   /// "put" with supporting data (i.e. headers, body) for the REST API call.
//   static Future<CRestAPI> fetch({
//     required String action,
//     Object? body,
//     Map<String, String>? headers,
//     int timeoutSeconds = 10,
//     required String url,
//   }) async {
//     assert(
//       action == "get" ||
//           action == "delete" ||
//           action == "put" ||
//           action == "post",
//       "Invalid action specified for CRestAPI.fetch()",
//     );
//     try {
//       // Go carry out the fetch request
//       var duration = Duration(seconds: timeoutSeconds);
//       http.Response resp;
//       var uri = Uri.parse(url);
//       if (action == "get") {
//         resp = await http.get(uri, headers: headers).timeout(duration);
//       } else if (action == "delete") {
//         resp = await http
//             .delete(uri, headers: headers, body: body)
//             .timeout(duration);
//       } else if (action == "put") {
//         resp =
//             await http.put(uri, headers: headers, body: body).timeout(duration);
//       } else {
//         resp = await http
//             .post(uri, headers: headers, body: body)
//             .timeout(duration);
//       }

//       // Now get the result object put together
//       final status = resp.statusCode;
//       final statusText = resp.reasonPhrase ?? "";
//       dynamic data;
//       String contentType = resp.headers["content-type"].toString();
//       if (contentType.containsIgnoreCase('plain/text') ||
//           contentType.containsIgnoreCase('text/html')) {
//         data = resp.body;
//       } else if (contentType.containsIgnoreCase('application/json')) {
//         data = jsonDecode(resp.body);
//       } else if (contentType.containsIgnoreCase('application/octet-stream')) {
//         data = resp.bodyBytes;
//       }

//       // Return the result.
//       return CRestAPI._(data, status, statusText);
//     } on TimeoutException catch (ex, st) {
//       // We had a timeout occur, log it and return it
//       CLogger.log(level: CLogger.warning, data: ex, st: st);
//       return CRestAPI._(null, 408, "Request Timeout");
//     } catch (ex, st) {
//       // Something unexpected happened, log it, and return it.
//       CLogger.log(level: CLogger.error, data: ex, st: st);
//       return CRestAPI._(null, 418, "Unknown Error Encountered");
//     }
//   }

//   // TODO: serve a REST API
//   // TODO: ping
// }

// ----------------------------------------------------------------------------
// [Storage] ------------------------------------------------------------------
// ----------------------------------------------------------------------------

// ============================================================================
// [Advanced Use Cases] =======================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [Database] -----------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Device Orientation] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Link Opener] --------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Hardware Device] ----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Network Socket] -----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Runtime] ------------------------------------------------------------------
// ----------------------------------------------------------------------------

class CRuntime {
  static bool get isPWA => platform.isPWA;
}

// ----------------------------------------------------------------------------
// [Web RTC] ------------------------------------------------------------------
// ----------------------------------------------------------------------------

// ============================================================================
// [User Interface Use Cases] =================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [Audio Player] -------------------------------------------------------------
// ----------------------------------------------------------------------------

// /// Identifies the source for the [CAudioPlayer.file] for a file playback.
// enum CAudioSource {
//   /// A bundled asset with your application
//   asset,

//   /// A file on the file system probably chosen via file picker
//   file,

//   /// A internet resource to download and play
//   url,
// }

// /// Identifies the state of the [CAudioPlayer] object.
// enum CAudioState {
//   /// Currently in a playback mode.
//   playing,

//   /// Audio has been paused.
//   paused,

//   /// Audio has been stopped and will reset with playing.
//   stopped,
// }

// /// Provides the ability to play audio files or perform text to speech
// /// within your application.
// class CAudioPlayer {
//   // Member Fields:
//   CAudioState _state = CAudioState.stopped;
//   late dynamic _data;
//   late dynamic _player;

//   CAudioPlayer._(dynamic player, dynamic data) {
//     _data = data;
//     _player = player;
//   }

//   /// Identifies the current state of the audio player.
//   CAudioState get state => _state;

//   /// Plays or resumes a paused audio source.
//   Future<void> play() async {
//     if (_state != CAudioState.paused || _state != CAudioState.stopped) {
//       return;
//     }

//     if (_player is FlutterTts) {
//       (_player as FlutterTts).speak(_data);
//     } else {
//       if (_state == CAudioState.paused) {
//         (_player as AudioPlayer).resume();
//       } else {
//         (_player as AudioPlayer).play(_data);
//       }
//     }
//     _state = CAudioState.playing;
//   }

//   /// Stops the playing audio source.
//   Future<void> stop() async {
//     if (_state != CAudioState.playing || _state != CAudioState.paused) {
//       return;
//     }

//     if (_player is FlutterTts) {
//       (_player as FlutterTts).stop();
//     } else {
//       (_player as AudioPlayer).stop();
//     }
//     _state = CAudioState.stopped;
//   }

//   /// Pauses a currently playing audio source.
//   Future<void> pause() async {
//     if (_state != CAudioState.playing) {
//       return;
//     }

//     if (_player is FlutterTts) {
//       (_player as FlutterTts).pause();
//     } else {
//       (_player as AudioPlayer).pause();
//     }
//     _state = CAudioState.paused;
//   }

//   /// Disposes of the audio player and resources.
//   Future<void> dispose() async {
//     if (_player is FlutterTts) {
//       await (_player as FlutterTts).stop();
//       _player = null;
//       _data = null;
//     } else {
//       await (_player as AudioPlayer).stop();
//       await (_player as AudioPlayer).dispose();
//       _player = null;
//       _data = null;
//     }
//   }

//   /// Builds a [CAudioPlayer] identifying an audio source and specifying the
//   /// location of said audio source.
//   static Future<CAudioPlayer> file({
//     required String data,
//     required CAudioSource source,
//     double volume = 0.5,
//     double balance = 0.0,
//     double rate = 1.0,
//     AudioPlayer? mock,
//   }) async {
//     final player = mock ?? AudioPlayer();
//     await player.setVolume(volume);
//     await player.setPlaybackRate(rate);
//     await player.setBalance(balance);
//     var audioSource = source == CAudioSource.asset
//         ? AssetSource(data)
//         : source == CAudioSource.file
//             ? DeviceFileSource(data)
//             : UrlSource(data);
//     player.onLog.listen((event) {
//       CLogger.log(level: CLogger.error, data: event, st: StackTrace.current);
//     });
//     return CAudioPlayer._(player, audioSource);
//   }

//   /// Builds a [CAudioPlayer] to perform text to speech of the specified data.
//   static Future<CAudioPlayer> tts({
//     required String data,
//     double volume = 0.5,
//     double pitch = 1.0,
//     double rate = 0.5,
//     FlutterTts? mock,
//   }) async {
//     final player = mock ?? FlutterTts();
//     await player.setPitch(pitch);
//     await player.setVolume(volume);
//     await player.setSpeechRate(rate);
//     player.setErrorHandler((message) {
//       CLogger.log(level: CLogger.error, data: message, st: StackTrace.current);
//     });
//     return CAudioPlayer._(player, data);
//   }
// }

// ----------------------------------------------------------------------------
// [Console] ------------------------------------------------------------------
// ----------------------------------------------------------------------------

// Console is not applicable to flutter as it is a widget based library.

// ----------------------------------------------------------------------------
// [Dialog] -------------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Set of utility methods for working with dialogs available in the flutter
/// environment. Allows for quick alerts, questions, async loading, and for
/// custom dialogs.
class CDialog {
  /// Sets up a global navigator key for usage with dialogs.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Sets up a global scaffold key for opening drawers and such on the
  /// [CAppView] object.
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  /// Internal tracking variable to properly handle browser display within
  /// rounded borders or the other types of dialogs.
  static bool _isBrowserAction = false;

  /// Will display information about your flutter app.
  static Future<void> about({
    Widget? appIcon,
    String? appName,
    String? appVersion,
    String? appLegalese,
  }) async {
    showLicensePage(
      context: navigatorKey.currentContext!,
      applicationIcon: appIcon,
      applicationName: appName,
      applicationVersion: appVersion,
      applicationLegalese: appLegalese,
      useRootNavigator: true,
    );
  }

  /// Provides a simple way to display a message to the user that must
  /// be dismissed.
  static Future<void> alert({
    required String message,
    double? height,
    String? title,
    double? width,
  }) async {
    return custom(
      content: Text(
        message,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: _getTheme().contentColor),
      ),
      height: height,
      title: title ?? "Attention",
      width: width,
    );
  }

  /// Shows a browser popup window when running within a mobile or web target
  /// environment.
  static Future<void> browser({
    required String url,
    double? height,
    String? title,
    bool useNativeBrowser = false,
    double? width,
  }) async {
    // Now figure what browser window action we are taking
    if (useNativeBrowser) {
      platform.openWebBrowser(
        target: title,
        height: height,
        url: url,
        width: width,
      );
      return;
    }

    // We are rendering an inline web view.
    _isBrowserAction = true;
    return custom(
      content: CWidget.webView(url: url),
      title: title ?? "Browser",
      height: height,
      width: width,
    );
  }

  /// Shows a popup dialog with a list of options returning the index selected
  /// or -1 if canceled.
  static Future<int> choose({
    required String title,
    required List<String> options,
  }) async {
    // Form up our dropdown options
    final dropdownItems = <DropdownMenuEntry<int>>[];
    for (final (index, option) in options.indexed) {
      dropdownItems.add(DropdownMenuEntry(label: option, value: index));
    }
    int? answer = 0;
    return (await custom<int?>(
          actions: [
            _buildButton<int>("OK", answer),
          ],
          content: CWidget.comboBox(
            dropdownMenuEntries: dropdownItems,
            enableFilter: false,
            enableSearch: false,
            initialSelection: 0,
            onSelected: (v) => answer = v,
            style: DropdownMenuThemeData(
              inputDecorationTheme: InputDecorationTheme(
                isDense: true,
                iconColor: _getTheme().contentColor,
                suffixIconColor: _getTheme().contentColor,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _getTheme().contentColor!),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _getTheme().contentColor!),
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: _getTheme().contentColor!),
                ),
              ),
              menuStyle: const MenuStyle(
                padding: MaterialStatePropertyAll(EdgeInsets.zero),
                visualDensity: VisualDensity.compact,
              ),
              textStyle: TextStyle(
                color: _getTheme().contentColor,
                decorationColor: _getTheme().contentColor,
              ),
            ),
            width: 200,
          ),
          title: title,
        )) ??
        -1;
  }

  /// Closes an open dialog and returns an answer depending on the type of
  /// dialog shown.
  static void close<T>([T? answer]) {
    Navigator.of(
      navigatorKey.currentContext!,
      rootNavigator: true,
    ).pop(answer);
    _isBrowserAction = false;
  }

  /// Provides a Yes/No confirmation dialog with the displayed message as the
  /// question. True is returned for Yes and False for a No or cancel.
  static Future<bool> confirm({
    required String message,
    double? height,
    String? title,
    double? width,
  }) async {
    return (await custom<bool?>(
          actions: [
            _buildButton<bool>("Yes", true),
            _buildButton<bool>("No", false),
          ],
          content: Text(
            message,
            softWrap: true,
            overflow: TextOverflow.clip,
            style: TextStyle(color: _getTheme().contentColor),
          ),
          height: height,
          title: title ?? "Confirm",
          width: width,
        )) ??
        false;
  }

  /// Shows a custom dialog for a more complex form where at the end you can
  /// apply changes as a returned value if necessary. You will make use of
  /// [CDialog.close] for returning values via your actions array.
  static Future<T?> custom<T>({
    required Widget content,
    required String title,
    List<Widget>? actions,
    bool hideClose = false,
    double? height,
    double? width,
  }) async {
    Widget? w;
    if (!_isBrowserAction && height == null && width == null) {
      // No width / height dialog, do not set size.
      w = content;
    } else if (_isBrowserAction) {
      // Browser, if no size specified, go for max size
      w = SizedBox(
        height: height ??
            CAppView.height(
                  navigatorKey.currentContext!,
                ) *
                0.85,
        width: width ??
            CAppView.width(
                  navigatorKey.currentContext!,
                ) *
                0.95,
        child: content,
      );
    } else {
      // A dialog that supports width / height but does not need max size/
      // Go with whatever they specified.
      w = SizedBox(
        height: height,
        width: width,
        child: content,
      );
    }
    return showDialog<T>(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        backgroundColor: _getTheme().backgroundColor,
        insetPadding: EdgeInsets.zero,
        scrollable: true,
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Row(
              children: [
                CWidget.divider(width: 10.0),
                Expanded(
                  child: CWidget.label(
                    data: title,
                    style: TextStyle(
                      color: _getTheme().titleColor,
                    ),
                  ),
                ),
                if (!hideClose)
                  CWidget.button(
                    type: CButtonType.icon,
                    title: "Close Dialog",
                    style: ButtonStyle(
                      iconColor: MaterialStatePropertyAll(
                        _getTheme().titleColor,
                      ),
                    ),
                    onPressed: () => close(),
                  )
              ],
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.all(5.0),
        actionsAlignment: MainAxisAlignment.center,
        contentPadding: EdgeInsets.only(
          left: _isBrowserAction ? 1.0 : 25.0,
          right: _isBrowserAction ? 1.0 : 25.0,
          bottom: _isBrowserAction ? 25.0 : 0.0,
        ),
        content: w,
        actions: actions,
      ),
    );
  }

  /// Provides the ability to run an async task and present a wait dialog. It
  /// is important you call [CDialog.close] to properly clear the
  /// dialog and return any value expected.
  static Future<T?> loading<T>({
    double? height,
    required String message,
    required Future<void> Function() task,
    String? title,
    double? width,
  }) async {
    Future.delayed(Duration.zero, task);
    return custom<T>(
      content: Row(
        children: [
          const SizedBox(width: 5.0),
          SizedBox(
            height: 25.0,
            width: 25.0,
            child: CircularProgressIndicator(
              color: _getTheme().contentColor,
            ),
          ),
          const SizedBox(width: 5.0),
          Text(
            message,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _getTheme().contentColor),
          ),
        ],
      ),
      hideClose: true,
      height: height,
      title: title ?? "Please Wait",
      width: width,
    );
  }

  /// Provides the ability to show an input prompt to retrieve an answer to a
  /// question. The value is returned back as a string. If a user cancels the
  /// action an empty string is returned.
  static Future<String> prompt({
    required String title,
  }) async {
    var answer = "";
    return (await custom<String?>(
          actions: [
            _buildButton<String>("OK", answer),
          ],
          content: CWidget.textField(
            height: 30.0,
            width: 200.0,
            textStyle: TextStyle(color: _getTheme().contentColor!),
            style: InputDecorationTheme(
              isDense: true,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: _getTheme().contentColor!),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _getTheme().contentColor!),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: _getTheme().contentColor!),
              ),
            ),
            onChanged: (v) => answer = v,
          ),
          title: title,
        )) ??
        "";
  }

  /// Provides the ability to show a full page within the [CAppView] with the
  /// ability to specify the title and actions in the top bar. You can also
  /// specify bottom actions.
  static void fullPage({
    required Widget content,
    List<Widget>? actions,
    bool? centerTitle,
    bool showBackButton = true,
    String? title,
  }) async {
    Navigator.push(
      scaffoldKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => Material(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: showBackButton,
              actions: actions,
              centerTitle: centerTitle,
              title: title != null ? Text(title) : null,
            ),
            body: content,
          ),
        ),
      ),
    );
  }

  /// Shows a snackbar at the bottom of the content area to display
  /// information.
  static void snackbar({
    required Widget content,
    SnackBarAction? action,
    Clip clipBehavior = Clip.hardEdge,
    int? seconds,
  }) {
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        action: action,
        clipBehavior: clipBehavior,
        content: content,
        duration: seconds != null
            ? Duration(seconds: seconds)
            : const Duration(seconds: 4),
      ),
    );
  }

  /// Helper action to build text buttons for our basic dialogs.
  static Widget _buildButton<T>(String title, T answer) => CWidget.button(
        type: CButtonType.text,
        title: title,
        style: ButtonStyle(
          foregroundColor: MaterialStatePropertyAll(
            _getTheme().actionsColor,
          ),
        ),
        onPressed: () => close<T>(answer),
      );

  /// Helper method to get the currently active dialog theme.
  static CDialogTheme _getTheme() =>
      Theme.of(scaffoldKey.currentContext!).cDialogTheme;
}

// ----------------------------------------------------------------------------
// [Main View] ----------------------------------------------------------------
// ----------------------------------------------------------------------------

class CAppView extends StatefulWidget {
  static bool _isInitialized = false;

  static final uiState = CObjectDataNotifier(
    objData: {
      "darkTheme": ThemeData.dark(useMaterial3: true),
      "themeMode": ThemeMode.system,
      "theme": ThemeData.light(useMaterial3: true),
    },
  );

  static ThemeData get darkTheme => uiState.get<ThemeData>("darkTheme");
  static set darkTheme(ThemeData? v) =>
      uiState.set<ThemeData?>("darkTheme", v, notify: true);

  static ThemeData get theme => uiState.get<ThemeData>("theme");
  static set theme(ThemeData? v) =>
      uiState.set<ThemeData?>("theme", v, notify: true);

  static ThemeMode get themeMode => uiState.get<ThemeMode>("themeMode");
  static set themeMode(ThemeMode v) =>
      uiState.set<ThemeMode?>("themeMode", v, notify: true);

  static String? get title => uiState.get<String?>("title");
  static set title(String? v) => uiState.set<String?>("title", v, notify: true);

  static void header({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    if (actions == null && leading == null && title == null) {
      uiState.set<AppBar?>("appBar", null);
    } else {
      uiState.set<AppBar?>(
        "appBar",
        AppBar(
          actions: actions,
          actionsIconTheme: style?.actionsIconTheme,
          automaticallyImplyLeading: automaticallyImplyLeading,
          backgroundColor: style?.backgroundColor,
          centerTitle: style?.centerTitle,
          elevation: style?.elevation,
          foregroundColor: style?.foregroundColor,
          forceMaterialTransparency: forceMaterialTransparency,
          iconTheme: style?.iconTheme,
          leading: leading,
          scrolledUnderElevation: style?.scrolledUnderElevation,
          shadowColor: style?.shadowColor,
          shape: style?.shape,
          surfaceTintColor: style?.surfaceTintColor,
          title: title,
          titleSpacing: style?.titleSpacing,
          titleTextStyle: style?.titleTextStyle,
          toolbarHeight: style?.toolbarHeight,
          toolbarTextStyle: style?.toolbarTextStyle,
          systemOverlayStyle: style?.systemOverlayStyle,
        ),
        notify: true,
      );
    }
  }

  static void content({
    required Widget? body,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
  }) {
    uiState.set<CObject>(
      "content",
      {
        "body": body,
        "extendBody": extendBody,
        "extendBodyBehindAppBar": extendBodyBehindAppBar,
      },
      notify: true,
    );
  }

  static void footer({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    if (actions == null && leading == null && title == null) {
      uiState.set<BottomAppBar?>("bottomAppBar", null);
    } else {
      uiState.set<BottomAppBar?>(
        "bottomAppBar",
        BottomAppBar(
          notchMargin: 0.0,
          padding: EdgeInsets.zero,
          height: style != null
              ? style.toolbarHeight
              : theme.appBarTheme.toolbarHeight,
          child: AppBar(
            actions: actions,
            actionsIconTheme: style?.actionsIconTheme,
            automaticallyImplyLeading: automaticallyImplyLeading,
            backgroundColor: style?.backgroundColor,
            centerTitle: style?.centerTitle,
            elevation: style?.elevation,
            foregroundColor: style?.foregroundColor,
            forceMaterialTransparency: forceMaterialTransparency,
            iconTheme: style?.iconTheme,
            leading: leading,
            scrolledUnderElevation: style?.scrolledUnderElevation,
            shadowColor: style?.shadowColor,
            shape: style?.shape,
            surfaceTintColor: style?.surfaceTintColor,
            title: title,
            titleSpacing: style?.titleSpacing,
            titleTextStyle: style?.titleTextStyle,
            toolbarHeight: style?.toolbarHeight,
            toolbarTextStyle: style?.toolbarTextStyle,
            systemOverlayStyle: style?.systemOverlayStyle,
          ),
        ),
        notify: true,
      );
    }
  }

  static void floatingActionButton({
    Widget? button,
    FloatingActionButtonLocation? location,
  }) {
    uiState.set<Widget?>(
      "floatingActionButton",
      button != null
          ? PointerInterceptor(
              intercepting: kIsWeb,
              child: button,
            )
          : null,
    );
    uiState.set<FloatingActionButtonLocation?>(
      "floatingActionButtonLocation",
      location,
      notify: true,
    );
  }

  static void drawer({Widget? header, List<Widget>? items}) {
    if (header == null && items == null) {
      uiState.set<Drawer?>("drawer", null);
    } else {
      uiState.set<Drawer?>(
        "drawer",
        Drawer(
          child: ListView(
            children: [
              if (header != null) header,
              if (items != null) ...items,
            ],
          ),
        ),
        notify: true,
      );
    }
  }

  static void endDrawer({Widget? header, List<Widget>? items}) {
    if (header == null && items == null) {
      uiState.set<Drawer?>("endDrawer", null);
    } else {
      uiState.set<Drawer?>(
        "endDrawer",
        Drawer(
          child: ListView(
            children: [
              if (header != null) header,
              if (items != null) ...items,
            ],
          ),
        ),
        notify: true,
      );
    }
  }

  /// Will programmatically close an open drawer on the [CAppView].
  static void closeDrawer() {
    if (CDialog.scaffoldKey.currentState!.isDrawerOpen) {
      CDialog.scaffoldKey.currentState!.closeDrawer();
    }
    if (CDialog.scaffoldKey.currentState!.isEndDrawerOpen) {
      CDialog.scaffoldKey.currentState!.closeEndDrawer();
    }
  }

  /// Will programmatically open a drawer on the [CAppView].
  static void openDrawer({bool isEndDrawer = false}) {
    if (!isEndDrawer && CDialog.scaffoldKey.currentState!.hasDrawer) {
      CDialog.scaffoldKey.currentState!.openDrawer();
    } else if (CDialog.scaffoldKey.currentState!.hasEndDrawer) {
      CDialog.scaffoldKey.currentState!.openEndDrawer();
    }
  }

  /// Retrieves the available height of the specified context.
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Retrieves the available width of the specified context.
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  @override
  State<StatefulWidget> createState() => _CAppViewState();

  /// Constructs the stateful single page app architecture.
  CAppView({super.key}) {
    assert(
      !_isInitialized,
      "Only one CAppView can be created. It sets up a SPA.",
    );
    _isInitialized = true;
  }
}

class _CAppViewState extends State<CAppView> {
  @override
  void initState() {
    CAppView.uiState.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: CAppView.darkTheme,
      navigatorKey: CDialog.navigatorKey,
      theme: CAppView.theme,
      themeMode: CAppView.themeMode,
      title: CAppView.title ?? "",
      home: Scaffold(
        appBar: CAppView.uiState.get<AppBar?>("appBar"),
        body: CAppView.uiState.get<CObject?>("content")?['body'],
        extendBody:
            CAppView.uiState.get<CObject?>("content")?['extendBody'] ?? false,
        extendBodyBehindAppBar: CAppView.uiState
                .get<CObject?>("content")?["extendBodyBehindAppBar"] ??
            false,
        bottomNavigationBar:
            CAppView.uiState.get<BottomAppBar?>("bottomAppBar"),
        drawer: CAppView.uiState.get<Widget?>("drawer"),
        endDrawer: CAppView.uiState.get<Widget?>("endDrawer"),
        floatingActionButton:
            CAppView.uiState.get<Widget?>("floatingActionButton"),
        floatingActionButtonLocation: CAppView.uiState
            .get<FloatingActionButtonLocation?>("floatingActionButtonLocation"),
        key: CDialog.scaffoldKey,
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// [Themes] -------------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Provides an alternative to the flutter DialogTheme class. This is due
/// to the fact it really does not theme much when the [CDialog] utility object
/// was created. Therefore, this extension will provide the theming for the
/// [CDialog] utility object.
class CDialogTheme extends ThemeExtension<CDialogTheme> {
  /// Background color for the entire dialog panel.
  final Color? backgroundColor;

  /// The title foreground color for the text and close icon.
  final Color? titleColor;

  /// The foreground color of the content color for all dialog types minus
  /// [CDialog.custom]. There the developer sets the color of the content.
  final Color? contentColor;

  /// The foreground color of the Text buttons for the dialog.
  final Color? actionsColor;

  @override
  CDialogTheme copyWith({
    Color? backgroundColor,
    Color? titleColor,
    Color? contentColor,
    Color? actionsColor,
  }) {
    return CDialogTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      titleColor: titleColor ?? this.titleColor,
      contentColor: contentColor ?? this.contentColor,
      actionsColor: actionsColor ?? this.actionsColor,
    );
  }

  @override
  CDialogTheme lerp(CDialogTheme? other, double t) {
    if (other is! CDialogTheme) {
      return this;
    }
    return CDialogTheme(
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      titleColor: Color.lerp(titleColor, other.titleColor, t),
      contentColor: Color.lerp(contentColor, other.contentColor, t),
      actionsColor: Color.lerp(actionsColor, other.actionsColor, t),
    );
  }

  /// Constructor for the theme. Sets up generic colors if none are specified.
  const CDialogTheme({
    this.backgroundColor = const Color.fromARGB(255, 2, 48, 32),
    this.titleColor = Colors.amber,
    this.contentColor = Colors.white,
    this.actionsColor = Colors.lightBlueAccent,
  });
}

/// Provides a wrapper around the Flutter ThemeData object that isolates
/// the application theming to the material3 constructs of Flutter. To support
/// this, a factory [CThemeDataExtension.create] method is created that only
/// supports material3 theming concepts and removes items that will eventually
/// be deprecated. This should be used when setting up the [CAppView.theme] amd
/// [CAppView.darkTheme] properties.
extension CThemeDataExtension on ThemeData {
  /// Custom theme to properly allow the theming of [CDialog] utility methods
  /// when showing pop-up dialogs.
  CDialogTheme get cDialogTheme => extension<CDialogTheme>()!;

  /// Utility method to create ThemeData objects but it only exposes the
  /// material3 themes so that any application theming is done with the
  /// future in mind.
  ThemeData create({
    ActionIconThemeData? actionIconTheme,
    AppBarTheme? appBarTheme,
    BadgeThemeData? badgeTheme,
    MaterialBannerThemeData? bannerTheme,
    BottomAppBarTheme? bottomAppBarTheme,
    BottomNavigationBarThemeData? bottomNavigationBarTheme,
    BottomSheetThemeData? bottomSheetTheme,
    ButtonBarThemeData? buttonBarTheme,
    ButtonThemeData? buttonTheme,
    CardTheme? cardTheme,
    CheckboxThemeData? checkboxTheme,
    ChipThemeData? chipTheme,
    ColorScheme? colorScheme,
    DataTableThemeData? dataTableTheme,
    DatePickerThemeData? datePickerTheme,
    DividerThemeData? dividerTheme,
    CDialogTheme? cDialogTheme,
    DrawerThemeData? drawerTheme,
    DropdownMenuThemeData? dropdownMenuTheme,
    ElevatedButtonThemeData? elevatedButtonTheme,
    ExpansionTileThemeData? expansionTileTheme,
    FilledButtonThemeData? filledButtonTheme,
    FloatingActionButtonThemeData? floatingActionButtonTheme,
    IconButtonThemeData? iconButtonTheme,
    IconThemeData? iconTheme,
    InputDecorationTheme? inputDecorationTheme,
    ListTileThemeData? listTileTheme,
    MaterialTapTargetSize? materialTapTargetSize,
    MenuBarThemeData? menuBarTheme,
    MenuButtonThemeData? menuButtonTheme,
    MenuThemeData? menuTheme,
    NavigationBarThemeData? navigationBarTheme,
    NavigationDrawerThemeData? navigationDrawerTheme,
    NavigationRailThemeData? navigationRailTheme,
    OutlinedButtonThemeData? outlinedButtonTheme,
    PageTransitionsTheme? pageTransitionsTheme,
    PopupMenuThemeData? popupMenuTheme,
    IconThemeData? primaryIconTheme,
    ProgressIndicatorThemeData? progressIndicatorTheme,
    TextTheme? primaryTextTheme,
    RadioThemeData? radioTheme,
    ScrollbarThemeData? scrollbarTheme,
    SearchBarThemeData? searchBarTheme,
    SearchViewThemeData? searchViewTheme,
    SegmentedButtonThemeData? segmentedButtonTheme,
    SliderThemeData? sliderTheme,
    InteractiveInkFeatureFactory? splashFactory,
    SwitchThemeData? switchTheme,
    TabBarTheme? tabBarTheme,
    TextButtonThemeData? textButtonTheme,
    TextSelectionThemeData? textSelectionTheme,
    TextTheme? textTheme,
    TimePickerThemeData? timePickerTheme,
    ToggleButtonsThemeData? toggleButtonsTheme,
    TooltipThemeData? tooltipTheme,
    Typography? typography,
    VisualDensity? visualDensity,
  }) {
    return ThemeData(
      actionIconTheme: actionIconTheme,
      appBarTheme: appBarTheme,
      badgeTheme: badgeTheme,
      bannerTheme: bannerTheme,
      bottomAppBarTheme: bottomAppBarTheme,
      bottomNavigationBarTheme: bottomNavigationBarTheme,
      bottomSheetTheme: bottomSheetTheme,
      buttonBarTheme: buttonBarTheme,
      buttonTheme: buttonTheme,
      cardTheme: cardTheme,
      checkboxTheme: checkboxTheme,
      chipTheme: chipTheme,
      colorScheme: colorScheme,
      dataTableTheme: dataTableTheme,
      datePickerTheme: datePickerTheme,
      dividerTheme: dividerTheme,
      drawerTheme: drawerTheme,
      dropdownMenuTheme: dropdownMenuTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      expansionTileTheme: expansionTileTheme,
      filledButtonTheme: filledButtonTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      iconButtonTheme: iconButtonTheme,
      iconTheme: iconTheme,
      inputDecorationTheme: inputDecorationTheme,
      listTileTheme: listTileTheme,
      materialTapTargetSize: materialTapTargetSize,
      menuBarTheme: menuBarTheme,
      menuButtonTheme: menuButtonTheme,
      menuTheme: menuTheme,
      navigationBarTheme: navigationBarTheme,
      navigationDrawerTheme: navigationDrawerTheme,
      navigationRailTheme: navigationRailTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      pageTransitionsTheme: pageTransitionsTheme,
      popupMenuTheme: popupMenuTheme,
      primaryIconTheme: primaryIconTheme,
      primaryTextTheme: primaryTextTheme,
      progressIndicatorTheme: progressIndicatorTheme,
      radioTheme: radioTheme,
      scrollbarTheme: scrollbarTheme,
      searchBarTheme: searchBarTheme,
      searchViewTheme: searchViewTheme,
      segmentedButtonTheme: segmentedButtonTheme,
      sliderTheme: sliderTheme,
      splashFactory: splashFactory,
      switchTheme: switchTheme,
      tabBarTheme: tabBarTheme,
      textButtonTheme: textButtonTheme,
      textSelectionTheme: textSelectionTheme,
      textTheme: textTheme,
      timePickerTheme: timePickerTheme,
      toggleButtonsTheme: toggleButtonsTheme,
      tooltipTheme: tooltipTheme,
      useMaterial3: true,
      visualDensity: visualDensity,
    ).copyWith(
      extensions: <ThemeExtension<CDialogTheme>>[
        cDialogTheme ?? const CDialogTheme(),
      ],
    );
  }
}

// ----------------------------------------------------------------------------
// [Widget] -------------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Supports identifying the [CWidget.button] widget constructed.
enum CButtonType { elevated, filled, icon, outlined, text }

/// Supports identifying what [CWidget.image] is constructed when utilized.
enum CImageType { asset, file, memory, network }

/// Utility widget builder for building basic stateless widgets for the
/// [CAppView]. It is a basic wrapper for the most common of UI elements but
/// does not preclude using Flutter to its fullest abilities to build rich UIs
/// for the application.
///
/// It focuses on utilizing material3 which is the default setup via the
/// [CThemeDataExtension] utility object for the [CAppView]. So the overrides
/// provided conform to that paradigm. It also patterns itself in providing the
/// ability to show / hide widgets so that any widget down the tree in theory
/// should also be hidden. Lastly any items with onPressed / onTapped events
/// utilizes the PointerInterceptor class to properly handle web targets when
/// over HTML elements.
class CWidget {
  /// Will construct a stateless button to handle press events of said button.
  /// The button is determined via the [CButtonType] enumeration which will
  /// provide the look and feel of the button. The style is handled by that
  /// particular buttons theme data object but to set the button individually,
  /// utilize the style override. These are stateless buttons so any changing
  /// of them is up to the parent.
  static Widget button({
    required void Function() onPressed,
    required String title,
    required CButtonType type,
    Key? key,
    bool enabled = true,
    dynamic icon,
    ButtonStyle? style,
    bool visible = true,
  }) {
    assert(
      icon is IconData || icon is Image || icon == null,
      "icon can only be an Image / IconData / null type",
    );

    Widget? btn;
    if (type == CButtonType.elevated) {
      btn = icon != null
          ? ElevatedButton.icon(
              key: key,
              icon: icon is IconData ? Icon(icon) : icon,
              label: Text(title),
              onPressed: enabled ? onPressed : null,
              style: style,
            )
          : ElevatedButton(
              key: key,
              onPressed: enabled ? onPressed : null,
              style: style,
              child: Text(title),
            );
    } else if (type == CButtonType.filled) {
      btn = icon != null
          ? FilledButton.icon(
              key: key,
              icon: icon is IconData ? Icon(icon) : icon,
              label: Text(title),
              onPressed: enabled ? onPressed : null,
              style: style,
            )
          : FilledButton(
              key: key,
              onPressed: enabled ? onPressed : null,
              style: style,
              child: Text(title),
            );
    } else if (type == CButtonType.icon) {
      btn = IconButton(
        key: key,
        icon: icon is IconData ? Icon(icon) : icon,
        tooltip: title,
        onPressed: enabled ? onPressed : null,
        style: style,
      );
    } else if (type == CButtonType.outlined) {
      btn = icon != null
          ? OutlinedButton.icon(
              key: key,
              icon: icon is IconData ? Icon(icon) : icon,
              label: Text(title),
              onPressed: enabled ? onPressed : null,
              style: style,
            )
          : OutlinedButton(
              key: key,
              onPressed: enabled ? onPressed : null,
              style: style,
              child: Text(title),
            );
    } else if (type == CButtonType.text) {
      btn = icon != null
          ? TextButton.icon(
              key: key,
              icon: icon is IconData ? Icon(icon) : icon,
              label: Text(title),
              onPressed: enabled ? onPressed : null,
              style: style,
            )
          : TextButton(
              key: key,
              onPressed: enabled ? onPressed : null,
              style: style,
              child: Text(title),
            );
    }

    return Visibility(
      key: key,
      visible: visible,
      child: PointerInterceptor(
        key: key,
        intercepting: kIsWeb,
        child: btn!,
      ),
    );
  }

  /// Provides the ability to center a widget with the ability to specify
  /// the visibility of the child tree of widgets wrapped by this.
  static Widget center({
    Key? key,
    double? heightFactor,
    double? widthFactor,
    bool visible = true,
    Widget? child,
  }) {
    return Visibility(
      key: key,
      visible: visible,
      child: Center(
        key: key,
        heightFactor: heightFactor,
        widthFactor: widthFactor,
        child: child,
      ),
    );
  }

  /// Layout to put widgets vertically.
  static Widget column({
    required List<Widget> children,
    Key? key,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    bool visible = true,
  }) {
    return Visibility(
      key: key,
      visible: visible,
      child: Column(
        key: key,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }

  /// Creates a customizable combo box drop down with the ability to implement
  /// a search box to filter the combo box.
  static Widget comboBox<T>({
    required List<DropdownMenuEntry<T>> dropdownMenuEntries,
    Key? key,
    bool enabled = true,
    bool enableFilter = false,
    bool enableSearch = true,
    String? errorText,
    double? height,
    String? helperText,
    String? hintText,
    T? initialSelection,
    Widget? label,
    dynamic leadingIcon,
    void Function(T?)? onSelected,
    int? Function(List<DropdownMenuEntry<T>>, String)? searchCallback,
    DropdownMenuThemeData? style,
    dynamic trailingIcon,
    bool visible = true,
    double? width,
  }) {
    assert(
      leadingIcon == null || leadingIcon is IconData || leadingIcon is Image,
      "leadingIcon can only be an Image, IconData, or null type",
    );
    assert(
      trailingIcon == null || trailingIcon is IconData || trailingIcon is Image,
      "trailingIcon can only be an Image, IconData, or null type",
    );

    final menu = DropdownMenu<T>(
      dropdownMenuEntries: dropdownMenuEntries,
      enabled: enabled,
      enableFilter: enableFilter,
      enableSearch: enableSearch,
      errorText: errorText,
      helperText: helperText,
      hintText: hintText,
      initialSelection: initialSelection,
      label: label,
      leadingIcon: leadingIcon is IconData ? Icon(leadingIcon) : leadingIcon,
      menuHeight: height,
      onSelected: onSelected,
      searchCallback: searchCallback,
      trailingIcon:
          trailingIcon is IconData ? Icon(trailingIcon) : trailingIcon,
      width: width,
    );
    final w = style != null
        ? DropdownMenuTheme(
            data: style,
            child: menu,
          )
        : menu;

    return Visibility(
      visible: visible,
      child: w,
    );
  }

  /// Creates a vertical or horizontal spacer between widgets that can be
  /// hidden if necessary.
  static Widget divider({
    Key? key,
    double? height,
    double? width,
    Color color = Colors.transparent,
    bool visible = true,
  }) {
    return Visibility(
      key: key,
      visible: visible,
      child: Container(
        key: key,
        color: color,
        height: height,
        width: width,
      ),
    );
  }

  /// Provides the ability to have an expansion list of widgets.
  static Widget expandedTile({
    required List<Widget> children,
    required Widget title,
    Key? key,
    bool enabled = true,
    bool initiallyExpanded = false,
    dynamic leading,
    ExpansionTileThemeData? style,
    Widget? subtitle,
    dynamic trailing,
    bool visible = true,
  }) {
    // Make sure we are using things properly
    assert(
      leading is IconData || leading is Image || leading == null,
      "leading can only be an Image, IconData, or null type",
    );
    assert(
      trailing is IconData || trailing is Image || trailing == null,
      "trailing can only be an Image, IconData, or null type",
    );

    final w = ExpansionTile(
      key: key,
      enabled: enabled,
      leading: leading == IconData ? Icon(leading) : leading,
      initiallyExpanded: false,
      title: title,
      subtitle: subtitle,
      trailing: trailing == IconData ? Icon(trailing) : trailing,
      children: children,
    );

    return Visibility(
      key: key,
      visible: visible,
      child: style != null ? ExpansionTileTheme(data: style, child: w) : w,
    );
  }

  /// Creates a scrollable grid layout of widgets that based on the
  /// crossAxisCount.
  static Widget gridView({
    required int crossAxisCount,
    required List<Widget> children,
    Key? key,
    Clip clipBehavior = Clip.hardEdge,
    double childAspectRatio = 1.0,
    double crossAxisSpacing = 0.0,
    double mainAxisSpacing = 0.0,
    EdgeInsetsGeometry? padding,
    bool? primary,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
  }) {
    return GridView.count(
      key: key,
      clipBehavior: clipBehavior,
      childAspectRatio: childAspectRatio,
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
      padding: padding,
      primary: primary,
      reverse: reverse,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }

  /// Will create an image widget based on the specified [CImageType]
  /// enumerated value and display it when available based on the
  /// characteristics specified with the widget. No theme controls this widget
  /// type so the characteristics are unique to each widget created.
  static Image image({
    required CImageType type,
    required dynamic src,
    Alignment alignment = Alignment.center,
    BoxFit? fit,
    double? height,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    double? width,
  }) {
    if (type == CImageType.asset) {
      return Image.asset(
        src,
        alignment: alignment,
        fit: fit,
        height: height,
        repeat: repeat,
        width: width,
      );
    } else if (type == CImageType.file) {
      return Image.file(
        src,
        alignment: alignment,
        fit: fit,
        height: height,
        repeat: repeat,
        width: width,
      );
    } else if (type == CImageType.memory) {
      return Image.memory(
        src,
        alignment: alignment,
        fit: fit,
        height: height,
        repeat: repeat,
        width: width,
      );
    }
    return Image.network(
      src,
      alignment: alignment,
      fit: fit,
      height: height,
      repeat: repeat,
      width: width,
    );
  }

  /// Provides a basic text label with the ability to make it multi-line, clip
  /// it if to long, and if necessary, make it a hyperlink.
  static Widget label({
    required String data,
    // String hyperlink,
    Key? key,
    int? maxLines,
    bool? softWrap,
    TextStyle? style,
    bool visible = true,
  }) {
    final w = Visibility(
      key: key,
      visible: visible,
      child: Text(
        data,
        key: key,
        maxLines: maxLines,
        softWrap: softWrap,
        style: style,
      ),
    );

    // TODO: Work hyperlink feature.
    return w;
  }

  /// Creates a selectable widget to be part of a view of selectable items.
  static Widget listTile({
    required void Function() onTap,
    Key? key,
    bool enabled = true,
    dynamic leading,
    Widget? title,
    Widget? subtitle,
    dynamic trailing,
    ListTileThemeData? style,
    bool visible = true,
  }) {
    // Make sure we are using things properly
    assert(
      leading is IconData || leading is Image || leading == null,
      "leading can only be an Image, IconData, or null type",
    );
    assert(
      trailing is IconData || trailing is Image || trailing == null,
      "trailing can only be an Image, IconData, or null type",
    );

    // Create a return the widget.
    final w = ListTile(
      key: key,
      leading: leading is IconData ? Icon(leading) : leading,
      title: title,
      subtitle: subtitle,
      trailing: trailing is IconData ? Icon(trailing) : trailing,
      onTap: enabled ? onTap : null,
    );

    return Visibility(
      key: key,
      visible: visible,
      child: style != null
          ? ListTileTheme(
              key: key,
              data: style,
              child: w,
            )
          : w,
    );
  }

  /// Provides a list view of widgets with automatic scrolling that can be
  /// set for vertical (default) or horizontal.
  static Widget listView({
    required List<Widget> children,
    Key? key,
    Clip clipBehavior = Clip.hardEdge,
    EdgeInsetsGeometry? padding,
    bool? primary,
    bool reverse = false,
    Axis scrollDirection = Axis.vertical,
    bool shrinkWrap = false,
  }) {
    return ListView(
      key: key,
      clipBehavior: clipBehavior,
      padding: padding,
      primary: primary,
      reverse: reverse,
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }

  /// Builds padding around a given widget.
  static Widget padding({
    required EdgeInsetsGeometry padding,
    Key? key,
    Widget? child,
  }) {
    return Padding(
      key: key,
      padding: padding,
      child: child,
    );
  }

  /// Layout to put widgets horizontally.
  static Widget row({
    required List<Widget> children,
    Key? key,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
    bool visible = true,
  }) {
    return Visibility(
      key: key,
      visible: visible,
      child: Row(
        key: key,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: children,
      ),
    );
  }

  /// Creates a stacked widget based on the children allowing for a custom
  /// look and feel for "special" widgets that stack bottom to top and overlap.
  static Widget stack({
    required List<Widget> children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    Clip clipBehavior = Clip.hardEdge,
    StackFit fit = StackFit.loose,
    Key? key,
    TextDirection? textDirection,
    bool visible = true,
  }) {
    return Visibility(
      key: key,
      visible: visible,
      child: Stack(
        alignment: alignment,
        clipBehavior: clipBehavior,
        fit: fit,
        key: key,
        textDirection: textDirection,
        children: children,
      ),
    );
  }

  /// Provides for a generalized widget to allow for the collection of data
  /// and providing feedback to a user. It exposes the most common text field
  /// options to allow for building custom text fields
  /// (i.e. spin controls, number only, etc.).
  static Widget textField({
    bool autofocus = false,
    bool canRequestFocus = true,
    bool? enabled,
    FocusNode? focusNode,
    double? height,
    List<TextInputFormatter>? inputFormatters,
    Key? key,
    TextInputType? keyboardType,
    int? maxLength,
    int? maxLines = 1,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool readOnly = false,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    TextAlign textAlign = TextAlign.start,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? textStyle,
    double? width,
    bool visible = true,
    InputDecorationTheme? style,
  }) {
    final w = TextField(
      key: key,
      // Causes the text field to properly size via a SizedBox
      expands: true,
      minLines: null,
      maxLines: maxLines,
      // Setup proper focus properties
      autofocus: autofocus,
      canRequestFocus: canRequestFocus,
      focusNode: focusNode,
      // Control how text is rendered within text field
      autocorrect: false,
      enableSuggestions: false,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      style: textStyle,
      textInputAction: textInputAction,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      scrollPadding: scrollPadding,
      // Control user interaction with the text field
      enabled: enabled,
      maxLength: maxLength,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
    );
    return Visibility(
      key: key,
      visible: visible,
      child: style != null
          ? SizedBox(
              key: key,
              height: height,
              width: width,
              child: Theme(
                key: key,
                data: ThemeData(inputDecorationTheme: style),
                child: w,
              ),
            )
          : SizedBox(
              key: key,
              height: height,
              width: width,
              child: w,
            ),
    );
  }

  /// Provides the ability to view web content on mobile / web targets.
  static Widget webView({
    required String url,
    Key? key,
    bool visible = true,
  }) {
    return Visibility(
      key: key,
      visible: visible,
      child: platform.createWebView(
        key: key,
        url: url,
      ),
    );
  }
}
