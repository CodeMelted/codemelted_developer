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

/// The Flutter web implementation of the CodeMelted - Developer use cases.
library codemelted;

import 'dart:async';
import 'dart:convert';
import 'dart:ui_web';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import "package:web/web.dart" as web;

// ----------------------------------------------------------------------------
// [Data Definition] ----------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// [Async Use Case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

/// The task to run as part of the different module async functions.
typedef CAsyncTask = Future<dynamic> Function([dynamic]);

/// Something Something Star Wars.
/// SEE https://codemelted.com/developer/use_cases/async.html
/// @nodoc
class CAsyncAPI {
  /// Holds the mapping of timer objects of repeating tasks.
  final _data = <int, dynamic>{};

  /// The currently held timer id.
  int _timerId = 0;

  /// @nodoc - need to hook up to codemelted_js
  int get cpuLoad => throw UnimplementedError(
        "Future Implementation",
      );

  /// @nodoc - need to hook up to codemelted_js
  int get hardwareConcurrency => throw UnimplementedError(
        "Future Implementation",
      );

  /// Starts a repeating [CAsyncTask] on the specified interval.
  int startTimer(CAsyncTask task, int interval) {
    assert(interval > 0, "interval specified must be greater than 0.");
    var timer = Timer.periodic(
      Duration(milliseconds: interval),
      (timer) {
        task();
      },
    );
    _timerId += 1;
    _data[_timerId] = timer;
    return _timerId;
  }

  /// Stops the currently running timer.
  void stopTimer(timerId) {
    assert(_data.containsKey(timerId), "timerId was not found.");
    (_data[timerId] as Timer).cancel();
    _data.remove(timerId);
  }

  /// Will allow for a delay in an asynchronous function.
  Future<void> sleep(delay) async {
    return Future.delayed(Duration(milliseconds: delay));
  }

