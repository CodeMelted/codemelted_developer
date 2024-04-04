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

import 'package:flutter/widgets.dart';

import 'src/platform_none.dart'
    if (dart.library.io) 'src/platform_io.dart'
    if (dart.library.js) 'src/platform_web.dart';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/js.dart' as js;
import 'package:universal_io/io.dart';

// ============================================================================
// [Core Use Cases] ===========================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [Async IO] -----------------------------------------------------------------
// ----------------------------------------------------------------------------

/// The task to run as part of the [CAsyncTask] utility object. It defines the
/// logic to run as part of the async call and possibly return a result.
typedef CAsyncTaskFunction = dynamic Function([dynamic]);

/// Utility class for handling one off [CAsyncTaskFunction] work. It can be
/// handled via [CAsyncTask.background] for spawning a background isolate
/// (only available on native), [CAsyncTask.timeout] for spawning it on the
/// main thread, or as a [CAsyncTask.interval] repeating task. You can also
/// [CAsyncTask.sleep] a task.
class CAsyncTask {
  /// Spawns a background isolate to run the specified task and if part of the
  /// task, return the result. Only available on desktop and mobile platforms.
  static Future<dynamic> background({
    required CAsyncTaskFunction task,
    dynamic data,
  }) async {
    assert(!kIsWeb, "This is only available on native platforms");
    return Isolate.run<dynamic>(() => task(data));
  }

  /// Spawns a Timer for executing a repeating task. It is canceled via the
  /// [Timer.cancel] method.
  static Timer interval({
    required CAsyncTaskFunction task,
    required int delay,
  }) {
    final timer = Timer.periodic(Duration(milliseconds: delay), (timer) {
      task();
    });
    return timer;
  }

  /// Provides the ability to await a specified number of milliseconds before
  /// proceeding to the next async task.
  static Future<void> sleep(int delay) async => await Future.delayed(
        Duration(milliseconds: delay),
      );

  /// Spawns a future task that can return a result when completed. Only
  /// executes the one time and cannot be canceled.
  static Future<dynamic> timeout({
    required CAsyncTaskFunction task,
    dynamic data,
    int delay = 0,
  }) async {
    return Future.delayed(
      Duration(milliseconds: delay),
      () => task(data),
    );
  }
}

/// Supports the receipt of data via the [CAsyncWorker] dedicated background
/// FIFO queued processor.
typedef CAsyncWorkerListener = void Function(dynamic);

/// Creates a dedicated FIFO queued background worker for processing data
/// off the main thread communicating those results via the
/// [CAsyncWorkerListener].
class CAsyncWorker {
  // Member Fields:
  late dynamic _asyncObj;

  /// Constructor for the object.
  CAsyncWorker._({
    dynamic asyncObj,
    SendPort? sendPort,
    ReceivePort? receivePort,
  }) {
    _asyncObj = asyncObj;
  }

  /// Supports sending data specific to the background worker to process and
  /// return the results via the [CAsyncWorkerListener].
  void postMessage([dynamic data]) {
    if (_asyncObj is html.Worker) {
      (_asyncObj as html.Worker).postMessage(data);
    }
  }

  /// Terminates this dedicated worker object making it no longer available.
  void terminate() {
    if (_asyncObj is html.Worker) {
      (_asyncObj as html.Worker).terminate();
    }
  }

  /// @nodoc
  static CAsyncWorker process() {
    assert(!kIsWeb, "CAsyncIO.process not available on web targets");
    throw "NOT IMPLEMENTED YET";
  }

  /// Spawns a dedicated web worker written in JavaScript represented by the
  /// specified url. This is only valid for the web target.
  static CAsyncWorker webWorker({
    required String url,
    required CAsyncWorkerListener onReceived,
  }) {
    assert(
      kIsWeb,
      "CAsyncWorker.webWorker() is only available on the web target.",
    );
    var worker = html.Worker(url);
    worker.addEventListener(
      "message",
      (event) => onReceived((event as html.MessageEvent).data),
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
    return CAsyncWorker._(asyncObj: worker);
  }
}

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
  void set<T>(String key, T value) {
    _data[key] = value;
    notifyListeners();
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

// ----------------------------------------------------------------------------
// [File Explorer] ------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Logger] -------------------------------------------------------------------
// ----------------------------------------------------------------------------

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

// ----------------------------------------------------------------------------
// [Math] ---------------------------------------------------------------------
// ----------------------------------------------------------------------------

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
      "CMath.calculate() formula specified does not exist",
    );
    return _map[formula]!(vars);
  }
}

