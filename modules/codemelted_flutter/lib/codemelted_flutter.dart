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
/// flutter targets utilizing the [codemelted] namespace.
library codemelted_flutter;

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:codemelted_flutter/src/stub.dart'
    if (dart.library.io) 'package:codemelted_flutter/src/native.dart'
    if (dart.library.js) 'package:codemelted_flutter/src/web.dart' as platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:logging/logging.dart';
import 'package:http/http.dart' as http;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher_string.dart';
export 'package:url_launcher/url_launcher_string.dart' show LaunchMode;

// ============================================================================
// [Use Case Support Definitions] =============================================
// ============================================================================

// ----------------------------------------------------------------------------
// [App View Definitions] -----------------------------------------------------
// ----------------------------------------------------------------------------

/// Sets up a global navigator key for usage with dialogs rendered with the
/// [CodeMeltedAPI] dlgXXX functions.
final cNavigatorKey = GlobalKey<NavigatorState>();

/// Sets up a global scaffold key for opening drawers and such on the
/// [CodeMeltedAPI] appXXX functions.
final cScaffoldKey = GlobalKey<ScaffoldState>();

/// Provides the Single Page Application for the [CodeMeltedAPI.app] property
/// that returns the main view.
class _CAppView extends StatefulWidget {
  /// Tracks if the [CodeMeltedAPI.app] has already been called.
  static bool _isInitialized = false;

  /// Sets up the dictionary for usage with the SPA.
  static final uiState = CObjectDataNotifier(
    objData: {
      "darkTheme": ThemeData.dark(useMaterial3: true),
      "themeMode": ThemeMode.system,
      "theme": ThemeData.light(useMaterial3: true),
    },
  );

  /// Sets / gets the dark theme for the [CodeMeltedAPI.app].
  static ThemeData get darkTheme => uiState.get<ThemeData>("darkTheme");
  static set darkTheme(ThemeData? v) =>
      uiState.set<ThemeData?>("darkTheme", v, notify: true);

  /// Sets / gets the light theme for the [CodeMeltedAPI.app].
  static ThemeData get theme => uiState.get<ThemeData>("theme");
  static set theme(ThemeData? v) =>
      uiState.set<ThemeData?>("theme", v, notify: true);

  /// Sets / gets the theme mode for the [CodeMeltedAPI.app].
  static ThemeMode get themeMode => uiState.get<ThemeMode>("themeMode");
  static set themeMode(ThemeMode v) =>
      uiState.set<ThemeMode?>("themeMode", v, notify: true);

  /// Sets / gets the app title for the [CodeMeltedAPI.app].
  static String? get title => uiState.get<String?>("title");
  static set title(String? v) => uiState.set<String?>("title", v, notify: true);

  /// Sets / removes the header area of the [CodeMeltedAPI.app].
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

  /// Sets / removes the content area of the [CodeMeltedAPI.app].
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

  /// Sets / removes the footer area of the [CodeMeltedAPI.app].
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

  /// Sets / removes a floating action button for the [CodeMeltedAPI.app].
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

  /// Sets / removes a left sided drawer for the [CodeMeltedAPI.app].
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

  /// Sets / removes a right sided drawer from the [CodeMeltedAPI.app].
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

  /// Will programmatically close an open drawer on the [CodeMeltedAPI.app].
  static void closeDrawer() {
    if (cScaffoldKey.currentState!.isDrawerOpen) {
      cScaffoldKey.currentState!.closeDrawer();
    }
    if (cScaffoldKey.currentState!.isEndDrawerOpen) {
      cScaffoldKey.currentState!.closeEndDrawer();
    }
  }

  /// Will programmatically open a drawer on the [CodeMeltedAPI.app].
  static void openDrawer({bool isEndDrawer = false}) {
    if (!isEndDrawer && cScaffoldKey.currentState!.hasDrawer) {
      cScaffoldKey.currentState!.openDrawer();
    } else if (cScaffoldKey.currentState!.hasEndDrawer) {
      cScaffoldKey.currentState!.openEndDrawer();
    }
  }

  @override
  State<StatefulWidget> createState() => _CAppViewState();

  _CAppView() {
    assert(
      !_isInitialized,
      "Only one CAppView can be created. It sets up a SPA.",
    );
    _isInitialized = true;
  }
}