  /// Runs a task and returns any calculated results. Can be scheduled into
  /// the future if necessary.
  Future<dynamic> runTask({
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

  /// TODO: Thread pool stuff.

  /// Gets the single instance of the API.
  static CAsyncAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CAsyncAPI() => _instance ?? CAsyncAPI._();

  /// Sets up the namespace for the [CAsyncAPI] object.
  CAsyncAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Audio Use Case] -----------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CAudioAPI {
  /// Gets the single instance of the API.
  static CAudioAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CAudioAPI() => _instance ?? CAudioAPI._();

  /// Sets up the namespace for the [CAudioAPI] object.
  CAudioAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Console Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

// NOT APPLICABLE TO FLUTTER MODULE.

// ----------------------------------------------------------------------------
// [Database Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CDatabaseAPI {
  /// Gets the single instance of the API.
  static CDatabaseAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CDatabaseAPI() => _instance ?? CDatabaseAPI._();

  /// Sets up the namespace for the [CDatabaseAPI] object.
  CDatabaseAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Firebase Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CFirebaseAPI {
  /// Gets the single instance of the API.
  static CFirebaseAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CFirebaseAPI() => _instance ?? CFirebaseAPI._();

  /// Sets up the namespace for the [CFirebaseAPI] object.
  CFirebaseAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Game Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CGameAPI {
  /// Gets the single instance of the API.
  static CGameAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CGameAPI() => _instance ?? CGameAPI._();

  /// Sets up the namespace for the [CGameAPI] object.
  CGameAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Hardware Use Case] --------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CHardwareAPI {
  /// Gets the single instance of the API.
  static CHardwareAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CHardwareAPI() => _instance ?? CHardwareAPI._();

  /// Sets up the namespace for the [CHardwareAPI] object.
  CHardwareAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [JSON Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Defines an array definition to match JSON Array construct.
typedef CArray = List<dynamic>;

/// Provides helper methods for the CArray.
extension CArrayExtension on CArray {
  /// Builds a map of ChangeNotifier objects to support notification via the
  /// [CArray] definition.
  static final _map = <dynamic, ChangeNotifier?>{};

  /// Adds an event listener so when changes are made via the
  /// [CObjectExtension.set] method.
  void addListener(void Function() listener) {
    if (_map[this] == null) {
      _map[this] = ChangeNotifier();
    }
    _map[this]!.addListener(listener);
  }

  /// Removes an event listener from the [CArray].
  void removeListener(void Function() listener) {
    _map[this]?.removeListener(listener);
  }

  /// Provides a method to set data elements on the [CArray].
  void set<T>(int index, T value, {bool notify = false}) {
    insert(index, value);
    if (notify) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      _map[this]?.notifyListeners();
    }
  }

  /// Provides the ability to extract a data element from the represented
  /// [CArray] at the given index.
  T get<T>(int index) => elementAt(index) as T;

  /// Creates a copy of the array.
  CArray copy() {
    var copy = <dynamic>[];
    copy.addAll(this);
    return copy;
  }

  /// Attempts to parse the serialized string data and turn it into a
  /// [CArray]. Any data previously held by this object is cleared. False is
  /// returned if it could not parse the data.
  bool parse(String data) {
    try {
      clear();
      addAll(jsonDecode(data));
      return true;
    } catch (ex) {
      return false;
    }
  }

  /// Converts the JSON object to a string returning null if it cannot
  String? stringify() => jsonEncode(this);
}

/// Defines an object definition to match a valid JSON Object construct.
typedef CObject = Map<String, dynamic>;

/// Provides helper methods for the [CObject] for set / get data, implementing
/// a [ChangeNotifier], and being able to serialize / deserialize between
/// JSON and string data.
extension CObjectExtension on CObject {
  /// Builds a map of ChangeNotifier objects to support notification via the
  /// [CObject] definition.
  static final _map = <dynamic, ChangeNotifier?>{};

  /// Adds an event listener so when changes are made via the
  /// [CObjectExtension.set] method.
  void addListener(void Function() listener) {
    if (_map[this] == null) {
      _map[this] = ChangeNotifier();
    }
    _map[this]!.addListener(listener);
  }

  /// Removes an event listener from the [CObject].
  void removeListener(void Function() listener) {
    _map[this]?.removeListener(listener);
  }

  /// Attempts to parse the serialized string data and turn it into a
  /// [CObject]. Any data previously held by this object is cleared. False is
  /// returned if it could not parse the data.
  bool parse(String data) {
    try {
      clear();
      addAll(jsonDecode(data));
      return true;
    } catch (ex) {
      return false;
    }
  }

  /// Converts the JSON object to a string returning null if it cannot.
  String? stringify() {
    try {
      return jsonEncode(this);
    } catch (ex) {
      return null;
    }
  }

  /// Provides a method to set data elements on the [CObject].
  void set<T>(String key, T value, {bool notify = false}) {
    this[key] = value;
    if (notify) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      _map[this]?.notifyListeners();
    }
  }

  /// Provides the ability to extract a data element from the represented
  /// [CObject].
  T get<T>(String key) {
    return this[key];
  }
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

/// Defines a set of utility methods for performing data conversions for JSON
/// along with data validation.
class CJsonAPI {
  /// Determines if a [CObject] has a given property contained within.
  bool checkHasProperty(CObject obj, String key) {
    return obj.containsKey(key);
  }

  /// Determines if the variable is of the expected type.
  bool checkType<T>(dynamic data) {
    return data is T;
  }

  /// Determines if the data type is a valid URL.
  bool checkValidUrl(String data) {
    return Uri.tryParse(data) != null;
  }

  /// Will convert data into a JSON [CObject] or return null if the decode
  /// could not be achieved.
  CObject? parse(data) {
    return data.asObject();
  }

  /// Will encode the JSON [CObject] into a string or null if the encode
  /// could not be achieved.
  String? stringify(CObject data) {
    return data.stringify();
  }

  /// Same as [checkHasProperty] but throws an exception if the key
  /// is not found.
  void tryHasProperty(CObject obj, String key) {
    if (!checkHasProperty(obj, key)) {
      throw "obj does not contain specified key";
    }
  }

  /// Same as [checkType] but throws an exception if not of the
  /// expected type.
  void tryType<T>(dynamic data) {
    if (!checkType<T>(data)) {
      throw "variable was not of of an expected type.'";
    }
  }

  /// Same as [checkValidUrl] but throws an exception if not a valid
  /// URL type.
  void tryValidUrl(String data) {
    if (!checkValidUrl(data)) {
      throw "data was not a valid URL string";
    }
  }

  /// Gets the single instance of the API.
  static CJsonAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CJsonAPI() => _instance ?? CJsonAPI._();

  /// Sets up the namespace for the [CJsonAPI] object.
  CJsonAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Logger Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CLoggerAPI {
  /// Gets the single instance of the API.
  static CLoggerAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CLoggerAPI() => _instance ?? CLoggerAPI._();

  /// Sets up the namespace for the [CLoggerAPI] object.
  CLoggerAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Math Use Case] ------------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CMathAPI {
  /// Gets the single instance of the API.
  static CMathAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CMathAPI() => _instance ?? CMathAPI._();

  /// Sets up the namespace for the [CUserAPI] object.
  CMathAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Memory Use Case] ----------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CMemoryAPI {
  /// Gets the single instance of the API.
  static CMemoryAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CMemoryAPI() => _instance ?? CMemoryAPI._();

  /// Sets up the namespace for the [CMemoryAPI] object.
  CMemoryAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Network Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CNetworkAPI {
  /// Gets the single instance of the API.
  static CNetworkAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CNetworkAPI() => _instance ?? CNetworkAPI._();

  /// Sets up the namespace for the [CNetworkAPI] object.
  CNetworkAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Runtime Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/// Optional parameter for the mailto scheme to facilitate translating the more
/// complicated URL.
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
    url += "$mailto;";
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

/// Identifies the scheme to utilize as part of the module open
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

/// Something Something Star Wars.
/// @nodoc
class CRuntimeAPI {
  // TODO: Hook into codemelted.js
  /// Loads a specified resource into a new or existing browsing context
  /// (that is, a tab, a window, or an iframe) under a specified name. These
  /// are based on the different [CSchemeType] supported protocol items.
  Future<web.Window?> open({
    required CSchemeType scheme,
    bool popupWindow = false,
    CMailToParams? mailtoParams,
    String? url,
    String target = "_blank",
    double? width,
    double? height,
  }) async {
    try {
      var urlToLaunch = "";
      if (scheme == CSchemeType.file ||
          scheme == CSchemeType.http ||
          scheme == CSchemeType.https ||
          scheme == CSchemeType.sms ||
          scheme == CSchemeType.tel) {
        urlToLaunch = scheme.getUrl(url!);
      } else {
        urlToLaunch = mailtoParams != null
            ? scheme.getUrl(mailtoParams.toString())
            : scheme.getUrl(url!);
      }

      if (popupWindow) {
        var w = width ?? 900.0;
        var h = height ?? 600.0;
        var top = (web.window.screen.height - h) / 2;
        var left = (web.window.screen.width - w) / 2;
        var settings = "toolbar=no, location=no, "
            "directories=no, status=no, menubar=no, "
            "scrollbars=no, resizable=yes, copyhistory=no, "
            "width=$w, height=$h, top=$top, left=$left";
        return web.window.open(
          urlToLaunch,
          "_blank",
          settings,
        );
      }

      return web.window.open(urlToLaunch, target);
    } catch (ex) {
      // codemelted_logger.error(data: ex, stackTrace: st);
      return null;
    }
  }

  /// Gets the single instance of the API.
  static CRuntimeAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CRuntimeAPI() => _instance ?? CRuntimeAPI._();

  /// Sets up the namespace for the [CRuntimeAPI] object.
  CRuntimeAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Storage Use Case] ---------------------------------------------------------
// ----------------------------------------------------------------------------

/// Something Something Star Wars.
/// @nodoc
class CStorageAPI {
  /// Gets the single instance of the API.
  static CStorageAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CStorageAPI() => _instance ?? CStorageAPI._();

  /// Sets up the namespace for the [CStorageAPI] object.
  CStorageAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [User Interface Use Case] --------------------------------------------------
// ----------------------------------------------------------------------------

/// Sets up a global navigator key for usage with dialogs rendered with the
/// [CUserInterfaceAPI] dlg functions.
final cNavigatorKey = GlobalKey<NavigatorState>();

/// Sets up a global scaffold key for opening drawers and such on the
/// [CUserInterfaceAPI] app functions.
final cScaffoldKey = GlobalKey<ScaffoldState>();

/// Will allow for hooking up to get resize events update to determine if a
/// change to the UI state is necessary for the SPA. Return true if you are
/// handling the resize event, false to propagate the event up the widget
/// tree.
typedef OnResizeEventHandler = bool Function(Size);

/// Provides the Single Page Application for the [CUserInterfaceAPI.app]
/// property that returns the main view.
class CAppView extends StatefulWidget {
  /// Tracks if the [CUserInterfaceAPI.app] has already been called.
  static bool _isInitialized = false;

  /// Sets up the dictionary for usage with the SPA.
  static final uiState = <String, dynamic>{
    "darkTheme": ThemeData.dark(useMaterial3: true),
    "themeMode": ThemeMode.system,
    "theme": ThemeData.light(useMaterial3: true),
  };

  /// Sets / gets the ability to detect resize events with the
  /// [CUserInterfaceAPI.app] to update the main body if necessary.
  static OnResizeEventHandler? get onResizeEvent =>
      uiState.get<OnResizeEventHandler?>("onResizeEvent");
  static set onResizeEvent(OnResizeEventHandler? v) =>
      uiState.set<OnResizeEventHandler?>("onResizeEvent", v);

  /// Sets / gets the dark theme for the [CUserInterfaceAPI.app].
  static ThemeData get darkTheme => uiState.get<ThemeData>("darkTheme");
  static set darkTheme(ThemeData? v) =>
      uiState.set<ThemeData?>("darkTheme", v, notify: true);

  /// Sets / gets the light theme for the [CUserInterfaceAPI.app].
  static ThemeData get theme => uiState.get<ThemeData>("theme");
  static set theme(ThemeData? v) =>
      uiState.set<ThemeData?>("theme", v, notify: true);

  /// Sets / gets the theme mode for the [CUserInterfaceAPI.app].
  static ThemeMode get themeMode => uiState.get<ThemeMode>("themeMode");
  static set themeMode(ThemeMode v) =>
      uiState.set<ThemeMode?>("themeMode", v, notify: true);

  /// Sets / gets the app title for the [CUserInterfaceAPI.app].
  static String? get title => uiState.get<String?>("title");
  static set title(String? v) => uiState.set<String?>("title", v, notify: true);

  /// Sets / removes the header area of the [CUserInterfaceAPI.app].
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

  /// Sets / removes the content area of the [CUserInterfaceAPI.app].
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

  /// Sets / removes the footer area of the [CUserInterfaceAPI.app].
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

  /// Sets / removes a floating action button for the [CUserInterfaceAPI.app].
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

  /// Sets / removes a left sided drawer for the [CUserInterfaceAPI.app].
  static void drawer({Widget? header, List<Widget>? items}) {
    if (header == null && items == null) {
      uiState.set<Widget?>("drawer", null);
    } else {
      uiState.set<Widget?>(
        "drawer",
        PointerInterceptor(
          intercepting: kIsWeb,
          child: Drawer(
            child: ListView(
              children: [
                if (header != null) header,
                if (items != null) ...items,
              ],
            ),
          ),
        ),
        notify: true,
      );
    }
  }

  /// Sets / removes a right sided drawer from the [CUserInterfaceAPI.app].
  static void endDrawer({Widget? header, List<Widget>? items}) {
    if (header == null && items == null) {
      uiState.set<Widget?>("endDrawer", null);
    } else {
      uiState.set<Widget?>(
        "endDrawer",
        PointerInterceptor(
          intercepting: kIsWeb,
          child: Drawer(
            child: ListView(
              children: [
                if (header != null) header,
                if (items != null) ...items,
              ],
            ),
          ),
        ),
        notify: true,
      );
    }
  }

  /// Will programmatically close an open drawer on the [CUserInterfaceAPI.app].
  static void closeDrawer() {
    if (cScaffoldKey.currentState!.isDrawerOpen) {
      cScaffoldKey.currentState!.closeDrawer();
    }
    if (cScaffoldKey.currentState!.isEndDrawerOpen) {
      cScaffoldKey.currentState!.closeEndDrawer();
    }
  }

  /// Will programmatically open a drawer on the [CUserInterfaceAPI.app].
  static void openDrawer({bool isEndDrawer = false}) {
    if (!isEndDrawer && cScaffoldKey.currentState!.hasDrawer) {
      cScaffoldKey.currentState!.openDrawer();
    } else if (cScaffoldKey.currentState!.hasEndDrawer) {
      cScaffoldKey.currentState!.openEndDrawer();
    }
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
      navigatorKey: cNavigatorKey,
      theme: CAppView.theme,
      themeMode: CAppView.themeMode,
      title: CAppView.title ?? "",
      home: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          var handler = CAppView.onResizeEvent;
          if (handler != null) {
            return handler(MediaQuery.of(context).size);
          }
          return false;
        },
        child: Scaffold(
          appBar: CAppView.uiState.get<AppBar?>("appBar"),
          body: SizeChangedLayoutNotifier(
            child: CAppView.uiState.get<CObject?>("content")?['body'],
          ),
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
              .get<FloatingActionButtonLocation?>(
                  "floatingActionButtonLocation"),
          key: cScaffoldKey,
        ),
      ),
    );
  }
}

/// Provides some modifications to the [DialogTheme] to properly configure
/// overall dialog theme.
class CDialogTheme extends DialogTheme {
  /// The title foreground color for the text and close icon.
  final Color? titleColor;

  /// The foreground color of the content color for all dialog types minus
  /// custom dialogs. The developer sets the color of the content for custom
  /// dialog types.
  final Color? contentColor;

  /// The foreground color of the Text buttons for the dialog.
  final Color? actionsColor;

  /// What background color to apply when hovering over the button.
  final Color? actionsOverlayColor;

  /// Constructor to provide new colors for the [DialogTheme]
  const CDialogTheme({
    super.backgroundColor = const Color.fromARGB(255, 2, 48, 32),
    this.titleColor = Colors.amber,
    this.contentColor = Colors.white,
    this.actionsColor = Colors.lightBlueAccent,
    this.actionsOverlayColor = Colors.blue,
  });
}

/// Provides theming of the regular [InputDecorationTheme] but expands to
/// the input style and other attributes of styling. Modeled off the
/// [DropdownMenuTheme] to be consistent with that control.
class CInputDecorationTheme extends InputDecorationTheme {
  /// Adds the items associated with the input field so it is in line with
  /// other material3 widgets. See DropdownMenu as an example.
  final TextStyle? inputStyle;

  /// Identifies how to capitalize text entered into the field.
  final TextCapitalization textCapitalization;

  /// Specifies the text direction.
  final TextDirection? textDirection;

  /// Specifies the alignment of the text within the field.
  final TextAlign textAlign;

  /// Specifies the vertical alignment of the text within the text field.
  final TextAlignVertical? textAlignVertical;

  /// The max number of lines to apply to the text field.
  final int? maxLines;

  /// The minimum number of lines to apply to the text field.
  final int? minLines;

  /// Whether this control expands or not.
  final bool expands;

  /// The maximum number of characters allowed within the widget.
  final int? maxLength;

  /// Scroll padding applied if a multi-line text field is created.
  final EdgeInsets scrollPadding;

  /// Clipping behavior to apply if the text exceeds what can be displayed.
  final Clip clipBehavior;

  /// Sets the maximum lines for the hint field.
  final int? hintMaxLines;

  /// Sets the text direction of the hint text.
  final TextDirection? hintTextDirection;

  @override
  CInputDecorationTheme copyWith({
    // Items added to make it possible to match other theme styles.
    TextStyle? inputStyle,
    TextCapitalization? textCapitalization,
    TextDirection? textDirection,
    TextAlign? textAlign,
    TextAlignVertical? textAlignVertical,
    int? maxLines,
    int? minLines,
    bool? expands,
    int? maxLength,
    EdgeInsets? scrollPadding,
    Clip? clipBehavior,
    int? hintMaxLines,
    TextDirection? hintTextDirection,

    // From the original object
    TextStyle? labelStyle,
    TextStyle? floatingLabelStyle,
    TextStyle? helperStyle,
    int? helperMaxLines,
    TextStyle? hintStyle,
    Duration? hintFadeDuration,
    TextStyle? errorStyle,
    int? errorMaxLines,
    FloatingLabelBehavior? floatingLabelBehavior,
    FloatingLabelAlignment? floatingLabelAlignment,
    bool? isDense,
    EdgeInsetsGeometry? contentPadding,
    bool? isCollapsed,
    Color? iconColor,
    TextStyle? prefixStyle,
    Color? prefixIconColor,
    TextStyle? suffixStyle,
    Color? suffixIconColor,
    TextStyle? counterStyle,
    bool? filled,
    Color? fillColor,
    BorderSide? activeIndicatorBorder,
    BorderSide? outlineBorder,
    Color? focusColor,
    Color? hoverColor,
    InputBorder? errorBorder,
    InputBorder? focusedBorder,
    InputBorder? focusedErrorBorder,
    InputBorder? disabledBorder,
    InputBorder? enabledBorder,
    InputBorder? border,
    bool? alignLabelWithHint,
    BoxConstraints? constraints,
  }) {
    return CInputDecorationTheme(
      inputStyle: inputStyle ?? this.inputStyle,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textAlign: textAlign ?? this.textAlign,
      textAlignVertical: textAlignVertical ?? this.textAlignVertical,
      textDirection: textDirection ?? this.textDirection,
      maxLines: maxLines == null
          ? this.maxLines
          : maxLines == 0
              ? null
              : maxLines,
      minLines: minLines == null
          ? this.minLines
          : minLines == 0
              ? null
              : minLines,
      expands: expands ?? this.expands,
      maxLength: maxLength == null
          ? this.maxLength
          : maxLength == 0
              ? null
              : maxLength,
      scrollPadding: scrollPadding ?? this.scrollPadding,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      hintMaxLines: hintMaxLines ?? this.hintMaxLines,
      hintTextDirection: hintTextDirection ?? this.hintTextDirection,

      // The existing InputDecorationTheme
      labelStyle: labelStyle ?? this.labelStyle,
      floatingLabelStyle: floatingLabelStyle ?? this.floatingLabelStyle,
      helperStyle: helperStyle ?? this.helperStyle,
      helperMaxLines: helperMaxLines ?? this.helperMaxLines,
      hintStyle: hintStyle ?? this.hintStyle,
      hintFadeDuration: hintFadeDuration ?? this.hintFadeDuration,
      errorStyle: errorStyle ?? this.errorStyle,
      errorMaxLines: errorMaxLines ?? this.errorMaxLines,
      floatingLabelBehavior:
          floatingLabelBehavior ?? this.floatingLabelBehavior,
      floatingLabelAlignment:
          floatingLabelAlignment ?? this.floatingLabelAlignment,
      isDense: isDense ?? this.isDense,
      contentPadding: contentPadding ?? this.contentPadding,
      isCollapsed: isCollapsed ?? this.isCollapsed,
      iconColor: iconColor ?? this.iconColor,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      prefixIconColor: prefixIconColor ?? this.prefixIconColor,
      suffixStyle: suffixStyle ?? this.suffixStyle,
      suffixIconColor: suffixIconColor ?? this.suffixIconColor,
      counterStyle: counterStyle ?? this.counterStyle,
      filled: filled ?? this.filled,
      fillColor: fillColor ?? this.fillColor,
      activeIndicatorBorder:
          activeIndicatorBorder ?? this.activeIndicatorBorder,
      outlineBorder: outlineBorder ?? this.outlineBorder,
      focusColor: focusColor ?? this.focusColor,
      hoverColor: hoverColor ?? this.hoverColor,
      errorBorder: errorBorder ?? this.errorBorder,
      focusedBorder: focusedBorder ?? this.focusedBorder,
      focusedErrorBorder: focusedErrorBorder ?? this.focusedErrorBorder,
      disabledBorder: disabledBorder ?? this.errorBorder,
      enabledBorder: enabledBorder ?? this.enabledBorder,
      border: border ?? this.border,
      alignLabelWithHint: alignLabelWithHint ?? this.alignLabelWithHint,
      constraints: constraints ?? this.constraints,
    );
  }

  /// Constructor for the class.
  const CInputDecorationTheme({
    // Styles attached to the InputDecorationTheme.
    this.inputStyle,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.clipBehavior = Clip.hardEdge,
    this.hintMaxLines,
    this.hintTextDirection,

    // The existing InputDecorationTheme
    super.labelStyle,
    super.floatingLabelStyle,
    super.helperStyle,
    super.helperMaxLines,
    super.hintStyle,
    super.hintFadeDuration,
    super.errorStyle,
    super.errorMaxLines,
    super.floatingLabelBehavior = FloatingLabelBehavior.auto,
    super.floatingLabelAlignment = FloatingLabelAlignment.start,
    super.isDense = false,
    super.contentPadding,
    super.isCollapsed = false,
    super.iconColor,
    super.prefixStyle,
    super.prefixIconColor,
    super.suffixStyle,
    super.suffixIconColor,
    super.counterStyle,
    super.filled = false,
    super.fillColor,
    super.activeIndicatorBorder,
    super.outlineBorder,
    super.focusColor,
    super.hoverColor,
    super.errorBorder,
    super.focusedBorder,
    super.focusedErrorBorder,
    super.disabledBorder,
    super.enabledBorder,
    super.border,
    super.alignLabelWithHint = false,
    super.constraints,
  });
}

/// Provides a wrapper around the Flutter ThemeData object that isolates
/// the application theming to the material3 constructs of Flutter. Extended
/// existing ThemeData objects utilized to provide a similar theming experience.
/// The theme is created via the [CUserInterfaceAPI.themeCreate] method.
extension ThemeDataExtension on ThemeData {
  /// Extracts the [DialogTheme] as an [CDialogTheme] object.
  CDialogTheme get cDialogTheme => dialogTheme as CDialogTheme;

  /// Gets access to the specialized input decoration theme to pick up styles
  /// for all items that may utilize it.
  CInputDecorationTheme get cInputDecorationTheme =>
      inputDecorationTheme as CInputDecorationTheme;
}

/// Supports identifying the module uiButton widget constructed.
enum CButtonType { elevated, filled, icon, outlined, text }

/// Supports identifying what module uiImage is constructed when utilized.
enum CImageType { asset, file, memory, network }

/// Enumerations set specifying the allowed actions within the embedded web
/// view when the compile target is web.
enum CSandboxAllow {
  forms("allow-forms"),
  modals("allow-modals"),
  orientationLock("allow-orientation-lock"),
  pointerLock("allow-pointer-lock"),
  popups("allow-popups"),
  popupsToEscapeSandbox("allow-popups-to-escape-sandbox"),
  presentation("allow-presentation"),
  sameOrigin("allow-same-origin"),
  scripts("allow-scripts"),
  topNavigation("allow-top-navigation"),
  topNavigationByUserActivation("allow-top-navigation-by-user-activation");

  final String sandbox;

  const CSandboxAllow(this.sandbox);
}

/// Defines a tab item to utilize with the module uiTabView method.
class CTabItem {
  /// The content displayed with the tab.
  final Widget? content;

  /// An icon for the tab within the tab view.
  final dynamic icon;

  /// A title with the tab within the tab view.
  final String? title;

  CTabItem({
    this.content,
    this.icon,
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

/// TODO: Add comments
class CTabbedView extends StatefulWidget {
  final List<CTabItem> tabItems;
  final bool automaticIndicatorColorAdjustment;
  final Color? backgroundColor;
  final Clip clipBehavior;
  final double? height;
  final EdgeInsetsGeometry? iconMargin;
  final double indicatorWeight;
  final bool isScrollable;
  final void Function(int)? onTap;
  final TabBarTheme? style;
  final double viewportFraction;
  final void Function(TabController)? onTabControllerCreated;

  const CTabbedView({
    super.key,
    required this.tabItems,
    this.automaticIndicatorColorAdjustment = true,
    this.backgroundColor,
    this.clipBehavior = Clip.hardEdge,
    this.height,
    this.iconMargin,
    this.indicatorWeight = 2.0,
    this.isScrollable = false,
    this.onTap,
    this.style,
    this.viewportFraction = 1.0,
    this.onTabControllerCreated,
  });

  @override
  State<StatefulWidget> createState() => _CTabViewState();
}

class _CTabViewState extends State<CTabbedView> with TickerProviderStateMixin {
  // Member Fields:
  late TabController _controller;

  @override
  void initState() {
    _controller = TabController(length: widget.tabItems.length, vsync: this);
    _controller.addListener(() {
      if (_controller.indexIsChanging) {
        var index = _controller.index;
        if (widget.tabItems[index].content == null) {
          widget.onTap?.call(_controller.index);
          _controller.index = _controller.previousIndex;
        }
      }
    });
    widget.onTabControllerCreated?.call(_controller);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Parse the tabItems to construct the tab data.
    var tabs = <Widget>[];
    var contentList = <Widget>[];
    for (var w in widget.tabItems) {
      tabs.add(
        Tab(
          key: widget.key,
          icon: w.icon is IconData ? Icon(w.icon) : w.icon,
          iconMargin: widget.iconMargin,
          height: widget.height,
          text: w.title,
        ),
      );
      contentList.add(w.content ?? const SizedBox.shrink());
    }

    // Go build the tabbed view based on that data and other configuration
    // items
    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.backgroundColor,
        toolbarHeight: widget.height ?? 50.0,
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: SizedBox(
            height: widget.height ?? 50.0,
            child: TabBar(
              controller: _controller,
              automaticIndicatorColorAdjustment:
                  widget.automaticIndicatorColorAdjustment,
              dividerColor: widget.style?.dividerColor,
              dividerHeight: widget.style?.dividerHeight,
              indicator: widget.style?.indicator,
              indicatorColor: widget.style?.indicatorColor,
              indicatorSize: widget.style?.indicatorSize,
              indicatorWeight: widget.indicatorWeight,
              labelColor: widget.style?.labelColor,
              labelPadding: widget.style?.labelPadding,
              labelStyle: widget.style?.labelStyle,
              isScrollable: widget.isScrollable,
              overlayColor: widget.style?.overlayColor,
              padding: EdgeInsets.zero,
              tabAlignment: widget.style?.tabAlignment,
              unselectedLabelColor: widget.style?.unselectedLabelColor,
              unselectedLabelStyle: widget.style?.unselectedLabelStyle,
              tabs: tabs,
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _controller,
        clipBehavior: widget.clipBehavior,
        viewportFraction: widget.viewportFraction,
        children: contentList,
      ),
    );
  }
}

/// The web view controller to support the [CUserInterfaceAPI.uiWebView] widget
/// creation.
class CWebViewController {
  /// Handles the changing of the URL within the web view.
  late web.HTMLIFrameElement _iFrameRef;

  /// The URL currently loaded in the embedded view widget.
  late String _url;

  /// Sets / gets the currently loaded URL in the embedded web view.
  String get url => _url;
  set url(String v) {
    _url = v;
    _iFrameRef.src = v;
  }

  /// The policy defines what features are available to the
  /// webview element (for example, access to the microphone, camera, battery,
  /// web-share, etc.) based on the origin of the request.
  final String allow;

  /// Whether to allow the embedded web view to request full screen access.
  final bool allowFullScreen;

  /// The set of [CSandboxAllow] permissions for the web view.
  final List<CSandboxAllow> sandbox;

  /// Constructor for the object.
  CWebViewController({
    required String initialUrl,
    this.allow = "",
    this.allowFullScreen = true,
    this.sandbox = const [],
  }) {
    _url = initialUrl;
  }
}

/// Provides a set of utility methods to build a Graphical User Interface (GUI)
/// for a Single Page Application (SPA). This design paradigm does not preclude
/// you from utilize Flutter's vast array of widgets. It simple provides the
/// SPA construct, dialog utility, and a wrapper for the most common of
/// widgets. Theming is also provides to allow for creating different themes
/// for your SPA.
class CUserInterfaceAPI {
  // TODO: Eventually hook this up to codemelted.js.
  /// Determines if the web app is an installed PWA or not.
  bool get isPWA {
    var queries = [
      '(display-mode: fullscreen)',
      '(display-mode: standalone)',
      '(display-mode: minimal-ui),'
    ];
    var pwaDetected = false;
    for (var query in queries) {
      pwaDetected = pwaDetected || web.window.matchMedia(query).matches;
    }
    return pwaDetected;
  }

  /// Accesses a Single Page Application (SPA) for the overall module. This
  /// is called after being configured via the appXXX functions in the runApp
  /// of the main().
  Widget get app {
    return CAppView();
  }

  /// Sets the [CUserInterfaceAPI.app] dark theme.
  set appDarkTheme(ThemeData? v) {
    CAppView.darkTheme = v;
  }

  /// Sets the [CUserInterfaceAPI.app] light theme.
  set appTheme(ThemeData? v) {
    CAppView.theme = v;
  }

  /// Sets the [CUserInterfaceAPI.app] theme mode.
  set appThemeMode(ThemeMode v) {
    CAppView.themeMode = v;
  }

  /// Sets / removes the [CUserInterfaceAPI.app] title.
  set appTitle(String? v) {
    CAppView.title = v;
  }

  String? get appTitle {
    return CAppView.title;
  }

  /// Sets up the ability to detect resize events with the SPA.
  set appOnResizeEvent(OnResizeEventHandler? v) {
    CAppView.onResizeEvent = v;
  }

  /// Sets / removes the [CUserInterfaceAPI.app] header area.
  void appHeader({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    CAppView.header(
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      forceMaterialTransparency: forceMaterialTransparency,
      leading: leading,
      style: style,
      title: title,
    );
  }

  /// Sets / removes the [CUserInterfaceAPI.app] content area.
  void appContent({
    required Widget? body,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
  }) {
    CAppView.content(
      body: body,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  /// Sets / removes the [CUserInterfaceAPI.app] footer area.
  void appFooter({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    CAppView.footer(
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      forceMaterialTransparency: forceMaterialTransparency,
      leading: leading,
      style: style,
      title: title,
    );
  }

  /// Sets / removes the [CUserInterfaceAPI.app] floating action button.
  void appFloatingActionButton({
    Widget? button,
    FloatingActionButtonLocation? location,
  }) {
    CAppView.floatingActionButton(button: button, location: location);
  }

  /// Sets / removes the [CUserInterfaceAPI.app] drawer.
  void appDrawer({Widget? header, List<Widget>? items}) {
    CAppView.drawer(header: header, items: items);
  }

  /// Sets / removes the [CUserInterfaceAPI.app] end drawer.
  void appEndDrawer({Widget? header, List<Widget>? items}) {
    CAppView.endDrawer(header: header, items: items);
  }

  /// Closes the [CUserInterfaceAPI.app] drawer or end drawer.
  void appCloseDrawer() {
    CAppView.closeDrawer();
  }

  /// Opens the [CUserInterfaceAPI.app] drawer or end drawer.
  void appOpenDrawer({bool isEndDrawer = false}) {
    CAppView.openDrawer(isEndDrawer: isEndDrawer);
  }

  /// Provides the ability to get items from the global app state.
  T getAppState<T>({required String key}) {
    return CAppView.uiState.get<T>(key);
  }

  /// Provides the ability to set items on the global app state.
  void setAppState<T>({required String key, required T value}) {
    CAppView.uiState.set<T>(key, value);
  }

  /// Helper action to build text buttons for our basic dialogs.
  Widget _buildButton<T>(String title, [T? answer]) {
    return uiButton(
      type: CButtonType.text,
      title: title,
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(
          _getTheme().actionsColor,
        ),
      ),
      onPressed: () => dlgClose<T>(answer),
    );
  }

  /// Helper method to get the currently active dialog theme.
  CDialogTheme _getTheme() {
    return Theme.of(cScaffoldKey.currentContext!).cDialogTheme;
  }

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
    double? height,
    String? title,
    double? width,
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

  // TODO: Fix when we have codemelted.js hookup for backend module support.
  // /// Shows a browser popup window when running within a mobile or web target
  // /// environment.
  // Future<void> dlgBrowser({
  //   required String url,
  //   double? height,
  //   String? title,
  //   bool useNativeBrowser = false,
  //   double? width,
  // }) async {
  //   // Now figure what browser window action we are taking
  //   if (useNativeBrowser) {
  //     codemelted_runtime.open(
  //       scheme: CSchemeType.https,
  //       popupWindow: true,
  //       url: url,
  //       height: height,
  //       width: width,
  //     );
  //     return;
  //   }

  //   // We are rendering an inline web view.
  //   return dlgCustom(
  //     actions: [
  //       _buildButton<void>("OK"),
  //     ],
  //     content: uiWebView(controller: CWebViewController(initialUrl: url)),
  //     title: title ?? "Browser",
  //     height: height,
  //     width: width,
  //   );
  // }

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
  }

  /// Provides a Yes/No confirmation dialog with the displayed message as the
  /// question. True is returned for Yes and False for a No or cancel.
  Future<bool> dlgConfirm({
    required String message,
    double? height,
    String? title,
    double? width,
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
  /// [CUserInterfaceAPI.dlgClose] for returning values via your actions array.
  Future<T?> dlgCustom<T>({
    required Widget content,
    required String title,
    List<Widget>? actions,
    double? height,
    double? width,
  }) async {
    return showDialog<T>(
      barrierDismissible: false,
      context: cNavigatorKey.currentContext!,
      builder: (_) => AlertDialog(
        backgroundColor: _getTheme().backgroundColor,
        insetPadding: EdgeInsets.zero,
        scrollable: true,
        titlePadding: const EdgeInsets.all(5.0),
        title: Center(child: Text(title)),
        titleTextStyle: TextStyle(
          color: _getTheme().titleColor,
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
        contentPadding: const EdgeInsets.only(
          left: 25.0,
          right: 25.0,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              width: width,
              child: content,
            )
          ],
        ),
        actionsPadding: const EdgeInsets.all(5.0),
        actionsAlignment: MainAxisAlignment.center,
        actions: actions,
      ),
    );
  }

  /// Provides the ability to run an async task and present a wait dialog. It
  /// is important you call [CUserInterfaceAPI.dlgClose] to properly clear the
  /// dialog and return any value expected.
  Future<T?> dlgLoading<T>({
    required String message,
    required Future<void> Function() task,
    double? height,
    String? title,
    double? width,
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
    var answer = '';
    await dlgCustom<String?>(
      actions: [
        _buildButton<void>("OK"),
      ],
      content: SizedBox(
        height: 30.0,
        width: 200.0,
        child: uiTextField(
          onChanged: (v) => answer = v,
          style: CInputDecorationTheme(
            inputStyle: TextStyle(color: _getTheme().contentColor),
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
        ),
      ),
      title: title,
    );
    return answer;
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
    Brightness? brightness,
    ButtonThemeData? buttonTheme,
    CardTheme? cardTheme,
    CheckboxThemeData? checkboxTheme,
    ChipThemeData? chipTheme,
    ColorScheme? colorScheme,
    DataTableThemeData? dataTableTheme,
    DatePickerThemeData? datePickerTheme,
    DividerThemeData? dividerTheme,
    DialogTheme? dialogTheme,
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
    SnackBarThemeData? snackBarTheme,
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
      brightness: brightness,
      buttonTheme: buttonTheme,
      cardTheme: cardTheme,
      checkboxTheme: checkboxTheme,
      chipTheme: chipTheme,
      colorScheme: colorScheme,
      dataTableTheme: dataTableTheme,
      datePickerTheme: datePickerTheme,
      dialogTheme: dialogTheme ?? const CDialogTheme(),
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
      snackBarTheme: snackBarTheme,
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
    );
  }

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
      leading: leading is IconData ? Icon(leading) : leading,
      initiallyExpanded: initiallyExpanded,
      title: title,
      subtitle: subtitle,
      trailing: trailing is IconData ? Icon(trailing) : trailing,
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
  Widget uiGridView({
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
  double uiHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

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
  }) {
    return Text(
      data,
      key: key,
      maxLines: maxLines,
      softWrap: softWrap,
      style: style,
    );
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
  Widget uiTabbedView({
    required List<CTabItem> tabItems,
    Key? key,
    bool automaticIndicatorColorAdjustment = true,
    Color? backgroundColor,
    Clip clipBehavior = Clip.hardEdge,
    double? height,
    EdgeInsetsGeometry? iconMargin,
    double indicatorWeight = 2.0,
    bool isScrollable = false,
    void Function(int)? onTap,
    TabBarTheme? style,
    double viewportFraction = 1.0,
    void Function(TabController)? onTabControllerCreated,
  }) {
    return CTabbedView(
      tabItems: tabItems,
      key: key,
      automaticIndicatorColorAdjustment: automaticIndicatorColorAdjustment,
      backgroundColor: backgroundColor,
      clipBehavior: clipBehavior,
      height: height,
      iconMargin: iconMargin,
      indicatorWeight: indicatorWeight,
      isScrollable: isScrollable,
      onTabControllerCreated: onTabControllerCreated,
      onTap: onTap,
      style: style,
      viewportFraction: viewportFraction,
    );
  }

  /// Provides for a generalized widget to allow for the collection of data
  /// and providing feedback to a user. It exposes the most common text field
  /// options to allow for building custom text fields
  /// (i.e. spin controls, number only, etc.).
  Widget uiTextField({
    bool autocorrect = true,
    bool enableSuggestions = true,
    TextEditingController? controller,
    String? initialValue,
    bool enabled = true,
    bool readOnly = false,
    bool obscureText = false,
    String obscuringCharacter = '•',
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
    void Function()? onEditingComplete,
    void Function(String)? onFieldSubmitted,
    void Function(String?)? onSaved,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    String? errorText,
    String? helperText,
    String? hintText,
    String? labelText,
    Widget? leadingWidget,
    Widget? trailingWidget,
    CInputDecorationTheme? style,
    Key? key,
  }) {
    return TextFormField(
      // Setup the items that control how the widget will behave.
      autocorrect: autocorrect,
      controller: controller,
      enabled: enabled,
      enableSuggestions: enableSuggestions,
      readOnly: readOnly,
      initialValue: initialValue,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      obscureText: obscureText,
      obscuringCharacter: obscuringCharacter,
      onChanged: onChanged,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      smartDashesType: SmartDashesType.disabled,
      smartQuotesType: SmartQuotesType.disabled,
      textInputAction: textInputAction,
      validator: validator,

      // Style items for overall input field along with setting labels.
      decoration: InputDecoration(
        prefixIconColor: style?.prefixIconColor,
        prefixStyle: style?.prefixStyle,
        prefix: leadingWidget,
        suffix: trailingWidget,
        suffixIconColor: style?.suffixIconColor,
        suffixStyle: style?.suffixStyle,
        labelText: labelText,
        labelStyle: style?.labelStyle,
        floatingLabelAlignment: style?.floatingLabelAlignment,
        floatingLabelBehavior: style?.floatingLabelBehavior,
        floatingLabelStyle: style?.floatingLabelStyle,
        helperText: helperText,
        helperStyle: style?.helperStyle,
        helperMaxLines: style?.helperMaxLines,
        hintText: hintText,
        hintStyle: style?.hintStyle,
        hintMaxLines: style?.hintMaxLines,
        hintTextDirection: style?.hintTextDirection,
        hintFadeDuration: style?.hintFadeDuration,
        alignLabelWithHint: style?.alignLabelWithHint,
        errorText: errorText,
        errorStyle: style?.errorStyle,
        errorMaxLines: style?.errorMaxLines,
        errorBorder: style?.errorBorder,
        focusedErrorBorder: style?.focusedErrorBorder,
        focusedBorder: style?.focusedBorder,
        fillColor: style?.fillColor,
        filled: style?.filled,
      ),
      style: style?.inputStyle,
      textCapitalization: style?.textCapitalization ?? TextCapitalization.none,
      textDirection: style?.textDirection,
      textAlign: style?.textAlign ?? TextAlign.start,
      textAlignVertical: style?.textAlignVertical,
      maxLines: style?.maxLines,
      maxLength: style?.maxLength,
      minLines: style?.minLines,
      expands: style?.expands ?? false,
      scrollPadding: style?.scrollPadding ?? const EdgeInsets.all(20.0),
      clipBehavior: style?.clipBehavior ?? Clip.hardEdge,
    );
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

  /// Provides an embedded web view via an iFrame to load other HTML documents.
  Widget uiWebView({required CWebViewController controller}) {
    // Create the IFrame.
    var iFrameElement = web.HTMLIFrameElement();
    iFrameElement.style.height = "100%";
    iFrameElement.style.width = "100%";
    iFrameElement.style.border = 'none';

    // Configure based on the controller configuration.
    iFrameElement.allow = controller.allow;
    iFrameElement.allowFullscreen = controller.allowFullScreen;
    for (var sandbox in controller.sandbox) {
      iFrameElement.sandbox.add(sandbox.sandbox);
    }
    iFrameElement.src = controller.url;

    // Register it and return it.
    var viewType = UniqueKey();
    platformViewRegistry.registerViewFactory(
      viewType.toString(),
      (int viewId) => iFrameElement,
    );
    controller._iFrameRef = iFrameElement;
    return HtmlElementView(
      viewType: viewType.toString(),
    );
  }

  /// Retrieves the available width of the specified context.
  double uiWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Gets the single instance of the API.
  static CUserInterfaceAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CUserInterfaceAPI() => _instance ?? CUserInterfaceAPI._();

  /// Sets up the namespace for the [CUserInterfaceAPI] object.
  CUserInterfaceAPI._() {
    _instance = this;
  }
}

// ----------------------------------------------------------------------------
// [Public API] ---------------------------------------------------------------
// ----------------------------------------------------------------------------

/// This module is the implementation of the CodeMelted - Developer use cases.
/// It targets the web runtime to allow for building powerful Progressive Web
/// Applications. This module is a mix of utilizing Flutter's powerful UI
/// toolkit with support from the CodeMelted - JS Module project for the more
/// JavaScript features. See that project for examples.
class CodeMeltedAPI {
  /// Accesses the json defined namespace.
  CJsonAPI get json => CJsonAPI();

  CRuntimeAPI get runtime => CRuntimeAPI();

  /// Accesses the ui defined namespace.
  CUserInterfaceAPI get ui => CUserInterfaceAPI();

  /// Gets the single instance of the API.
  static CodeMeltedAPI? _instance;

  /// Sets up the internal instance for this object.
  factory CodeMeltedAPI() => _instance ?? CodeMeltedAPI._();

  /// Sets up the namespace for the [CodeMeltedAPI] object.
  CodeMeltedAPI._() {
    _instance = this;
  }
}

/// Connects to the [CodeMeltedAPI] factory object to form the
/// global [codemelted] namespace.
final codemelted = CodeMeltedAPI();