// ----------------------------------------------------------------------------
// [Rest API] -----------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Implements the ability to either create a Rest API endpoint within your
/// application or to fetch data from an Rest API endpoint.
class CRestAPI {
  /// The data resulting from the REST API client call.
  final dynamic data;

  /// The HTTP status code for the REST API client call.
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Status
  final int status;

  /// The status text associated with the HTTP status code.
  final String statusText;

  /// Data is assumed to be a [CObject] JSON format and is returned as such or
  /// null if it is not.
  CObject? get asObject => data as CObject?;

  /// Data is assumed to be a String and is returned as such or null if it is
  /// not.
  String? get asString => data as String?;

  /// Constructor for the object.
  CRestAPI._(this.data, this.status, this.statusText);

  /// Implements the ability to fetch a server's REST API endpoint to retrieve
  /// and manage data. The supported actions are "delete", "get", "post", and
  /// "put" with supporting data (i.e. headers, body) for the REST API call.
  static Future<CRestAPI> fetch({
    required String action,
    Object? body,
    Map<String, String>? headers,
    int timeoutSeconds = 10,
    required String url,
  }) async {
    assert(
      action == "get" ||
          action == "delete" ||
          action == "put" ||
          action == "post",
      "Invalid action specified for CRestAPI.fetch()",
    );
    try {
      // Go carry out the fetch request
      var duration = Duration(seconds: timeoutSeconds);
      http.Response resp;
      var uri = Uri.parse(url);
      if (action == "get") {
        resp = await http.get(uri, headers: headers).timeout(duration);
      } else if (action == "delete") {
        resp = await http
            .delete(uri, headers: headers, body: body)
            .timeout(duration);
      } else if (action == "put") {
        resp =
            await http.put(uri, headers: headers, body: body).timeout(duration);
      } else {
        resp = await http
            .post(uri, headers: headers, body: body)
            .timeout(duration);
      }

      // Now get the result object put together
      final status = resp.statusCode;
      final statusText = resp.reasonPhrase ?? "";
      dynamic data;
      String contentType = resp.headers["content-type"].toString();
      if (contentType.containsIgnoreCase('plain/text') ||
          contentType.containsIgnoreCase('text/html')) {
        data = resp.body;
      } else if (contentType.containsIgnoreCase('application/json')) {
        data = jsonDecode(resp.body);
      } else if (contentType.containsIgnoreCase('application/octet-stream')) {
        data = resp.bodyBytes;
      }

      // Return the result.
      return CRestAPI._(data, status, statusText);
    } on TimeoutException catch (ex, st) {
      // We had a timeout occur, log it and return it
      CLogger.log(level: CLogger.warning, data: ex, st: st);
      return CRestAPI._(null, 408, "Request Timeout");
    } catch (ex, st) {
      // Something unexpected happened, log it, and return it.
      CLogger.log(level: CLogger.error, data: ex, st: st);
      return CRestAPI._(null, 418, "Unknown Error Encountered");
    }
  }

  // TODO: serve a REST API
  // TODO: ping
}

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

// ----------------------------------------------------------------------------
// [Web RTC] ------------------------------------------------------------------
// ----------------------------------------------------------------------------

// ============================================================================
// [User Interface Use Cases] =================================================
// ============================================================================