class _CAppViewState extends State<_CAppView> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: _CAppView.darkTheme,
      navigatorKey: cNavigatorKey,
      theme: _CAppView.theme,
      themeMode: _CAppView.themeMode,
      title: _CAppView.title ?? "",
      home: Scaffold(
        appBar: _CAppView.uiState.get<AppBar?>("appBar"),
        body: _CAppView.uiState.get<CObject?>("content")?['body'],
        extendBody:
            _CAppView.uiState.get<CObject?>("content")?['extendBody'] ?? false,
        extendBodyBehindAppBar: _CAppView.uiState
                .get<CObject?>("content")?["extendBodyBehindAppBar"] ??
            false,
        bottomNavigationBar:
            _CAppView.uiState.get<BottomAppBar?>("bottomAppBar"),
        drawer: _CAppView.uiState.get<Widget?>("drawer"),
        endDrawer: _CAppView.uiState.get<Widget?>("endDrawer"),
        floatingActionButton:
            _CAppView.uiState.get<Widget?>("floatingActionButton"),
        floatingActionButtonLocation: _CAppView.uiState
            .get<FloatingActionButtonLocation?>("floatingActionButtonLocation"),
        key: cScaffoldKey,
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// [Async IO Definition] ------------------------------------------------------
// ----------------------------------------------------------------------------

/// Defines the actions supported by the [CodeMeltedAPI.asyncTask] function.
enum CAsyncTaskAction { background, interval, sleep, timeout }

/// The task to run as part of the [CodeMeltedAPI.asyncTask] function. It
/// defines the logic to run as part of the async call and possibly return
/// a result.
typedef CAsyncTaskFunction = dynamic Function([dynamic]);

/// Defines the supported worker types for the [CodeMeltedAPI.asyncWorker]
/// function that provides a dedicated FIFO background task.
enum CAsyncWorkerType { isolate, process, webWorker }

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

/// Base definition class for the returned [CodeMeltedAPI.asyncWorker] call
/// to post messages to the background worker
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

// ----------------------------------------------------------------------------
// [Audio Player Definition] --------------------------------------------------
// ----------------------------------------------------------------------------

/// Identifies the source for the [CAudioPlayer] data playback.
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

/// Provides the ability to play audio files via [CodeMeltedAPI.audioFile] or
/// perform text to speech via [CodeMeltedAPI.audioTTS] within your
/// application.
class CAudioPlayer {
  // Member Fields:
  late CAudioState _state;
  late dynamic _data;
  late dynamic _player;

  CAudioPlayer._(dynamic player, dynamic data) {
    _state = CAudioState.stopped;
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
}

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
// [Fetch Data Definitions] ---------------------------------------------------
// ----------------------------------------------------------------------------

/// The actions supported by the [CodeMeltedAPI.fetch] call.
enum CFetchAction { delete, get, post, put }

/// The response object that results from the [CodeMeltedAPI.fetch] call.
class CFetchResponse {
  /// The data received.
  final dynamic data;

  /// That status of the  call.
  final int status;

  /// Any text associated with the status.
  final String statusText;

  /// Data is assumed to be a [CObject] JSON format and is returned as such or
  /// null if it is not.
  CObject? get asObject => data as CObject?;

  /// Data is assumed to be a collection of bytes.
  Uint8List get asBytes => data as Uint8List;

  /// Data is assumed to be a String and is returned as such or null if it is
  /// not.
  String? get asString => data as String?;

  /// Constructs the [CFetchResponse] object.
  CFetchResponse(this.data, this.status, this.statusText);
}

// ----------------------------------------------------------------------------
// [Hardware Device Definition] -----------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Link Opener Definition] ---------------------------------------------------
// ----------------------------------------------------------------------------

/// Represents how the [CodeMeltedAPI.open] launches a [CSchemeType].
typedef LaunchUrlStringHandler = Future<bool> Function(
  String urlString, {
  LaunchMode mode,
  WebViewConfiguration webViewConfiguration,
  String? webOnlyWindowName,
});

/// Optional parameter for the [CodeMeltedAPI.open] mailto scheme to facilitate
/// translating the more complicated URL.
class CMailToParams {
  /// The list of email addresses to send the email.
  final List<String> mailto;

  /// The carbon copies to send the email.
  final List<String> cc;

  /// The blind carbon copies to send the email.
  final List<String> bcc;

  /// The subject of the email.
  final String subject;

  /// The body of the email.
  final String body;

  @override
  String toString() {
    var url = "";

    // Go format the mailto part of the url
    for (final e in mailto) {
      url += "$e;";
    }
    url = url.substring(0, url.length - 1);

    // Go format the cc part of the url
    var delimiter = "?";
    if (cc.isNotEmpty) {
      url += "${delimiter}cc=";
      delimiter = "&";
      for (final e in cc) {
        url += "$e;";
      }
      url = url.substring(0, url.length - 1);
    }

    // Go format the bcc part of the url
    if (bcc.isNotEmpty) {
      url += "${delimiter}bcc=";
      delimiter = "&";
      for (final e in bcc) {
        url += "$e;";
      }
      url = url.substring(0, url.length - 1);
    }

    // Go format the subject part
    if (subject.trim().isNotEmpty) {
      url += "${delimiter}subject=${subject.trim()}";
      delimiter = "&";
    }

    // Go format the body part
    if (body.trim().isNotEmpty) {
      url += "${delimiter}body=${body.trim()}";
      delimiter = "&";
    }

    return url;
  }

  /// Constructs the object.
  CMailToParams({
    required this.mailto,
    this.cc = const <String>[],
    this.bcc = const <String>[],
    this.subject = "",
    this.body = "",
  });
}

/// Identifies the scheme to utilize as part of the [CodeMeltedAPI.open]
/// function.
enum CSchemeType {
  /// Will open the program associated with the file.
  file("file:"),

  /// Will open a web browser with http.
  http("http://"),

  /// Will open a web browser with https.
  https("https://"),

  /// Will open the default email program to send an email.
  mailto("mailto:"),

  /// Will open the default telephone program to make a call.
  tel("tel:"),

  /// Will open the default texting app to send a text.
  sms("sms:");

  /// Identifies the leading scheme to form a URL.
  final String leading;

  const CSchemeType(this.leading);

  /// Will return the formatted URL based on the scheme and the
  /// data provided.
  String getUrl(String data) => "$leading$data";
}

// ----------------------------------------------------------------------------
// [Logger Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

/// Handler to support the [CodeMeltedAPI] for post processing of a logged
/// event.
typedef CLogEventHandler = void Function(CLogRecord);

/// Identifies the supported log levels for the [CodeMeltedAPI].
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
  final Level _level;

  const CLogLevel(this._level);
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

// ----------------------------------------------------------------------------
// [Math Definition] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/// Defines the formulas supported by the [CodeMeltedAPI.math] function.
enum CMathFormula {
  /// Kilometers squared to meters squared
  area_km2_to_m2;
}

/// Internal extension to tie the formulas to the [CMathFormula] enumerated
/// values.
extension on CMathFormula {
  /// The mapping of the enumerated formulas to actual formulas.
  static final _data = {
    CMathFormula.area_km2_to_m2: (List<double> v) => v[0] * 1e+6,
  };

  /// Private method to support the [CodeMeltedAPI.math] method.
  double _calculate(List<double> v) => _data[this]!(v);
}

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

// TODO: Tab Theme definition to follow style of other widgets.
//       1. Remove items from CTabItem. They should be in theme.
//       2. Allow for customization of icon placement in relation to title.
//       3. Ensure at least title or icon are specified.
//       4. Take some of the scaffold items from the uiTabView and add to the
//          theme.

// TODO: Text Field Theme definition to follow style of other uiComboBox.
//       This represents the standard I would like to shoot for.

/// Provides an alternative to the flutter DialogTheme class. This is due
/// to the fact it really does not theme much when utilizing the built-in
/// [AlertDialog] of Flutter wrapped in the [CodeMeltedAPI] dlgXXX functions.
class CDialogTheme extends ThemeExtension<CDialogTheme> {
  /// Background color for the entire dialog panel.
  final Color? backgroundColor;

  /// The title foreground color for the text and close icon.
  final Color? titleColor;

  /// The foreground color of the content color for all dialog types minus
  /// [CodeMeltedAPI.dlgCustom]. There the developer sets the color of the
  /// content.
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

/// Provides an extension on the ThemeData object to access the [CDialogTheme]
/// object as part of the ThemeData object.
extension on ThemeData {
  /// Accesses the [CDialogTheme] for the [CodeMeltedAPI] dlgXXX methods.
  CDialogTheme get cDialogTheme => extension<CDialogTheme>()!;
}

// ----------------------------------------------------------------------------
// [Web RTC Definition] -------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Widget Definitions] -------------------------------------------------------
// ----------------------------------------------------------------------------

/// Supports identifying the [CodeMeltedAPI.uiButton] widget constructed.
enum CButtonType { elevated, filled, icon, outlined, text }

/// Supports identifying what [CodeMeltedAPI.uiImage] is constructed when
/// utilized.
enum CImageType { asset, file, memory, network }

enum CTabIconPlacement { top, leading, trailing }

/// Defines a tab item to utilize with the [CodeMeltedAPI.uiTabView] method.
class CTabItem {
  /// The content displayed with the tab.
  final Widget content;

  /// An icon for the tab within the tab view.
  final dynamic icon;

  /// Determines where to place the icon with the title if title is specified.
  final CTabIconPlacement iconPlacement;

  /// Specifies the margin between the icon and the title.
  final EdgeInsetsGeometry? iconMargin;

  /// A title with the tab within the tab view.
  final String? title;

  CTabItem({
    required this.content,
    this.icon,
    this.iconPlacement = CTabIconPlacement.top,
    this.iconMargin,
    this.title,
  }) {
    assert(
      icon != null || title != null,
      "At least icon or title must have a valid value",
    );
    assert(
      icon is IconData || icon is Image || icon == null,
      "icon can only be an Image / IconData / null type",
    );
  }
}

// ============================================================================
// [Main API Implementation] ==================================================
// ============================================================================

/// Sets up the API wrapper implemented the codemelted_developer identified use
/// cases for flutter applications.
class CodeMeltedAPI {
  // --------------------------------------------------------------------------
  // [App View Implementation] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Accesses a Single Page Application (SPA) for the overall module. This
  /// is called after being configured via the appXXX functions in the runApp
  /// of the main().
  Widget get app => _CAppView();

  /// Sets the [CodeMeltedAPI.app] dark theme.
  set appDarkTheme(ThemeData? v) => _CAppView.darkTheme = v;

  /// Sets the [CodeMeltedAPI.app] light theme.
  set appTheme(ThemeData? v) => _CAppView.theme = v;

  /// Sets the [CodeMeltedAPI.app] theme mode.
  set appThemeMode(ThemeMode v) => _CAppView.themeMode = v;

  /// Sets / removes the [CodeMeltedAPI.app] title.
  set appTitle(String? v) => _CAppView.title = v;
  String? get appTitle => _CAppView.title;

  /// Sets / removes the [CodeMeltedAPI.app] header area.
  void appHeader({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    _CAppView.header(
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      forceMaterialTransparency: forceMaterialTransparency,
      leading: leading,
      style: style,
      title: title,
    );
  }

  /// Sets / removes the [CodeMeltedAPI.app] content area.
  void appContent({
    required Widget? body,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
  }) {
    _CAppView.content(
      body: body,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  /// Sets / removes the [CodeMeltedAPI.app] footer area.
  void appFooter({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    _CAppView.footer(
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      forceMaterialTransparency: forceMaterialTransparency,
      leading: leading,
      style: style,
      title: title,
    );
  }

  /// Sets / removes the [CodeMeltedAPI.app] floating action button.
  void appFloatingActionButton({
    Widget? button,
    FloatingActionButtonLocation? location,
  }) {
    _CAppView.floatingActionButton(button: button, location: location);
  }

  /// Sets / removes the [CodeMeltedAPI.app] drawer.
  void appDrawer({Widget? header, List<Widget>? items}) {
    _CAppView.drawer(header: header, items: items);
  }

  /// Sets / removes the [CodeMeltedAPI.app] end drawer.
  void appEndDrawer({Widget? header, List<Widget>? items}) {
    _CAppView.endDrawer(header: header, items: items);
  }

  /// Closes the [CodeMeltedAPI.app] drawer or end drawer.
  void appCloseDrawer() => _CAppView.closeDrawer();

  /// Opens the [CodeMeltedAPI.app] drawer or end drawer.
  void appOpenDrawer({bool isEndDrawer = false}) {
    _CAppView.openDrawer(isEndDrawer: isEndDrawer);
  }

  /// Provides the ability to get items from the global app state.
  T getAppState<T>(String key) => _CAppView.uiState.get<T>(key);

  /// Provides the ability to set items on the global app state.
  void setAppState<T>(String key, T value) =>
      _CAppView.uiState.set<T>(key, value);

  // --------------------------------------------------------------------------
  // [Async IO Implementation] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Supports the running of singular tasks asynchronously. This is either
  /// as a [CAsyncTaskAction.background] isolate (native only), a
  /// repeating [CAsyncTaskAction.interval] returned as as a [Timer] object,
  /// a [CAsyncTaskAction.sleep] action of an async task, or running a
  /// [CAsyncTaskAction.timeout] action. The background and timeout actions
  /// can also return results that are calculated via the [CAsyncTaskFunction]
  /// definition.
  Future<dynamic> asyncTask({
    required CAsyncTaskAction action,
    CAsyncTaskFunction? task,
    dynamic data,
    int delay = 0,
  }) async {
    switch (action) {
      case CAsyncTaskAction.background:
        assert(!kIsWeb, "This is only available on native platforms");
        return (await Isolate.run<dynamic>(() => task!(data)));
      case CAsyncTaskAction.interval:
        return Timer.periodic(
          Duration(milliseconds: delay),
          (timer) {
            task!();
          },
        );
      case CAsyncTaskAction.sleep:
        return (await Future.delayed(Duration(milliseconds: delay)));
      case CAsyncTaskAction.timeout:
        return (
          await Future.delayed(
            Duration(milliseconds: delay),
            () => task!(data),
          ),
        );
    }
  }

  /// @nodoc
  Future<CAsyncWorker> asyncWorker({
    required CAsyncWorkerType type,
    required CAsyncWorkerListener listener,
    String? url,
  }) async =>
      throw "NOT IMPLEMENTED YET";

  // --------------------------------------------------------------------------
  // [Audio Player Implementation] --------------------------------------------
  // --------------------------------------------------------------------------

  /// Builds a [CAudioPlayer] identifying an audio source and specifying the
  /// location of said audio source.
  Future<CAudioPlayer> audioFile({
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
      logError(data: event, st: StackTrace.current);
    });
    return CAudioPlayer._(player, audioSource);
  }

  /// Builds a [CAudioPlayer] to perform text-to-speech of the specified data.
  Future<CAudioPlayer> audioTTS({
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
      logError(data: message, st: StackTrace.current);
    });
    return CAudioPlayer._(player, data);
  }

  // --------------------------------------------------------------------------
  // [Console Implementation] -------------------------------------------------
  // --------------------------------------------------------------------------

  // Not applicable to the flutter module.

  // --------------------------------------------------------------------------
  // [Database Implementation] ------------------------------------------------
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // [Data Broker Implementation] ---------------------------------------------
  // --------------------------------------------------------------------------

  /// Determines if a [CObject] has a given property contained within.
  bool checkHasProperty(CObject obj, String key) => obj.containsKey(key);

  /// Determines if the variable is of the expected type.
  bool checkType<T>(dynamic v) => v is T;

  /// Determines if the data type is a valid URL.
  bool checkValidURL(String v) => Uri.tryParse(v) != null;

  /// Will convert data into a JSON [CObject] or return null if the decode
  /// could not be achieved.
  CObject? jsonParse(String data) => data.asObject();

  /// Will encode the JSON [CObject] into a string or null if the encode
  /// could not be achieved.
  String? jsonStringify(CObject data) => data.stringify();

  /// Same as [checkHasProperty] but throws an exception if the key is not
  /// found.
  void tryHasProperty(CObject obj, String key) {
    if (!checkHasProperty(obj, key)) {
      throw "obj does not contain '$key' key";
    }
  }

  /// Same as [checkType] but throws an exception if not of the expected
  /// type.
  void tryType<T>(dynamic v) {
    if (!checkType<T>(v)) {
      throw "variable was not of type '$T'";
    }
  }

  /// Same as [checkValidURL] but throws an exception if not a valid URL type.
  void tryValidURL(String v) {
    if (!checkValidURL(v)) {
      throw "v was not a valid URL string";
    }
  }

  // --------------------------------------------------------------------------
  // [Device Orientation Implementation] --------------------------------------
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // [Dialog Implementation] --------------------------------------------------
  // --------------------------------------------------------------------------

  /// Internal tracking variable to properly handle browser display within
  /// rounded borders or the other types of dialogs.
  bool _isBrowserAction = false;

  /// The default height for a medium dialog.
  static const _smallHeight = 256.0;

  /// The default width for a medium dialog.
  static const _smallWidth = 320.0;

  /// Will display information about your flutter app.
  Future<void> dlgAbout({
    Widget? appIcon,
    String? appName,
    String? appVersion,
    String? appLegalese,
  }) async {
    showLicensePage(
      context: cNavigatorKey.currentContext!,
      applicationIcon: appIcon,
      applicationName: appName,
      applicationVersion: appVersion,
      applicationLegalese: appLegalese,
      useRootNavigator: true,
    );
  }

  /// Provides a simple way to display a message to the user that must
  /// be dismissed.
  Future<void> dlgAlert({
    required String message,
    double height = _smallHeight,
    String? title,
    double width = _smallWidth,
  }) async {
    return dlgCustom(
      actions: [
        _buildButton<void>("OK"),
      ],
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
  Future<void> dlgBrowser({
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
    var dlgHeight = height ??
        uiHeight(
              cNavigatorKey.currentContext!,
            ) *
            0.85;
    var dlgWidth = width ??
        uiWidth(
              cNavigatorKey.currentContext!,
            ) *
            0.95;
    return dlgCustom(
      actions: [
        _buildButton<void>("OK"),
      ],
      content: uiWebView(url: url),
      title: title ?? "Browser",
      height: dlgHeight,
      width: dlgWidth,
    );
  }

  /// Shows a popup dialog with a list of options returning the index selected
  /// or -1 if canceled.
  Future<int> dlgChoose({
    required String title,
    required List<String> options,
  }) async {
    // Form up our dropdown options
    final dropdownItems = <DropdownMenuEntry<int>>[];
    for (final (index, option) in options.indexed) {
      dropdownItems.add(DropdownMenuEntry(label: option, value: index));
    }
    int? answer = 0;
    return (await dlgCustom<int?>(
          actions: [
            _buildButton<int>("OK", answer),
          ],
          content: uiComboBox(
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
                padding: WidgetStatePropertyAll(EdgeInsets.zero),
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
  void dlgClose<T>([T? answer]) {
    Navigator.of(
      cNavigatorKey.currentContext!,
      rootNavigator: true,
    ).pop(answer);
    _isBrowserAction = false;
  }

  /// Provides a Yes/No confirmation dialog with the displayed message as the
  /// question. True is returned for Yes and False for a No or cancel.
  Future<bool> dlgConfirm({
    required String message,
    double height = _smallHeight,
    String? title,
    double width = _smallWidth,
  }) async {
    return (await dlgCustom<bool?>(
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
  /// [CodeMeltedAPI.dlgClose] for returning values via your actions array.
  Future<T?> dlgCustom<T>({
    required Widget content,
    required String title,
    List<Widget>? actions,
    double height = _smallHeight,
    double width = _smallWidth,
  }) async {
    return showDialog<T>(
      barrierDismissible: false,
      context: cNavigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        backgroundColor: _getTheme().backgroundColor,
        insetPadding: EdgeInsets.zero,
        scrollable: true,
        titlePadding: const EdgeInsets.only(bottom: 25.0),
        title: uiCenter(child: uiLabel(data: title)),
        contentPadding: EdgeInsets.only(
          left: _isBrowserAction ? 1.0 : 25.0,
          right: _isBrowserAction ? 1.0 : 25.0,
          bottom: _isBrowserAction ? 25.0 : 0.0,
        ),
        content: SizedBox(
          height: height,
          width: width,
          child: content,
        ),
        actionsPadding: const EdgeInsets.all(5.0),
        actionsAlignment: MainAxisAlignment.center,
        actions: actions,
      ),
    );
  }

  /// Provides the ability to run an async task and present a wait dialog. It
  /// is important you call [CodeMeltedAPI.dlgClose] to properly clear the
  /// dialog and return any value expected.
  Future<T?> dlgLoading<T>({
    double height = _smallHeight,
    required String message,
    required Future<void> Function() task,
    String? title,
    double width = _smallWidth,
  }) async {
    Future.delayed(Duration.zero, task);
    return dlgCustom<T>(
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
      height: height,
      title: title ?? "Please Wait",
      width: width,
    );
  }

  /// Provides the ability to show an input prompt to retrieve an answer to a
  /// question. The value is returned back as a string. If a user cancels the
  /// action an empty string is returned.
  Future<String> dlgPrompt({
    required String title,
  }) async {
    var answer = "";
    return (await dlgCustom<String?>(
          actions: [
            _buildButton<String>("OK", answer),
          ],
          content: uiContainer(
            height: 30.0,
            width: 200.0,
            child: uiTextField(
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
          ),
          title: title,
        )) ??
        "";
  }

  /// Provides the ability to show a full page within the [CodeMeltedAPI.app] with the
  /// ability to specify the title and actions in the top bar. You can also
  /// specify bottom actions.
  void dlgFullPage({
    required Widget content,
    List<Widget>? actions,
    bool? centerTitle,
    bool showBackButton = true,
    String? title,
  }) async {
    Navigator.push(
      cScaffoldKey.currentContext!,
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
  void dlgSnackbar({
    required Widget content,
    SnackBarAction? action,
    Clip clipBehavior = Clip.hardEdge,
    int? seconds,
  }) {
    ScaffoldMessenger.of(cNavigatorKey.currentContext!).showSnackBar(
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
  Widget _buildButton<T>(String title, [T? answer]) => uiButton(
        type: CButtonType.text,
        title: title,
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(
            _getTheme().actionsColor,
          ),
        ),
        onPressed: () => dlgClose<T>(answer),
      );

  /// Helper method to get the currently active dialog theme.
  static CDialogTheme _getTheme() =>
      Theme.of(cScaffoldKey.currentContext!).cDialogTheme;

  // --------------------------------------------------------------------------
  // [Disk Manager Implementation] --------------------------------------------
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // [Fetch Implementation] ---------------------------------------------------
  // --------------------------------------------------------------------------

  /// Implements the ability to fetch a server's REST API endpoint to retrieve
  /// and manage data. The actions for the REST API are controlled via the
  /// [CFetchAction] enumerated values with optional items to pass to the
  /// endpoint. The result is a [CFetchResponse] wrapping the REST API endpoint
  /// response to the request.
  Future<CFetchResponse> fetch({
    required CFetchAction action,
    Object? body,
    Map<String, String>? headers,
    int timeoutSeconds = 10,
    required String url,
  }) async {
    try {
      // Go carry out the fetch request
      var duration = Duration(seconds: timeoutSeconds);
      http.Response resp;
      var uri = Uri.parse(url);
      if (action == CFetchAction.get) {
        resp = await http.get(uri, headers: headers).timeout(duration);
      } else if (action == CFetchAction.delete) {
        resp = await http
            .delete(uri, headers: headers, body: body)
            .timeout(duration);
      } else if (action == CFetchAction.put) {
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
      return CFetchResponse(data, status, statusText);
    } on TimeoutException catch (ex, st) {
      // We had a timeout occur, log it and return it
      logWarning(data: ex, st: st);
      return CFetchResponse(null, 408, "Request Timeout");
    } catch (ex, st) {
      // Something unexpected happened, log it, and return it.
      logError(data: ex, st: st);
      return CFetchResponse(null, 418, "Unknown Error Encountered");
    }
  }

  // --------------------------------------------------------------------------
  // [Hardware Device Implementation] -----------------------------------------
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // [Link Opener Implementation] ---------------------------------------------
  // --------------------------------------------------------------------------

  Future<bool> open({
    required CSchemeType scheme,
    CMailToParams? mailtoParams,
    String? url,
    LaunchMode mode = LaunchMode.platformDefault,
    String? target,
    LaunchUrlStringHandler? mock,
  }) async {
    var handler = mock ?? launchUrlString;
    try {
      // Go form our URL to launch
      var urlToLaunch = "";
      if (scheme == CSchemeType.file ||
          scheme == CSchemeType.http ||
          scheme == CSchemeType.https ||
          scheme == CSchemeType.sms ||
          scheme == CSchemeType.tel) {
        urlToLaunch = scheme.getUrl(url!);
      } else {
        urlToLaunch = mailtoParams != null
            ? mailtoParams.toString()
            : scheme.getUrl(url!);
      }

      // Go attempt to launch it.
      return await handler(
        urlToLaunch,
        mode: mode,
        webOnlyWindowName: target,
      );
    } catch (ex, st) {
      logError(data: ex, st: st);
      return false;
    }
  }

  // --------------------------------------------------------------------------
  // [Logger Implementation] --------------------------------------------------
  // --------------------------------------------------------------------------

  /// Sets up the internal logger for the module.
  final _logger = Logger("CodeMelted-Logger");

  /// Handles the initialization of the logger for the [CodeMeltedAPI] module.
  void _initLogger() {
    // Hookup into the flutter runtime error handlers so any error it
    // encounters, is also reported.
    FlutterError.onError = (details) {
      logError(data: details.exception, st: details.stack);
    };

    PlatformDispatcher.instance.onError = (error, st) {
      logError(data: error.toString(), st: st);
      return true;
    };

    // Now configure our logger items.
    Logger.root.level = CLogLevel.warning._level;
    Logger.root.onRecord.listen((v) {
      var record = CLogRecord(v);
      if (kDebugMode || kIsWeb) {
        if (platform.getEnvironment('FLUTTER_TEST') == null) {
          // ignore: avoid_print
          print(record);
        }
      }

      if (onLoggedEvent != null) {
        onLoggedEvent!(record);
      }
    });
  }

  /// Sets / gets the [CLogLevel] of the [CodeMeltedAPI] module logging
  /// facility.
  static set logLevel(CLogLevel v) => Logger.root.level = v._level;
  static CLogLevel get logLevel {
    return CLogLevel.values.firstWhere(
      (element) => element._level == Logger.root.level,
    );
  }

  /// Establishes the [CLogEventHandler] to facilitate post log processing
  /// of a [CodeMeltedAPI] module logged event.
  CLogEventHandler? onLoggedEvent;

  /// Will log debug level messages via the module.
  void logDebug({Object? data, StackTrace? st}) =>
      _logger.log(CLogLevel.debug._level, data, null, st);

  /// Will log info level messages via the module.
  void logInfo({Object? data, StackTrace? st}) =>
      _logger.log(CLogLevel.info._level, data, null, st);

  /// Will log warning level messages via the module.
  void logWarning({Object? data, StackTrace? st}) =>
      _logger.log(CLogLevel.warning._level, data, null, st);

  /// Will log error level messages via the module.
  void logError({Object? data, StackTrace? st}) =>
      _logger.log(CLogLevel.error._level, data, null, st);

  // --------------------------------------------------------------------------
  // [Math Implementation] ----------------------------------------------------
  // --------------------------------------------------------------------------

  /// Runs the specified [CMathFormula] with the specified variables returning
  /// the calculated result.
  double math({required CMathFormula formula, required List<double> vars}) =>
      formula._calculate(vars);

  // --------------------------------------------------------------------------
  // [Network Socket Implementation] ------------------------------------------
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // [Runtime Implementation] -------------------------------------------------
  // --------------------------------------------------------------------------

  /// Will search for the specified environment variable returning null if not
  /// found.
  String? environment(String key) => platform.getEnvironment(key);

  /// Determines if the application is a PWA. Will only return true if the
  /// app is a web targeted app and installed as a PWA.
  bool get isPWA => platform.isPWA;

  // --------------------------------------------------------------------------
  // [Share Implementation] ---------------------------------------------------
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // [Storage Implementation] -------------------------------------------------
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // [Theme Implementation] ---------------------------------------------------
  // --------------------------------------------------------------------------

  /// Utility method to create ThemeData objects but it only exposes the
  /// material3 themes so that any application theming is done with the
  /// future in mind.
  ThemeData themeCreate({
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

  // --------------------------------------------------------------------------
  // [Web RTC Implementation] -------------------------------------------------
  // --------------------------------------------------------------------------

  // --------------------------------------------------------------------------
  // [Widget Implementation] --------------------------------------------------
  // --------------------------------------------------------------------------

  /// Will construct a stateless button to handle press events of said button.
  /// The button is determined via the [CButtonType] enumeration which will
  /// provide the look and feel of the button. The style is handled by that
  /// particular buttons theme data object but to set the button individually,
  /// utilize the style override. These are stateless buttons so any changing
  /// of them is up to the parent.
  Widget uiButton({
    required void Function() onPressed,
    required String title,
    required CButtonType type,
    Key? key,
    bool enabled = true,
    dynamic icon,
    ButtonStyle? style,
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

    return PointerInterceptor(
      key: key,
      intercepting: kIsWeb,
      child: btn!,
    );
  }

  /// Provides the ability to center a widget with the ability to specify
  /// the visibility of the child tree of widgets wrapped by this.
  Widget uiCenter({
    Key? key,
    Widget? child,
    double? heightFactor,
    double? widthFactor,
  }) {
    return Center(
      key: key,
      heightFactor: heightFactor,
      widthFactor: widthFactor,
      child: child,
    );
  }

  /// Layout to put widgets vertically.
  Widget uiColumn({
    required List<Widget> children,
    Key? key,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Creates a customizable combo box drop down with the ability to implement
  /// a search box to filter the combo box.
  Widget uiComboBox<T>({
    required List<DropdownMenuEntry<T>> dropdownMenuEntries,
    Key? key,
    bool enabled = true,
    bool enableFilter = false,
    bool enableSearch = true,
    String? errorText,
    double? menuHeight,
    String? helperText,
    String? hintText,
    T? initialSelection,
    Widget? label,
    dynamic leadingIcon,
    void Function(T?)? onSelected,
    int? Function(List<DropdownMenuEntry<T>>, String)? searchCallback,
    DropdownMenuThemeData? style,
    dynamic trailingIcon,
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
      menuHeight: menuHeight,
      onSelected: onSelected,
      searchCallback: searchCallback,
      trailingIcon:
          trailingIcon is IconData ? Icon(trailingIcon) : trailingIcon,
      width: width,
    );
    return style != null
        ? DropdownMenuTheme(
            data: style,
            child: menu,
          )
        : menu;
  }

  /// The most basic component for setting up a UI. This widget can be utilized
  /// to setup padding, margins, or build custom stylized widgets combining
  /// said widget or layouts to build a more complex widget.
  Widget uiContainer({
    Key? key,
    AlignmentGeometry? alignment,
    EdgeInsetsGeometry? padding,
    Color? color,
    Decoration? decoration,
    Decoration? foregroundDecoration,
    double? width,
    double? height,
    BoxConstraints? constraints,
    EdgeInsetsGeometry? margin,
    Matrix4? transform,
    AlignmentGeometry? transformAlignment,
    Clip clipBehavior = Clip.none,
    Widget? child,
  }) {
    return Container(
      key: key,
      alignment: alignment,
      padding: padding,
      color: color,
      decoration: decoration,
      foregroundDecoration: foregroundDecoration,
      width: width,
      height: height,
      constraints: constraints,
      margin: margin,
      transform: transform,
      transformAlignment: transformAlignment,
      clipBehavior: clipBehavior,
      child: child,
    );
  }

  /// Creates a vertical or horizontal spacer between widgets that can be
  /// hidden if necessary.
  Widget uiDivider({
    Key? key,
    double? height,
    double? width,
    Color color = Colors.transparent,
  }) {
    return Container(
      key: key,
      color: color,
      height: height,
      width: width,
    );
  }

  /// Provides the ability to have an expansion list of widgets.
  Widget uiExpandedTile({
    required List<Widget> children,
    required Widget title,
    Key? key,
    bool enabled = true,
    bool initiallyExpanded = false,
    dynamic leading,
    ExpansionTileThemeData? style,
    Widget? subtitle,
    dynamic trailing,
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

    return style != null ? ExpansionTileTheme(data: style, child: w) : w;
  }

  /// Provides a wrapper for an asynchronous widget to load data and then
  /// present it when completed.
  Widget uiFutureBuilder<T>({
    required Widget Function(BuildContext, AsyncSnapshot<T>) builder,
    required Future<T>? future,
    Key? key,
    T? initialData,
  }) {
    return FutureBuilder<T>(
      key: key,
      initialData: initialData,
      future: future,
      builder: builder,
    );
  }

  /// Creates a scrollable grid layout of widgets that based on the
  /// crossAxisCount.
  static Widget uiGridView({
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

  /// Retrieves the total height of the specified context.
  double uiHeight(BuildContext context) => MediaQuery.of(context).size.height;

  /// Will create an image widget based on the specified [CImageType]
  /// enumerated value and display it when available based on the
  /// characteristics specified with the widget. No theme controls this widget
  /// type so the characteristics are unique to each widget created.
  Image uiImage({
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
  Widget uiLabel({
    required String data,
    Key? key,
    int? maxLines,
    bool? softWrap,
    TextStyle? style,
    void Function()? onTap,
  }) {
    final w = Text(
      data,
      key: key,
      maxLines: maxLines,
      softWrap: softWrap,
      style: style,
    );

    return onTap != null
        ? InkWell(
            onTap: onTap,
            child: w,
          )
        : w;
  }

  /// Creates a selectable widget to be part of a view of selectable items.
  Widget uiListTile({
    required void Function() onTap,
    Key? key,
    bool enabled = true,
    dynamic leading,
    Widget? title,
    Widget? subtitle,
    dynamic trailing,
    ListTileThemeData? style,
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

    return style != null
        ? ListTileTheme(
            key: key,
            data: style,
            child: w,
          )
        : w;
  }

  /// Provides a list view of widgets with automatic scrolling that can be
  /// set for vertical (default) or horizontal.
  Widget uiListView({
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

  /// Layout to put widgets horizontally.
  Widget uiRow({
    required List<Widget> children,
    Key? key,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      key: key,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Creates a stacked widget based on the children allowing for a custom
  /// look and feel for "special" widgets that stack bottom to top and overlap.
  Widget uiStack({
    required List<Widget> children,
    Key? key,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
    Clip clipBehavior = Clip.hardEdge,
    StackFit fit = StackFit.loose,
    TextDirection? textDirection,
  }) {
    return Stack(
      alignment: alignment,
      clipBehavior: clipBehavior,
      fit: fit,
      key: key,
      textDirection: textDirection,
      children: children,
    );
  }

  /// Constructs a tab view of content to allow for users to switch between
  /// widgets of data.
  Widget uiTabView({
    required List<CTabItem> tabItems,
    Key? key,
    bool automaticIndicatorColorAdjustment = true,
    Color? backgroundColor,
    Clip clipBehavior = Clip.hardEdge,
    double? height,
    double indicatorWeight = 2.0,
    bool isScrollable = false,
    void Function(int)? onTap,
    TabBarTheme? style,
    double viewportFraction = 1.0,
  }) {
    // Parse the tabItems to construct the tab data.
    var tabs = <Widget>[];
    var contentList = <Widget>[];
    for (var w in tabItems) {
      tabs.add(
        Tab(
          key: key,
          icon: w.icon is IconData ? Icon(w.icon) : w.icon,
          iconMargin: w.iconMargin,
          height: height,
          text: w.title,
        ),
      );
      contentList.add(w.content);
    }

    // Go build the tabbed view based on that data and other configuration
    // items
    return DefaultTabController(
      length: tabItems.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: backgroundColor,
          toolbarHeight: height ?? 50.0,
          bottom: PreferredSize(
            preferredSize: Size.zero,
            child: SizedBox(
              height: height ?? 50.0,
              child: TabBar(
                automaticIndicatorColorAdjustment:
                    automaticIndicatorColorAdjustment,
                dividerColor: style?.dividerColor,
                dividerHeight: style?.dividerHeight,
                indicator: style?.indicator,
                indicatorColor: style?.indicatorColor,
                indicatorSize: style?.indicatorSize,
                indicatorWeight: indicatorWeight,
                labelColor: style?.labelColor,
                labelPadding: style?.labelPadding,
                labelStyle: style?.labelStyle,
                isScrollable: isScrollable,
                onTap: onTap,
                overlayColor: style?.overlayColor,
                padding: EdgeInsets.zero,
                tabAlignment: style?.tabAlignment,
                unselectedLabelColor: style?.unselectedLabelColor,
                unselectedLabelStyle: style?.unselectedLabelStyle,
                tabs: tabs,
              ),
            ),
          ),
        ),
        body: TabBarView(
          clipBehavior: clipBehavior,
          viewportFraction: viewportFraction,
          children: contentList,
        ),
      ),
    );
  }

  /// Provides for a generalized widget to allow for the collection of data
  /// and providing feedback to a user. It exposes the most common text field
  /// options to allow for building custom text fields
  /// (i.e. spin controls, number only, etc.).
  Widget uiTextField({
    Key? key,
    bool autofocus = false,
    bool canRequestFocus = true,
    bool? enabled,
    FocusNode? focusNode,
    List<TextInputFormatter>? inputFormatters,
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
    return style != null
        ? Theme(
            key: key,
            data: ThemeData(inputDecorationTheme: style),
            child: w,
          )
        : w;
  }

  /// Provides the ability to show / hide a widget and setup how to treat
  /// other aspects of the widget.
  Widget uiVisibility({
    required Widget child,
    Key? key,
    bool maintainState = false,
    bool maintainAnimation = false,
    bool maintainSize = false,
    bool maintainSemantics = false,
    bool maintainInteractivity = false,
    bool visible = true,
  }) {
    return Visibility(
      key: key,
      maintainState: maintainState,
      maintainAnimation: maintainAnimation,
      maintainSize: maintainSize,
      maintainSemantics: maintainSemantics,
      maintainInteractivity: maintainInteractivity,
      visible: visible,
      child: child,
    );
  }

  /// Provides the ability to view web content on mobile / web targets.
  Widget uiWebView({
    required String url,
    Key? key,
  }) {
    return platform.createWebView(
      key: key,
      url: url,
    );
  }

  /// Retrieves the available width of the specified context.
  double uiWidth(BuildContext context) => MediaQuery.of(context).size.width;

  // --------------------------------------------------------------------------
  // [API Implementation] -----------------------------------------------------
  // --------------------------------------------------------------------------

  /// Holds the private instance of the [CodeMeltedAPI].
  static CodeMeltedAPI? _instance;

  /// Factory method to access this API.
  factory CodeMeltedAPI() => _instance ?? CodeMeltedAPI._();

  /// Private constructor to ensure only one instance of this.
  CodeMeltedAPI._() {
    _instance = this;
    _initLogger();
  }
}

/// Sets up a namespace object to access the [CodeMeltedAPI].
final codemelted = CodeMeltedAPI();