// ----------------------------------------------------------------------------
// [Audio Player] -------------------------------------------------------------
// ----------------------------------------------------------------------------

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

  /// Will display information about your flutter app.
  Future<void> about({
    required Widget? appIcon,
    required String? appName,
    required String? appVersion,
    required String? appLegalese,
  }) async {
    showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => PointerInterceptor(
        intercepting: kIsWeb,
        child: AboutDialog(
          applicationName: appName,
          applicationVersion: appVersion,
          applicationLegalese: appLegalese,
          applicationIcon: appIcon,
        ),
      ),
    );
  }

  /// Provides a simple way to display a message to the user that must
  /// be dismissed. You can use a flutter build alert dialog or the native
  /// browser if working within a web environment.
  Future<void> alert({
    double? height,
    required String message,
    String? title,
    bool useNativeBrowser = false,
    double? width,
  }) async {
    if (useNativeBrowser) {
      assert(kIsWeb, "Use of native browser only available on web targets");
      html.window.alert(message);
      return;
    }

    return custom(
      content: Text(message),
      height: height,
      title: title ?? "Attention",
      width: width,
    );
  }

  /// Shows a browser popup window when running within a mobile or web target
  /// environment.
  Future<void> browser({
    double? height,
    required String message,
    String? target,
    String? title,
    bool useNativeBrowser = false,
    required String url,
    double? width,
  }) async {
    // Now figure what browser window action we are taking
    if (useNativeBrowser) {
      assert(kIsWeb, "Use of native browser only available on web targets");

      if (target == null) {
        // Target not specified, it is a popup window.
        final w = width ?? 900;
        final h = height ?? 600;
        final top = (html.window.screen!.height! - h) / 2;
        final left = (html.window.screen!.width! - w) / 2;
        html.window.open(
          url,
          "_blank",
          "toolbar=no, location=no, directories=no, status=no, "
              "menubar=no, scrollbars=no, resizable=yes, copyhistory=no, "
              "width=$w, height=$h, top=$top, left=$left",
        );
        return;
      } else {
        // Target specified, we are redirecting somewhere.
        html.window.open(url, target);
        return;
      }
    }

    return custom(
      content: CWebView(url: url),
      height: height,
      title: title ?? "Browser",
      width: width,
    );
  }

  /// Shows a popup dialog with a list of options returning the index selected
  /// or -1 if canceled.
  Future<int> choose({
    double? height,
    required String message,
    required List<String> options,
    String? title,
    double? width,
  }) async {
    // Form up our dropdown options
    final dropdownItems = <DropdownMenuItem<int>>[];
    for (final (index, option) in options.indexed) {
      dropdownItems.add(
        DropdownMenuItem(
          value: index,
          child: Text(option),
        ),
      );
    }
    var answer = 0;
    return (await custom<int?>(
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => close<int>(answer),
            ),
          ],
          content: CComboBoxControl<int>(
            items: dropdownItems,
            title: message,
            value: 0,
            onChanged: (v) => answer = v!,
          ),
          height: height,
          title: title ?? "Choose",
          width: width,
        )) ??
        -1;
  }

  /// Closes an open dialog and returns an answer depending on the type of
  /// dialog shown.
  void close<T>([T? answer]) async {
    Navigator.of(navigatorKey.currentContext!, rootNavigator: true).pop(answer);
  }

  /// Provides a Yes/No confirmation dialog with the displayed message as the
  /// question. True is returned for Yes and False for a No or cancel. You also
  /// have the option to utilize the native browser prompt if running in a web
  /// target.
  Future<bool> confirm({
    double? height,
    required String message,
    String? title,
    bool useNativeBrowser = false,
    double? width,
  }) async {
    if (useNativeBrowser) {
      assert(kIsWeb, "Use of native browser only available on web targets");
      return html.window.confirm(message);
    }

    return (await custom<bool?>(
          actions: [
            TextButton(
              child: const Text("Yes"),
              onPressed: () => close<bool>(true),
            ),
            TextButton(
              child: const Text("No"),
              onPressed: () => close<bool>(false),
            ),
          ],
          content: Text(message),
          height: height,
          title: title ?? "Confirm",
          width: width,
        )) ??
        false;
  }

  /// Shows a custom dialog for a more complex form where at the end you can
  /// apply changes as a returned value if necessary. You will make use of
  /// [CDialog.close] for returning values via your actions array.
  Future<T?> custom<T>({
    List<TextButton>? actions,
    required Widget content,
    double? height,
    required String title,
    double? width,
  }) async {
    return showDialog<T>(
      barrierDismissible: false,
      context: navigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        insetPadding: EdgeInsets.zero,
        scrollable: true,
        titlePadding: EdgeInsets.zero,
        title: Column(
          children: [
            Row(
              children: [
                CWidget.spacer(width: 5.0),
                Expanded(child: Text(title)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => close(),
                ),
              ],
            ),
            CWidget.spacer(height: 2.0)
          ],
        ),
        actionsPadding: const EdgeInsets.all(5.0),
        actionsAlignment: MainAxisAlignment.center,
        contentPadding: EdgeInsets.zero,
        content: SizedBox(
          height:
              height ?? CAppView.height(navigatorKey.currentContext!) * 0.65,
          width: width ?? CAppView.width(navigatorKey.currentContext!) * 0.90,
          child: content,
        ),
        actions: actions,
      ),
    );
  }

  /// Provides the ability to run an async task and present a wait dialog. It
  /// is important you call [CDialog.close] to properly clear the
  /// dialog and return any value expected.
  Future<T?> loading<T>({
    Color barrierColor = Colors.black54,
    Color? backgroundColor,
    Color? foregroundColor,
    double? height,
    required String message,
    required Future<void> Function() task,
    String? title,
    double? width,
  }) async {
    Future.delayed(Duration.zero, task);
    return custom<T>(
      content: Text(
        message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      height: height,
      title: title ?? "Please Wait",
      width: width,
    );
  }

  /// Provides the ability to show an input prompt to retrieve an answer to a
  /// question. The value is returned back as a string. If a user cancels the
  /// action an empty string is returned. You also have the option to use the
  /// native browser prompt when utilizing the web target.
  Future<String> prompt({
    double? height,
    required String message,
    String? title,
    bool useNativeBrowser = false,
    double? width,
  }) async {
    if (useNativeBrowser) {
      assert(kIsWeb, "Use of native browser only available on web targets");
      return js.context.callMethod("prompt", [message]);
    }

    // Not using native browser, so show one of ours.
    var answer = "";
    return (await custom<String?>(
          actions: [
            TextButton(
              child: const Text("OK"),
              onPressed: () => close<String>(answer),
            ),
          ],
          content: CTextFieldControl(
            title: message,
            onChanged: (v) => answer = v,
          ),
          height: height,
          title: title ?? "Prompt",
          width: width,
        )) ??
        "";
  }

  /// Shows a rounded snackbar at the bottom of the content area to display
  /// some information.
  void snackbar({
    Widget? content,
    String? message,
    int? seconds,
  }) {
    assert(
      (content != null && message == null) ||
          (content == null && message != null),
      "Only content or message can be set. Not both or neither.",
    );

    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: content ?? Text(message!),
        duration: seconds != null
            ? Duration(seconds: seconds)
            : const Duration(seconds: 4),
        showCloseIcon: true,
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// [Main View] ----------------------------------------------------------------
// ----------------------------------------------------------------------------

class CAppView extends StatefulWidget {
  static bool _isInitialized = false;

  static final scaffoldKey = GlobalKey<ScaffoldState>();

  static final uiState = CObjectDataNotifier();

  static Widget? get content => uiState.get<Widget?>("content");
  static set content(Widget? v) => uiState.set<Widget?>("content", v);

  static ThemeData? get darkTheme => uiState.get<ThemeData?>("darkTheme");
  static set darkTheme(ThemeData? v) => uiState.set<ThemeData?>("darkTheme", v);

  static ThemeData? get theme => uiState.get<ThemeData?>("theme");
  static set theme(ThemeData? v) => uiState.set<ThemeData?>("theme", v);

  static ThemeMode? get themeMode => uiState.get<ThemeMode?>("themeMode");
  static set themeMode(ThemeMode? v) => uiState.set<ThemeMode?>("themeMode", v);

  static String? get title => uiState.get<String?>("title");
  static set title(String? v) => uiState.set<String?>("title", v);

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
    );
  }

  static void drawer({DrawerHeader? header, List<Widget>? items}) {
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
      );
    }
  }

  static void endDrawer({DrawerHeader? header, List<Widget>? items}) {
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
      );
    }
  }

  static void footer({
    List<Widget>? actions,
    bool? centerTitle,
    Widget? leading,
    Widget? title,
  }) {
    if (actions == null &&
        centerTitle == null &&
        leading == null &&
        title == null) {
      uiState.set<BottomAppBar?>("bottomAppBar", null);
    } else {
      uiState.set<BottomAppBar?>(
        "bottomAppBar",
        BottomAppBar(
          notchMargin: 0.0,
          padding: EdgeInsets.zero,
          child: AppBar(
            actions: actions,
            automaticallyImplyLeading: false,
            centerTitle: centerTitle,
            leading: leading,
            title: title,
          ),
        ),
      );
    }
  }

  static void header({
    List<Widget>? actions,
    bool? centerTitle,
    Widget? leading,
    Widget? title,
  }) {
    if (actions == null &&
        centerTitle == null &&
        leading == null &&
        title == null) {
      uiState.set<AppBar?>("appBar", null);
    } else {
      uiState.set<AppBar?>(
        "appBar",
        AppBar(
          actions: actions,
          automaticallyImplyLeading: false,
          centerTitle: centerTitle,
          leading: leading,
          title: title,
        ),
      );
    }
  }

  /// Will programmatically close an open drawer on the [CAppView].
  void closeDrawer() {
    if (scaffoldKey.currentState!.isDrawerOpen) {
      scaffoldKey.currentState!.closeDrawer();
    }
    if (scaffoldKey.currentState!.isEndDrawerOpen) {
      scaffoldKey.currentState!.closeEndDrawer();
    }
  }

  /// Will programmatically open a drawer on the [CAppView].
  void openDrawer({bool isEndDrawer = false}) {
    if (!isEndDrawer && scaffoldKey.currentState!.hasDrawer) {
      scaffoldKey.currentState!.openDrawer();
    } else if (scaffoldKey.currentState!.hasEndDrawer) {
      scaffoldKey.currentState!.openEndDrawer();
    }
  }

  /// Retrieves the available height of the specified context.
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Retrieves the available width of the specified context.
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  /// Provides the ability to show a full page within the [CAppView] with the
  /// ability to specify the title and actions in the top bar. You can also
  /// specify bottom actions.
  void showFullPage({
    required Widget content,
    bool? centerTitle,
    String? title,
    List<Widget>? actions,
    List<Widget>? bottomActions,
  }) async {
    Navigator.push(
      scaffoldKey.currentContext!,
      MaterialPageRoute(
        builder: (context) => Material(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: true,
              actions: actions,
              centerTitle: centerTitle,
              title: title != null ? Text(title) : null,
            ),
            body: content,
            bottomNavigationBar: bottomActions != null
                ? BottomAppBar(
                    child: Row(
                      children: bottomActions,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  @override
  State<StatefulWidget> createState() => _CAppViewState();

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
        body: CAppView.content,
        bottomNavigationBar:
            CAppView.uiState.get<BottomAppBar?>("bottomAppBar"),
        drawer: CAppView.uiState.get<Widget?>("drawer"),
        endDrawer: CAppView.uiState.get<Widget?>("endDrawer"),
        floatingActionButton:
            CAppView.uiState.get<Widget?>("floatingActionButton"),
        floatingActionButtonLocation: CAppView.uiState
            .get<FloatingActionButtonLocation?>("floatingActionButtonLocation"),
        key: CAppView.scaffoldKey,
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// [Themes] -------------------------------------------------------------------
// ----------------------------------------------------------------------------

class CTheme {
  static ThemeData create({
    InputDecorationTheme? inputDecorationTheme,
    MaterialTapTargetSize? materialTapTargetSize,
    PageTransitionsTheme? pageTransitionsTheme,
    TargetPlatform? platform,
    ScrollbarThemeData? scrollbarTheme,
    InteractiveInkFeatureFactory? splashFactory,
    VisualDensity? visualDensity,
    Brightness? brightness,
    Color? canvasColor,
    Color? cardColor,
    ColorScheme? colorScheme,
    Color? colorSchemeSeed,
    Color? dialogBackgroundColor,
    Color? disabledColor,
    Color? dividerColor,
    Color? focusColor,
    Color? highlightColor,
    Color? hintColor,
    Color? hoverColor,
    Color? indicatorColor,
    Color? primaryColor,
    Color? primaryColorDark,
    Color? primaryColorLight,
    MaterialColor? primarySwatch,
    Color? scaffoldBackgroundColor,
    Color? secondaryHeaderColor,
    Color? shadowColor,
    Color? splashColor,
    Color? unselectedWidgetColor,
    String? fontFamily,
    List<String>? fontFamilyFallback,
    String? package,
    IconThemeData? iconTheme,
    IconThemeData? primaryIconTheme,
    TextTheme? primaryTextTheme,
    TextTheme? textTheme,
    Typography? typography,
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
    DataTableThemeData? dataTableTheme,
    DatePickerThemeData? datePickerTheme,
    DialogTheme? dialogTheme,
    DividerThemeData? dividerTheme,
    DrawerThemeData? drawerTheme,
    DropdownMenuThemeData? dropdownMenuTheme,
    ElevatedButtonThemeData? elevatedButtonTheme,
    ExpansionTileThemeData? expansionTileTheme,
    FilledButtonThemeData? filledButtonTheme,
    FloatingActionButtonThemeData? floatingActionButtonTheme,
    IconButtonThemeData? iconButtonTheme,
    ListTileThemeData? listTileTheme,
    MenuBarThemeData? menuBarTheme,
    MenuButtonThemeData? menuButtonTheme,
    MenuThemeData? menuTheme,
    NavigationBarThemeData? navigationBarTheme,
    NavigationDrawerThemeData? navigationDrawerTheme,
    NavigationRailThemeData? navigationRailTheme,
    OutlinedButtonThemeData? outlinedButtonTheme,
    PopupMenuThemeData? popupMenuTheme,
    ProgressIndicatorThemeData? progressIndicatorTheme,
    RadioThemeData? radioTheme,
    SearchBarThemeData? searchBarTheme,
    SearchViewThemeData? searchViewTheme,
    SegmentedButtonThemeData? segmentedButtonTheme,
    SliderThemeData? sliderTheme,
    SnackBarThemeData? snackBarTheme,
    SwitchThemeData? switchTheme,
    TabBarTheme? tabBarTheme,
    TextButtonThemeData? textButtonTheme,
    TextSelectionThemeData? textSelectionTheme,
    TimePickerThemeData? timePickerTheme,
    ToggleButtonsThemeData? toggleButtonsTheme,
    TooltipThemeData? tooltipTheme,
  }) {
    return ThemeData(
      inputDecorationTheme: inputDecorationTheme,
      materialTapTargetSize: materialTapTargetSize,
      pageTransitionsTheme: pageTransitionsTheme,
      platform: platform,
      scrollbarTheme: scrollbarTheme,
      splashFactory: splashFactory,
      visualDensity: visualDensity,
      brightness: brightness,
      canvasColor: canvasColor,
      cardColor: cardColor,
      colorScheme: colorScheme,
      colorSchemeSeed: colorSchemeSeed,
      dialogBackgroundColor: dialogBackgroundColor,
      disabledColor: disabledColor,
      dividerColor: dividerColor,
      focusColor: focusColor,
      highlightColor: highlightColor,
      hintColor: hintColor,
      hoverColor: hoverColor,
      indicatorColor: indicatorColor,
      primaryColor: primaryColor,
      primaryColorDark: primaryColorDark,
      primaryColorLight: primaryColorLight,
      primarySwatch: primarySwatch,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      secondaryHeaderColor: secondaryHeaderColor,
      shadowColor: shadowColor,
      splashColor: splashColor,
      unselectedWidgetColor: unselectedWidgetColor,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFamilyFallback,
      package: package,
      iconTheme: iconTheme,
      primaryIconTheme: primaryIconTheme,
      primaryTextTheme: primaryTextTheme,
      textTheme: textTheme,
      typography: typography,
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
      dataTableTheme: dataTableTheme,
      datePickerTheme: datePickerTheme,
      dialogTheme: dialogTheme,
      dividerTheme: dividerTheme,
      drawerTheme: drawerTheme,
      dropdownMenuTheme: dropdownMenuTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      expansionTileTheme: expansionTileTheme,
      filledButtonTheme: filledButtonTheme,
      floatingActionButtonTheme: floatingActionButtonTheme,
      iconButtonTheme: iconButtonTheme,
      listTileTheme: listTileTheme,
      menuBarTheme: menuBarTheme,
      menuButtonTheme: menuButtonTheme,
      menuTheme: menuTheme,
      navigationBarTheme: navigationBarTheme,
      navigationDrawerTheme: navigationDrawerTheme,
      navigationRailTheme: navigationRailTheme,
      outlinedButtonTheme: outlinedButtonTheme,
      popupMenuTheme: popupMenuTheme,
      progressIndicatorTheme: progressIndicatorTheme,
      radioTheme: radioTheme,
      searchBarTheme: searchBarTheme,
      searchViewTheme: searchViewTheme,
      segmentedButtonTheme: segmentedButtonTheme,
      sliderTheme: sliderTheme,
      snackBarTheme: snackBarTheme,
      switchTheme: switchTheme,
      tabBarTheme: tabBarTheme,
      textButtonTheme: textButtonTheme,
      textSelectionTheme: textSelectionTheme,
      timePickerTheme: timePickerTheme,
      toggleButtonsTheme: toggleButtonsTheme,
      tooltipTheme: tooltipTheme,
    );
  }
}

// ----------------------------------------------------------------------------
// [Widget] -------------------------------------------------------------------
// ----------------------------------------------------------------------------

enum CImageType { asset, file, memory, network }

/// Utility widget builder for building basic stateless widgets for a UI.
class CWidget {
  static Widget button() {
    throw "FUTURE BUTTON";
  }

  static Widget checkBox() {
    throw "FUTURE DEVELOPMENT";
  }

  static Widget comboBox() {
    throw "FUTURE DEVELOPMENT";
  }

  static Widget calendar() {
    throw "FUTURE DEVELOPMENT";
  }

  static Widget column() {
    throw "FUTURE DEVELOPMENT";
  }

  static Widget icon() {
    throw "FUTURE DEVELOPMENT";
  }

  static Widget label() {
    throw "FUTURE DEVELOPMENT";
  }

  static Widget listView() {
    throw "FUTURE DEVELOPMENT";
  }

  static Widget mediaPlayer() {
    throw "FUTURE DEVELOPMENT";
  }

  static Widget image({
    required CImageType type,
    required dynamic src,
    Alignment alignment = Alignment.center,
    BoxFit? fit,
    double? height,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    double? width,
  }) {
    assert(
        CDataBroker.checkType<String>(src) ||
            CDataBroker.checkType<File>(src) ||
            CDataBroker.checkType<Uint8List>(src),
        "");
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

  Widget row() {
    throw "FUTURE DEVELOPMENT";
  }

  /// Provides a spacer with the ability to set a divider color within a
  /// horizontal or vertical layout of controls.
  static Widget spacer({
    Color? color,
    double? height,
    bool visible = true,
    double? width,
  }) {
    return Offstage(
      offstage: !visible,
      child: Container(
        height: height,
        width: width,
        color: color,
      ),
    );
  }

  Widget stackView() {
    throw "FUTURE DEVELOPMENT";
  }

  Widget tabItem() {
    throw "FUTURE DEVELOPMENT";
  }

  Widget tabbedView() {
    throw "FUTURE DEVELOPMENT";
  }

  Widget textField() {
    throw "FUTURE DEVELOPMENT";
  }

  Widget webView() {
    throw "FUTURE DEVELOPMENT";
  }
}

/// Builds a icon based button widget.
class CButtonControl extends StatelessWidget {
  /// Optional size to apply to all the labels.
  final double? fontSize;

  /// The icon to associate with the action.
  final dynamic icon;

  /// Identifies the size of the icon
  final double? iconSize;

  /// The action to take when tapped.
  final VoidCallback onTap;

  /// An optional title to place at the bottom of the icon button.
  final String? title;

  /// The tooltip to describe what the action does.
  final String? tooltip;

  /// Determines whether to display this button or not.
  final bool visible;

  /// Constructor for the widget.
  CButtonControl({
    this.fontSize,
    required this.icon,
    this.iconSize,
    required this.onTap,
    this.title,
    this.tooltip,
    this.visible = true,
    super.key,
  }) {
    assert(icon is IconData || icon is AssetImage,
        "icon can only be an Image or IconData type");
  }

  @override
  Widget build(BuildContext context) {
    final btn = IconButton(
      icon: icon is IconData
          ? Icon(icon, size: iconSize)
          : Image(
              image: icon,
              height: iconSize,
              width: iconSize,
            ),
      tooltip: tooltip,
      onPressed: onTap,
    );
    return Offstage(
      offstage: !visible,
      child: title != null && title!.isNotEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                btn,
                Text(title!, style: TextStyle(fontSize: fontSize)),
              ],
            )
          : btn,
    );
  }
}

/// Creates a dropdown box with a selection of custom values one can then
/// select from.
class CComboBoxControl<T> extends StatelessWidget {
  // Identifies the dropdown color.
  final Color? dropdownColor;

  /// Whether the control is enabled or not.
  final bool enabled;

  /// The size of the font for the dropdown items.
  final double? fontSize;

  /// The height of the control.
  final double? height;

  /// Helper text for the control.
  final String? helperText;

  /// The items to select from.
  final List<DropdownMenuItem<T>> items;

  /// Callback fired when the dropdown value is changed.
  final void Function(T?)? onChanged;

  /// The text color of the control.
  final Color? textColor;

  /// The title to label the control.
  final String? title;

  /// The current value of the control.
  final T value;

  /// The width of the control.
  final double? width;

  /// Whether the control is visible or not.
  final bool visible;

  /// Constructor for the class.
  const CComboBoxControl({
    this.dropdownColor,
    this.enabled = true,
    this.fontSize,
    this.height,
    this.helperText,
    required this.items,
    this.onChanged,
    this.textColor,
    this.title,
    required this.value,
    this.width,
    this.visible = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !visible,
      child: SizedBox(
        height: height,
        width: width,
        child: DropdownButtonFormField(
          isExpanded: true,
          value: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          dropdownColor: dropdownColor,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10.0),
            labelText: title,
            isDense: true,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: fontSize,
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              color: textColor,
              fontSize: fontSize,
            ),
            filled: true,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: textColor ?? const Color(0xFF000000),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Creates a stack layout allowing for items to be placed on top of either
/// background image or a background color.
class CStackView extends StatelessWidget {
  /// Optional image resource to a background image bundled with your app.
  final String? backgroundImage;

  /// Optional background color to set for the stack.
  final Color? backgroundColor;

  /// The children widgets to build on top of the stack.
  final List<Widget> children;

  /// Constructor for the widget.
  CStackView({
    this.backgroundImage,
    this.backgroundColor,
    required this.children,
    super.key,
  }) {
    assert(
        (backgroundImage != null && backgroundColor == null) ||
            (backgroundImage == null && backgroundColor != null),
        "Only backgroundImage or backgroundColor can be set.");
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> w = [];
    if (backgroundImage != null) {
      w.add(
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(backgroundImage!),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else if (backgroundColor != null) {
      w.add(
        Container(
          color: backgroundColor,
        ),
      );
    }
    w.addAll(children);
    return Stack(children: w);
  }
}

/// Constructs a multi-purpose text field for entering different types of data.
///
/// TODO: Need to format for other data types and a custom controller.
class CTextFieldControl extends StatelessWidget {
  /// Enable or disable the text field.
  final bool? enabled;

  /// Font size for the text field.
  final double? fontSize;

  /// The height of the text field.
  final double? height;

  /// Helper text for the text field.
  final String? helperText;

  /// The keyboard type to render for entering the data.
  final TextInputType? keyboardType;

  /// The max length of characters to utilize for the text field.
  final int? maxLength;

  /// The max lines for the text field.
  final int maxLines;

  /// Callback fired each time the text is updated.
  final Function(String)? onChanged;

  /// Callback fired when the editing is completed with the control
  final Function()? onEditingComplete;

  /// Whether the control is readonly or not.
  final bool readOnly;

  /// The color of the text within the text field.
  final Color? textColor;

  /// The title to supply with the text field.
  final String? title;

  /// The width of the text field.
  final double? width;

  /// The initial value of the text field.
  final String? initialValue;

  /// Whether to show or hide the text field control.
  final bool visible;

  /// Constructor of the class.
  const CTextFieldControl({
    this.enabled,
    this.fontSize,
    this.height,
    this.helperText,
    this.keyboardType,
    this.maxLength,
    this.maxLines = 1,
    this.onChanged,
    this.onEditingComplete,
    this.readOnly = false,
    this.textColor,
    this.title,
    this.width,
    this.initialValue,
    this.visible = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Offstage(
      offstage: !visible,
      child: SizedBox(
        width: width,
        height: height,
        child: TextFormField(
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(5.0),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: textColor ?? const Color(0xFF000000),
              ),
            ),
            filled: true,
            helperText: helperText,
            helperStyle: TextStyle(
              color: textColor,
              fontSize: fontSize,
            ),
            isDense: true,
            labelText: title,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: fontSize,
            ),
            // suffixIcon: TODO: for password field type or units.
          ),
          enabled: enabled,
          initialValue: initialValue,
          keyboardType: keyboardType,
          maxLength: maxLength,
          maxLines: maxLines,
          // minLines: minLines,
          // obscureText: TODO: for password field type,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          readOnly: readOnly,
          smartDashesType: SmartDashesType.disabled,
          smartQuotesType: SmartQuotesType.disabled,
        ),
      ),
    );
  }
}

/// Crates an embedded web view so you can interact and display web content.
class CWebView extends StatelessWidget {
  /// The url of the page to display within your app.
  final String url;

  /// Constructor for the class.
  CWebView({required this.url, super.key}) {
    assert(
      kIsWeb || Platform.isAndroid || Platform.isIOS,
      "CWebView only supported on mobile and web targets.",
    );
  }

  @override
  Widget build(BuildContext context) {
    return createCWebView(url);
  }
}
