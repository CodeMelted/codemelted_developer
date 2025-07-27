// ignore_for_file: constant_identifier_names, camel_case_types

/*
===============================================================================
MIT License

© 2025 Mark Shaffer. All Rights Reserved.

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

/// The `codemelted.dart` module provides the power of Flutter to build Single
/// Page Applications (SPA) with an easy setup to install the SPA as a
/// Progressive Web App (PWA). This module only targets the Flutter web
/// implementing Flutter specific code to take full advantage of the widget
/// toolkit and Flutter native code that can be utilized within the web. The
/// remaining use case functionality will take advantage of Flutter's bindings
/// with the JavaScript browser APIs.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:ui_web';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import "package:web/web.dart" as web;

// ============================================================================
// [MODULE REQUEST DEFINITIONS] ===============================================
// ============================================================================

/// Identifies the [CodeMeltedAPI.ui_dialog] function supported dialog types.
enum DIALOG_REQUEST {
  /// Displays an about dialog for the constructed [CUiAppView]
  About,

  /// Displays a snack bar to alert the user of a condition.
  Alert,

  /// Opens a full page browser iFrame.
  Browser,

  /// Provides a half page selection of options.
  Choose,

  /// Will asynchronously close an open dialog.
  Close,

  /// Provides a confirmation Yes / No question to the user.
  Confirm,

  /// Provides a full page custom dialog to the [CUiAppView].
  Custom,

  /// Provides a loading half-page dialog closed via a [DIALOG_REQUEST.close].
  Loading,

  /// Provides a single text field prompt input box.
  Prompt;
}

/// Provides queryable parameters of the browser runtime environment.
enum IS_REQUEST {
  /// Determines if the browser window represents an installed Progressive
  /// Web Application.
  PWA,
  /// Indicates whether the current context is secure (true) or not (false).
  SecureContext,
  /// Identifies if the browser is accessible via a touch device.
  TouchEnabled,
}

/// Mapping of `codemelted.js` module formulas to support the
/// [CodeMeltedAPI.npu_math] call.
enum MATH_FORMULA {
  /// °F = (°C x 9/5) + 32
  TemperatureCelsiusToFahrenheit;
}

/// Identifies the different schemas a browser may be able to handle. This
/// supports the [CodeMeltedAPI.ui_open] function.
enum SCHEMA {
  /// Opens an app that can handle the identified file.
  File("file:"),
  /// Opens a browser window in a non-secure context.
  Http("http://"),
  /// Opens a browser window in a secure context.
  Https("https://"),
  /// Opens an app associated with email.
  Mailto("mailto:"),
  /// Opens an app associated with handling SMS text messages.
  SMS("sms:"),
  /// Opens an app associated with handling telephone calls.
  Tel("tel:");

  /// Holds the binding schema for the `codemelted.js` module to process.
  final String schema;

  /// Constructor for the enumeration.
  const SCHEMA(this.schema);
}

/// Specifies where to open the linked document. This supports the
/// [CodeMeltedAPI.ui_open] function.
enum TARGET {
  /// Opens the linked document in a new window or tab.
  Blank("_blank"),
  /// Opens the linked document in the same frame as it was clicked
  /// (this is default).
  Self("_self"),
  /// Opens the linked document in the parent frame.
  Parent("_parent"),
  /// Opens the linked document in the full body of the window
  Top("_top");

  /// Holds the [TARGET] enumerated value translation.
  final String target;

  /// Constructor for the enumeration.
  const TARGET(this.target);
}

// ============================================================================
// [MODULE DATA DEFINITION] ===================================================
// ============================================================================

/// Defines an array definition to match JSON Array construct.
typedef CArray = List<dynamic>;

/// Provides helper methods for the CArray.
extension CArrayExtension on CArray {
  /// Builds a map of ChangeNotifier objects to support notification via the
  /// [CArray] definition.
  static final _map = <dynamic, ChangeNotifier?>{};

  /// Adds an event listener so when changes are made via the
  /// [CObjectExtension.set] method.
  void addListener({required void Function() listener}) {
    if (_map[this] == null) {
      _map[this] = ChangeNotifier();
    }
    _map[this]!.addListener(listener);
  }

  /// Triggers the listener.
  void notifyAll() {
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    _map[this]?.notifyListeners();
  }

  /// Removes an event listener from the [CArray].
  void removeListener({required void Function() listener}) {
    _map[this]?.removeListener(listener);
  }

  /// Creates a copy of the array. This does not copy the listeners.
  CArray copy() {
    var copy = <dynamic>[];
    copy.addAll(this);
    return copy;
  }

  /// Attempts to parse the serialized string data and turn it into a
  /// [CArray]. Any data previously held by this object is cleared. False is
  /// returned if it could not parse the data.
  bool parse({required String data}) {
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

/// Provides a general event handler for the
/// [CodeMeltedAPI.runtime_event] attachment.
typedef CEventHandler = void Function(web.Event);

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
  void addListener({required void Function() listener}) {
    if (_map[this] == null) {
      _map[this] = ChangeNotifier();
    }
    _map[this]!.addListener(listener);
  }

  /// Triggers the listener to a data change.
  void notifyAll() {
    // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
    _map[this]?.notifyListeners();
  }

  /// Removes an event listener from the [CObject].
  void removeListener({required void Function() listener}) {
    _map[this]?.removeListener(listener);
  }

  /// Creates a copy of the object. This does not get the listeners.
  CObject copy() {
    return Map.from(this);
  }

  /// Attempts to parse the serialized string data and turn it into a
  /// [CObject]. Any data previously held by this object is cleared. False is
  /// returned if it could not parse the data.
  bool parse({required String initData}) {
    try {
      clear();
      addAll(jsonDecode(initData));
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
  void set<T>({required String key, required T value, bool notify = false}) {
    this[key] = value;
    if (notify) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      _map[this]?.notifyListeners();
    }
  }

  /// Provides the ability to extract a data element from the represented
  /// [CObject].
  T get<T>({required String key}) {
    return this[key] as T;
  }
}

/// Support object for any object to provide a result where either the value
/// or the error can be signaled for later checking by a user.
class CResult<T> {
  /// Hold the value of the given result or nothing if the [CResult] is being
  /// used to signal there was no error.
  final T? value;

  /// The error encountered that requires an action by the user.
  final String? error;

  /// Stack trace associated with the handled error.
  final StackTrace? st;

  /// Signals the transaction completed with no errors.
  bool get is_ok => error == null;

  /// Signals whether an error was captured or not.
  bool get is_error => error != null && error!.isNotEmpty;

  /// Constructor for the object.
  CResult({
    this.value,
    this.error,
    this.st,
  }) {
    assert(
      ((value != null && error == null) ||
       (value == null && error != null) ||
       (value == null && error == null)),
      "SyntaxError: Only value or error can be set. Not both!",
    );
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
    List<String> truthyStrings = [
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
    return truthyStrings.contains(toLowerCase());
  }

  /// Will attempt to return a double from the string value or null if it
  /// cannot.
  double? asDouble() => double.tryParse(this);

  /// Will attempt to return a int from the string value or null if it cannot.
  int? asInt() => int.tryParse(this);

  /// Will attempt to return CObject object or null if it cannot.
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

/// The task to run as part of the [CodeMeltedAPI.async_task] call.
typedef CTaskCB<T> = Future<T> Function([dynamic]);

/// The task to run as part of the [CodeMeltedAPI.async_timer] call.
typedef CTimerCB = void Function();

/// The result object from the [CodeMeltedAPI.async_timer] call to allow for
/// stopping the running timer in the future.
class CTimerResult {
  /// Holds the constructed flutter timer.
  late Timer _timer;

  /// Determines if the timer is still running or not.
  bool get isRunning => _timer.isActive;

  /// Stops the held running timer.
  void stop() {
    _timer.cancel();
  }

  /// Constructor for the class.
  CTimerResult(Timer timer) {
    _timer = timer;
  }
}

/// Identifies the ability to open a close [CUiAppDrawerConfig] configured
/// widgets.
enum CUiAppDrawerAction {
  /// Opens the widget.
  open,

  /// Closes the widget.
  close;
}

/// Will allow for hooking up to get resize events update to determine if a
/// change to the UI state is necessary for the SPA. Return true if you are
/// handling the resize event, false to propagate the event up the widget
/// tree.
typedef CUiAppViewResizeEventHandler = bool Function(Size);

/// Provides the Single Page Application for the [CodeMeltedAPI.ui_app_run]
/// function. This is built via the [CodeMeltedAPI.ui_app_config] function
/// call which makes use of the [CUiAppViewConfig] objects to setup the SPA.
///
/// **NOTE: It is recommended to not use this class directly and to use the
/// function.**
class CUiAppView extends StatefulWidget {
  /// Tracks if the app has already been called.
  static bool _isInitialized = false;

  /// Sets up the dictionary for usage with the SPA.
  static final uiState = <String, dynamic>{
    "darkTheme": ThemeData.dark(useMaterial3: true),
    "themeMode": ThemeMode.system,
    "theme": ThemeData.light(useMaterial3: true),
  };

  /// Sets / gets the ability to detect resize events with the
  /// [CUiAppView] to update the main body if necessary.
  static CUiAppViewResizeEventHandler? get onResizeEvent =>
      uiState.get<CUiAppViewResizeEventHandler?>(key: "onResizeEvent");
  static set onResizeEvent(CUiAppViewResizeEventHandler? v) =>
      uiState.set<CUiAppViewResizeEventHandler?>(key: "onResizeEvent", value: v);

  /// Sets / gets the dark theme for the [CUiAppView].
  static ThemeData get darkTheme => uiState.get<ThemeData>(key: "darkTheme");
  static set darkTheme(ThemeData v) =>
      uiState.set<ThemeData?>(key: "darkTheme", value: v, notify: true);

  /// Sets / gets the light theme for the [CUiAppView].
  static ThemeData get theme => uiState.get<ThemeData>(key: "theme");
  static set theme(ThemeData v) =>
      uiState.set<ThemeData>(key: "theme", value: v, notify: true);

  /// Sets / gets the theme mode for the [CUiAppView].
  static ThemeMode get themeMode => uiState.get<ThemeMode>(key: "themeMode");
  static set themeMode(ThemeMode v) =>
      uiState.set<ThemeMode>(key: "themeMode", value: v, notify: true);

  /// Sets / gets the app title for the [CUiAppView].
  static String? get title => uiState.get<String?>(key: "title");
  static set title(String? v) =>
      uiState.set<String?>(key: "title", value: v, notify: true);

  /// Sets / removes the header area of the [CUiAppView].
  static void header({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    if (actions == null && leading == null && title == null) {
      uiState.set<AppBar?>(key: "appBar", value: null);
    } else {
      uiState.set<AppBar?>(
        key: "appBar",
        value: AppBar(
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

  /// Sets / removes the content area of the [CUiAppView].
  static void content({
    required Widget? body,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
  }) {
    uiState.set<CObject>(
      key: "content",
      value: {
        "body": body,
        "extendBody": extendBody,
        "extendBodyBehindAppBar": extendBodyBehindAppBar,
      },
      notify: true,
    );
  }

  /// Sets / removes the footer area of the [CUiAppView].
  static void footer({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    if (actions == null && leading == null && title == null) {
      uiState.set<BottomAppBar?>(key: "bottomAppBar", value: null);
    } else {
      uiState.set<BottomAppBar?>(
        key: "bottomAppBar",
        value: BottomAppBar(
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

  /// Sets / removes a floating action button for the [CUiAppView].
  static void floatingActionButton({
    Widget? button,
    FloatingActionButtonLocation? location,
  }) {
    uiState.set<Widget?>(
      key: "floatingActionButton",
      value: button != null
          ? PointerInterceptor(
              intercepting: kIsWeb,
              child: button,
            )
          : null,
    );
    uiState.set<FloatingActionButtonLocation?>(
      key: "floatingActionButtonLocation",
      value: location,
      notify: true,
    );
  }

  /// Sets / removes a left sided drawer for the [CUiAppView].
  static void drawer({Widget? header, List<Widget>? items}) {
    if (header == null && items == null) {
      uiState.set<Widget?>(key: "drawer", value: null);
    } else {
      uiState.set<Widget?>(
        key: "drawer",
        value: PointerInterceptor(
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

  /// Sets / removes a right sided drawer from the [CUiAppView].
  static void endDrawer({Widget? header, List<Widget>? items}) {
    if (header == null && items == null) {
      uiState.set<Widget?>(key: "endDrawer", value: null);
    } else {
      uiState.set<Widget?>(
        key: "endDrawer",
        value: PointerInterceptor(
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

  /// Will programmatically close an open drawer on the [CUiAppView].
  static void closeDrawer() {
    if (CodeMeltedAPI.uiScaffoldKey.currentState!.isDrawerOpen) {
      CodeMeltedAPI.uiScaffoldKey.currentState!.closeDrawer();
    }
    if (CodeMeltedAPI.uiScaffoldKey.currentState!.isEndDrawerOpen) {
      CodeMeltedAPI.uiScaffoldKey.currentState!.closeEndDrawer();
    }
  }

  /// Will programmatically open a drawer on the [CUiAppView].
  static void openDrawer({bool isEndDrawer = false}) {
    if (!isEndDrawer && CodeMeltedAPI.uiScaffoldKey.currentState!.hasDrawer) {
      CodeMeltedAPI.uiScaffoldKey.currentState!.openDrawer();
    } else if (CodeMeltedAPI.uiScaffoldKey.currentState!.hasEndDrawer) {
      CodeMeltedAPI.uiScaffoldKey.currentState!.openEndDrawer();
    }
  }

  @override
  State<StatefulWidget> createState() => _CUiAppViewState();

  CUiAppView({super.key}) {
    assert(
      !_isInitialized,
      "Only one CUiAppView can be created. It sets up a SPA.",
    );
    _isInitialized = true;
  }
}

class _CUiAppViewState extends State<CUiAppView> {
  @override
  void initState() {
    CUiAppView.uiState.addListener(listener: () => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: CUiAppView.darkTheme,
      navigatorKey: CodeMeltedAPI.uiNavigationKey,
      theme: CUiAppView.theme,
      themeMode: CUiAppView.themeMode,
      title: CUiAppView.title ?? "",
      home: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          var handler = CUiAppView.onResizeEvent;
          if (handler != null) {
            return handler(MediaQuery.of(context).size);
          }
          return false;
        },
        child: Scaffold(
          appBar: CUiAppView.uiState.get<AppBar?>(key: "appBar"),
          body: SizeChangedLayoutNotifier(
            child: CUiAppView.uiState.get<CObject?>(key: "content")?['body'],
          ),
          extendBody:
              CUiAppView.uiState.get<CObject?>(key: "content")?['extendBody'] ??
                  false,
          extendBodyBehindAppBar: CUiAppView.uiState
                  .get<CObject?>(key: "content")?["extendBodyBehindAppBar"] ??
              false,
          bottomNavigationBar:
              CUiAppView.uiState.get<BottomAppBar?>(key: "bottomAppBar"),
          drawer: CUiAppView.uiState.get<Widget?>(key: "drawer"),
          endDrawer: CUiAppView.uiState.get<Widget?>(key: "endDrawer"),
          floatingActionButton:
              CUiAppView.uiState.get<Widget?>(key: "floatingActionButton"),
          floatingActionButtonLocation: CUiAppView.uiState
              .get<FloatingActionButtonLocation?>(
                  key: "floatingActionButtonLocation"),
          key: CodeMeltedAPI.uiScaffoldKey,
        ),
      ),
    );
  }
}

/// Base class for setting up the Single Page App (SPA) via the
/// [CUiAppView] function.
abstract class CUiAppViewConfig {
  /// Function that carries out the configuration request in the child object.
  void _execute();
}

/// Defines the [CUiAppView] content area of the SPA.
class CUiAppContentConfig extends CUiAppViewConfig {
  /// Sets up the widget to display in the main area of the [CUiAppView] widget.
  final Widget? body;

  /// Determines whether to extend the body or not.
  final bool extendBody;

  /// Determines whether to extend the body behind the app bar. Part of the
  /// scrolling and transparency style.
  final bool extendBodyBehindAppBar;

  @override
  void _execute() {
    CUiAppView.content(
      body: body,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  /// Constructor for the class.
  CUiAppContentConfig({
    required this.body,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
  });
}

/// Provides the [CUiAppView] drawer / end drawer setup.
class CUiAppDrawerConfig extends CUiAppViewConfig {
  /// True to set the left hand drawer. False to set the right hand drawer.
  final bool isEndDrawer;

  /// Set up the upper display of the drawer or null to not have anything.
  final Widget? header;

  /// The selectable items to pick from in the drawer.
  final List<Widget>? items;

  @override
  void _execute() {
    var exec = isEndDrawer ? CUiAppView.endDrawer : CUiAppView.drawer;
    exec(header: header, items: items);
  }

  /// Constructor for the class. Set header and items to null to remove the
  /// drawer.
  CUiAppDrawerConfig({required this.isEndDrawer, this.header, this.items});
}

/// Provides the [CUiAppView] floating action button. This can also be
/// achieved with a [codemelted_ui] function utilizing a stack and a
/// position widget for exact X / Y placement.
/// @nodoc
class CUiAppFloatingActionButtonConfig extends CUiAppViewConfig {
  /// The widget that represents the floating action button.
  final Widget? button;

  /// The location of said button.
  final FloatingActionButtonLocation? location;

  @override
  void _execute() {
    CUiAppView.floatingActionButton(button: button, location: location);
  }

  /// Constructor for the class.
  CUiAppFloatingActionButtonConfig({this.button, this.location});
}

/// Provides the [CUiAppView] header / footer configuration.
class CUiAppToolbarConfig extends CUiAppViewConfig {
  /// True for being the header, false for being the footer.
  final bool isHeader;

  /// The array of actions to put to the right of the title.
  final List<Widget>? actions;

  /// The leading widget to the left of the title.
  final Widget? leading;

  /// The title widget to apply
  final Widget? title;

  /// The theme override to apply over the overall app theme.
  final AppBarTheme? style;

  /// Whether to force transparency of the header / footer for the content
  /// paged configuration.
  final bool forceMaterialTransparency;

  @override
  void _execute() {
    var exec = isHeader ? CUiAppView.header : CUiAppView.footer;
    exec(
      actions: actions,
      automaticallyImplyLeading: false,
      forceMaterialTransparency: forceMaterialTransparency,
      leading: leading,
      style: style,
      title: title,
    );
  }

  /// Constructor for the class. Set actions leading, title to null to clear
  /// the header / footer.
  CUiAppToolbarConfig({
    required this.isHeader,
    this.actions,
    this.leading,
    this.title,
    this.style,
    this.forceMaterialTransparency = false,
  });
}

/// Sets the overall SPA theme of the [CUiAppView] via the
/// [CodeMeltedAPI.ui_theme] function.
class CUiAppThemeConfig extends CUiAppViewConfig {
  /// Sets up the light theme for the overall SPA.
  final ThemeData? theme;

  /// Sets up the dark theme for the overall SPA.
  final ThemeData? darkTheme;

  /// Sets up the theme mode of the SPA. System or forced light / dark.
  final ThemeMode? themeMode;

  /// Sets the title of the application.
  final String? title;

  @override
  void _execute() {
    CUiAppView.darkTheme = darkTheme ?? CUiAppView.darkTheme;
    CUiAppView.theme = theme ?? CUiAppView.theme;
    CUiAppView.themeMode = themeMode ?? CUiAppView.themeMode;
    CUiAppView.title = title ?? CUiAppView.title;
  }

  CUiAppThemeConfig({
    this.darkTheme,
    this.theme,
    this.themeMode,
    this.title,
  });
}

/// Base Widget configuration for the [CodeMeltedAPI.ui_widget] widget building
/// function.
abstract class CUiWidget {
  /// Function to build the actual widget based on the configuration.
  Widget _build();
}

/// Supports identifying the module [CUiButtonWidget] for widget construction.
enum CUiButtonType { elevated, filled, icon, outlined, text }

/// Provides the button [CUiWidget] widget with different supported
/// styles.
class CUiButtonWidget extends CUiWidget {
  /// The action to take when the button is pressed.
  final void Function() onPressed;

  /// The label title on the button or a hint if an icon type button.
  final String title;

  /// [CUiButtonType] button to render.
  final CUiButtonType type;

  /// The key to tie together a series of widgets.
  final Key? key;

  /// Whether to enable or disable the button.
  final bool enabled;

  /// An [Image] or [IconData] object representing the icon.
  final dynamic icon;

  /// Override of the overall button style vs. the overall SPA theme.
  final ButtonStyle? style;

  @override
  Widget _build() {
    assert(
      icon is IconData || icon is Image || icon == null,
      "icon can only be an Image / IconData / null type",
    );

    Widget? btn;
    if (type == CUiButtonType.elevated) {
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
    } else if (type == CUiButtonType.filled) {
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
    } else if (type == CUiButtonType.icon) {
      btn = IconButton(
        key: key,
        icon: icon is IconData ? Icon(icon) : icon,
        tooltip: title,
        onPressed: enabled ? onPressed : null,
        style: style,
      );
    } else if (type == CUiButtonType.outlined) {
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
    } else if (type == CUiButtonType.text) {
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

  /// Constructor for the object.
  CUiButtonWidget({
    required this.onPressed,
    required this.title,
    required this.type,
    this.key,
    this.enabled = true,
    this.icon,
    this.style,
  });
}

/// Provides the centering layout [CUiWidget] within a view.
class CUiCenterWidget extends CUiWidget {
  /// The key to tie together a series of widgets.
  final Key? key;

  /// The widget to center
  final Widget? child;

  /// A height factor to apply for the centering.
  final double? heightFactor;

  /// A width factor to apply for the centering.
  final double? widthFactor;

  @override
  Widget _build() {
    return Center(
      key: key,
      heightFactor: heightFactor,
      widthFactor: widthFactor,
      child: child,
    );
  }

  /// Constructor for the class.
  CUiCenterWidget({this.key, this.child, this.heightFactor, this.widthFactor});
}

/// Provides the [CUiWidget] layout widgets vertically.
class CUiColumnWidget extends CUiWidget {
  /// The widgets to put in the layout.
  final List<Widget> children;

  /// A key to group a series of widgets.
  final Key? key;

  /// The cross axis alignment to apply.
  final CrossAxisAlignment crossAxisAlignment;

  /// The main axis alignment to apply.
  final MainAxisAlignment mainAxisAlignment;

  /// The size of the axis.
  final MainAxisSize mainAxisSize;

  @override
  Widget _build() {
    return Column(
      key: key,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Constructor for the object.
  CUiColumnWidget({
    required this.children,
    this.key,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });
}

/// Provides the [CUiWidget] that creates a customizable combo box
/// drop down with the ability to implement a search box to filter the combo
/// box.
class CUiComboBoxWidget<T> extends CUiWidget {
  /// The menu entries for the combo box.
  final List<DropdownMenuEntry<T>> dropdownMenuEntries;

  /// The key to group a bunch of widgets together.
  final Key? key;

  /// Whether to enable or disable the widget.
  final bool enabled;

  /// Whether filters are utilized or not.
  final bool enableFilter;

  /// Whether search is utilized or not.
  final bool enableSearch;

  /// Text to provide a error message when something is amiss.
  final String? errorText;

  /// The height of the general dropdown menu selection.
  final double? menuHeight;

  /// Helper text explain what to do with the widget.
  final String? helperText;

  /// A hint for when making selections.
  final String? hintText;

  /// The initial selection if there is to be one.
  final T? initialSelection;

  /// A label to apply to the widget control
  final Widget? label;

  /// A leading icon to apply to the control.
  final dynamic leadingIcon;

  /// The callback handler for the selected value.
  final void Function(T?)? onSelected;

  /// The callback to handle the search functionality if set to true.
  final int? Function(List<DropdownMenuEntry<T>>, String)? searchCallback;

  /// The theme override to apply vs. the overall app theme.
  final DropdownMenuThemeData? style;

  /// A trailing icon to apply.
  final dynamic trailingIcon;

  /// The width of the selection area.
  final double? width;

  @override
  Widget _build() {
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
            data: style!,
            child: menu,
          )
        : menu;
  }

  /// Constructor for the object.
  CUiComboBoxWidget({
    required this.dropdownMenuEntries,
    this.key,
    this.enabled = true,
    this.enableFilter = false,
    this.enableSearch = true,
    this.errorText,
    this.menuHeight,
    this.helperText,
    this.hintText,
    this.initialSelection,
    this.label,
    this.leadingIcon,
    this.onSelected,
    this.searchCallback,
    this.style,
    this.trailingIcon,
    this.width,
  });
}

/// Provides the [CUiWidget] the most basic component for setting up a
/// UI. This widget can be utilized to setup padding, margins, or build custom
/// stylized widgets combining said widget or layouts to build a more complex
/// widget.
class CUiContainerWidget extends CUiWidget {
  /// The key to group a series of widgets as a singular group.
  final Key? key;

  /// The alignment to apply to the overall container.
  final AlignmentGeometry? alignment;

  /// Padding to apply to the widget.
  final EdgeInsetsGeometry? padding;

  /// The background color to apply.
  final Color? color;

  /// A series of different customization decorations to apply to the widget.
  final Decoration? decoration;

  /// A series of different customization decorations to apply to the widget.
  final Decoration? foregroundDecoration;

  /// The width of the widget.
  final double? width;

  /// The height of the widget.
  final double? height;

  /// How to constrain the widget.
  final BoxConstraints? constraints;

  /// The margins to apply within the widget.
  final EdgeInsetsGeometry? margin;

  /// Ways of transforming the widget.
  final Matrix4? transform;

  /// The alignment of the transform.
  final AlignmentGeometry? transformAlignment;

  /// What to do in an overflow condition.
  final Clip clipBehavior;

  /// A widget to add to the container.
  final Widget? child;

  @override
  Widget _build() {
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

  /// Constructor for the class.
  CUiContainerWidget({
    this.key,
    this.alignment,
    this.padding,
    this.color,
    this.decoration,
    this.foregroundDecoration,
    this.width,
    this.height,
    this.constraints,
    this.margin,
    this.transform,
    this.transformAlignment,
    this.clipBehavior = Clip.none,
    this.child,
  });
}

/// Provides the [CUiDividerWidget] a vertical or horizontal spacer between
/// widgets that can have a dividing line set if necessary.
class CUiDividerWidget extends CUiWidget {
  /// The key to use to group a bunch of widgets.
  final Key? key;

  /// The spacing height.
  final double? height;

  /// The spacing width.
  final double? width;

  /// The color to set on the divider.
  final Color color;

  @override
  Widget _build() {
    return Container(
      key: key,
      color: color,
      height: height,
      width: width,
    );
  }

  /// Constructor for the class.
  CUiDividerWidget({
    this.key,
    this.height,
    this.width,
    this.color = Colors.transparent,
  });
}

/// Provides the [CUiWidget] the ability to have an expansion list of
/// widgets.
class CUiExpansionTileWidget extends CUiWidget {
  /// The widgets that are part of the expansion widget.
  final List<Widget> children;

  /// Title to apply to the widget.
  final Widget title;

  /// A way of grouping like minded widgets.
  final Key? key;

  /// Is this thing enabled or not.
  final bool enabled;

  /// Whether to initially expand the list or not.
  final bool initiallyExpanded;

  /// A leading icon of sorts.
  final dynamic leading;

  /// A style override instead of the overall SPA setting.
  final ExpansionTileThemeData? style;

  /// A subtitle to apply. A description if you will.
  final Widget? subtitle;

  /// A trailing icon of the overall list.
  final dynamic trailing;

  @override
  Widget _build() {
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

    return style != null ? ExpansionTileTheme(data: style!, child: w) : w;
  }

  /// The constructor for the class.
  CUiExpansionTileWidget({
    required this.children,
    required this.title,
    this.key,
    this.enabled = true,
    this.initiallyExpanded = false,
    this.leading,
    this.style,
    this.subtitle,
    this.trailing,
  });
}

/// Provides the [CUiWidget] a wrapper for an asynchronous widget to
/// load data and then present it when completed.
class CUiFutureBuilderWidget<T> extends CUiWidget {
  /// The builder to perform the necessary widget and async calls.
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;

  /// The actual async call to make.
  final Future<T>? future;

  /// A way of grouping like minded widgets.
  final Key? key;

  /// The initial data to utilize for the future.
  final T? initialData;

  @override
  Widget _build() {
    return FutureBuilder<T>(
      key: key,
      initialData: initialData,
      future: future,
      builder: builder,
    );
  }

  /// Constructor for the object.
  CUiFutureBuilderWidget({
    required this.builder,
    required this.future,
    this.key,
    this.initialData,
  });
}

/// Provides the [CUiWidget] a scrollable grid layout of widgets that
/// based on the crossAxisCount.
class CUiGridViewWidget extends CUiWidget {
  /// How many columns is this thing going to be.
  final int crossAxisCount;

  /// The children to layout in the grid.
  final List<Widget> children;

  /// A way of grouping like minded widgets.
  final Key? key;

  /// What to do when the widgets overflow.
  final Clip clipBehavior;

  /// The aspect ratio of the widgets.
  final double childAspectRatio;

  /// The spacing to provide along with cross axis.
  final double crossAxisSpacing;

  /// The spacing to apply along the main axis.
  final double mainAxisSpacing;

  /// The padding to apply.
  final EdgeInsetsGeometry? padding;

  /// Am I the primary.
  final bool? primary;

  /// Reverse the scroll.
  final bool reverse;

  /// Which way am I scrolling.
  final Axis scrollDirection;

  /// Make all things nice and compact.
  final bool shrinkWrap;

  @override
  Widget _build() {
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

  /// Constructor for the object.
  CUiGridViewWidget({
    required this.crossAxisCount,
    required this.children,
    this.key,
    this.clipBehavior = Clip.hardEdge,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.padding,
    this.primary,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
  });
}

/// Supports identifying what module [CUiImageWidget] for widget construction.
enum CUiImageType { asset, file, memory, network }

/// Provides the [CUiWidget] to create an image widget based on the
/// specified [CUiImageType] enumerated value and display it when available based
/// on the characteristics specified with the widget. No theme controls this
/// widget type so the characteristics are unique to each widget created.
class CUiImageWidget extends CUiWidget {
  /// Identifies the [CUiImageType] of data.
  final CUiImageType type;

  /// The source of the data.
  final dynamic src;

  /// How do we want to align this thing.
  final Alignment alignment;

  /// How do you want me to fit in this widget.
  final BoxFit? fit;

  /// How tall am I.
  final double? height;

  /// Should I repeat if I have room.
  final ImageRepeat repeat;

  /// How wide do you think I am again...
  final double? width;

  @override
  Widget _build() {
    if (type == CUiImageType.asset) {
      return Image.asset(
        src,
        alignment: alignment,
        fit: fit,
        height: height,
        repeat: repeat,
        width: width,
      );
    } else if (type == CUiImageType.file) {
      return Image.file(
        src,
        alignment: alignment,
        fit: fit,
        height: height,
        repeat: repeat,
        width: width,
      );
    } else if (type == CUiImageType.memory) {
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

  /// Constructor for the object.
  CUiImageWidget({
    required this.type,
    required this.src,
    this.alignment = Alignment.center,
    this.fit,
    this.height,
    this.repeat = ImageRepeat.noRepeat,
    this.width,
  });
}

/// Provides theming of the regular [InputDecorationTheme] but expands to
/// the input style and other attributes of styling. Modeled off the
/// [DropdownMenuTheme] to be consistent with that control.
class CUiInputDecorationTheme extends InputDecorationTheme {
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
  CUiInputDecorationTheme copyWith({
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
    BoxConstraints? prefixIconConstraints,
    TextStyle? suffixStyle,
    Color? suffixIconColor,
    BoxConstraints? suffixIconConstraints,
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
    return CUiInputDecorationTheme(
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
  const CUiInputDecorationTheme({
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

/// Provides the [CUiWidget] a basic text label with the ability to make
/// it multi-line, clip it if to long.
class CUiLabelWidget extends CUiWidget {
  /// Tell me you want to say in this label.
  final String data;

  /// Grouping like minded widgets together.
  final Key? key;

  /// How many lines is this thing.
  final int? maxLines;

  /// So should I wor wrap this think or just clip or something.
  final bool? softWrap;

  /// The style to apply to this label.
  final TextStyle? style;

  @override
  Widget _build() {
    return Text(
      data,
      key: key,
      maxLines: maxLines,
      softWrap: softWrap,
      style: style,
    );
  }

  /// Constructor for the class.
  CUiLabelWidget({
    required this.data,
    this.key,
    this.maxLines,
    this.softWrap,
    this.style,
  });
}

/// Provides the [CUiWidget] a selectable widget to be part of a view of
/// selectable items.
class CUiListTileWidget extends CUiWidget {
  /// What do I do when tapped.
  final void Function() onTap;

  /// Grouping like minded widgets together.
  final Key? key;

  /// Is this thing on or not.
  final bool enabled;

  /// Putting a leading icon on this thing.
  final dynamic leading;

  /// What is this thing.
  final Widget? title;

  /// Please tell me more about this thing.
  final Widget? subtitle;

  /// The trailing icon to apply.
  final dynamic trailing;

  /// An override to the overall style vs. the app theme.
  final ListTileThemeData? style;

  @override
  Widget _build() {
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

  /// Constructor for the object.
  CUiListTileWidget({
    required this.onTap,
    this.key,
    this.enabled = true,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.style,
  });
}

/// Provides the [CUiWidget] a list view of widgets with automatic
/// scrolling that can be set for vertical (default) or horizontal.
class CUiListViewWidget extends CUiWidget {
  /// The items to put in a scrollable list.
  final List<Widget> children;

  /// Like minded widgets keyed together.
  final Key? key;

  /// What do I do if I overflow.
  final Clip clipBehavior;

  /// A padding to apply to the listed widgets.
  final EdgeInsetsGeometry? padding;

  /// Am I prime.
  final bool? primary;

  /// Should I reverse the scroll.
  final bool reverse;

  /// What direction shall I scroll?
  final Axis scrollDirection;

  /// Shrink this thing to make it more tight.
  final bool shrinkWrap;

  @override
  Widget _build() {
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

  /// Constructor for the class.
  CUiListViewWidget({
    required this.children,
    this.key,
    this.clipBehavior = Clip.hardEdge,
    this.padding,
    this.primary,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
  });
}

/// Provides the [CUiWidget] layout to put widgets horizontally.
class CUiRowWidget extends CUiWidget {
  /// The widgets we want on the horizon.
  final List<Widget> children;

  /// Grouping like minded widgets together.
  final Key? key;

  /// How to align the cross axis.
  final CrossAxisAlignment crossAxisAlignment;

  /// How to align the main axis.
  final MainAxisAlignment mainAxisAlignment;

  /// How big is that main axis.
  final MainAxisSize mainAxisSize;

  @override
  Widget _build() {
    return Row(
      key: key,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  /// Constructor for the object.
  CUiRowWidget({
    required this.children,
    this.key,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });
}

/// Provides the [CUiWidget] a stacked widget based on the children
/// allowing for a custom look and feel for "special" widgets that stack
/// bottom to top and overlap.
class CUiStackWidget extends CUiWidget {
  /// The widgets to stack on each other to create the super widget.
  final List<Widget> children;

  /// A grouping of like minded widgets.
  final Key? key;

  /// How to align the stacked widgets.
  final AlignmentGeometry alignment;

  /// Oh no we overflowed, what do we do.
  final Clip clipBehavior;

  /// How to make things fit on the widget.
  final StackFit fit;

  /// The direction of the stack text.
  final TextDirection? textDirection;

  @override
  Widget _build() {
    return Stack(
      alignment: alignment,
      clipBehavior: clipBehavior,
      fit: fit,
      key: key,
      textDirection: textDirection,
      children: children,
    );
  }

  /// Constructor for the class.
  CUiStackWidget({
    required this.children,
    this.key,
    this.alignment = AlignmentDirectional.topStart,
    this.clipBehavior = Clip.hardEdge,
    this.fit = StackFit.loose,
    this.textDirection,
  });
}

/// Defines a tab item to utilize with the [CUiTabbedView] object.
class CUiTabItem {
  /// The content displayed with the tab.
  final Widget? content;

  /// An icon for the tab within the tab view.
  final dynamic icon;

  /// A title with the tab within the tab view.
  final String? title;

  CUiTabItem({
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

// TODO: Create custom theme to add other items to reflect tab style like other
//       material3 widgets.

/// Widget associated with the [CUiTabbedViewWidget] to build a tabbed
/// interface of content via the [CodeMeltedAPI.ui_widget] function.
class CUiTabbedView extends StatefulWidget {
  /// The list of [CUiTabItem] definitions of the tabbed content.
  final List<CUiTabItem> tabItems;
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

  const CUiTabbedView({
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
  State<StatefulWidget> createState() => _CUiTabbedViewState();
}

class _CUiTabbedViewState extends State<CUiTabbedView>
    with TickerProviderStateMixin {
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

/// Provides the [CUiWidget] a tab view of content to allow for users to
/// switch between widgets of data.
class CUiTabbedViewWidget extends CUiWidget {
  /// The tab [CUiTabItem] list that represents the tabbed content.
  final List<CUiTabItem> tabItems;

  /// A way of grouping like minded widgets.
  final Key? key;

  /// Whether to adjust the tab size or not.
  final bool automaticIndicatorColorAdjustment;

  /// The background color of the tab.
  final Color? backgroundColor;

  /// The clip behavior when the tabs are just to big.
  final Clip clipBehavior;

  /// The height of the tabs
  final double? height;

  /// The margins to apply to the tab.
  final EdgeInsetsGeometry? iconMargin;

  /// The weight to indicate the active tab.
  final double indicatorWeight;

  /// Whether to scroll the overflow of tabs or not.
  final bool isScrollable;

  /// A callback handler for indicating the tab that was clicked.
  final void Function(int)? onTap;

  /// The them to override vs. the app style.
  final TabBarTheme? style;

  /// The fractional viewport to apply.
  final double viewportFraction;

  /// A reference to the created tab controller once the widget is created.
  final void Function(TabController)? onTabControllerCreated;

  @override
  Widget _build() {
    return CUiTabbedView(
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

  /// Constructor for the class.
  CUiTabbedViewWidget({
    required this.tabItems,
    this.key,
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
}

/// Provides the [CUiWidget] a generalized widget to allow for the
/// collection of data and providing feedback to a user. It exposes the most
/// common text field options to allow for building custom text fields (i.e.
/// spin controls, number only, etc.).
class CUiTextFieldWidget extends CUiWidget {
  /// Whether to enable / disable auto correct within the text field.
  final bool autocorrect;

  /// Whether to enable suggestions or not.
  final bool enableSuggestions;

  /// The controller that handles changes to the underlying widget.
  final TextEditingController? controller;

  /// The initial value to set the text field to.
  final String? initialValue;

  /// Is this thing on or off.
  final bool enabled;

  /// Can I read from this thing or not.
  final bool readOnly;

  /// Is this a password or not?
  final bool obscureText;

  /// How shall I hide the password.
  final String obscuringCharacter;

  /// The input action to apply.
  final TextInputAction? textInputAction;

  /// What kind of keyboard to render.
  final TextInputType? keyboardType;

  /// The changes as they are happening.
  final void Function(String)? onChanged;

  /// Signal when the changes are completed.
  final void Function()? onEditingComplete;

  /// Signal when the value is submitted as a form.
  final void Function(String)? onFieldSubmitted;

  /// Signal when the value is saved.
  final void Function(String?)? onSaved;

  /// A validator callback to do the validating.
  final String? Function(String?)? validator;

  /// The input formatter to apply.
  final List<TextInputFormatter>? inputFormatters;

  /// The error text to display when an error has happened.
  final String? errorText;

  /// How do I use this thing again.
  final String? helperText;

  /// If you just do this then everything will be fine.
  final String? hintText;

  /// How to identify the fie.d
  final String? labelText;

  /// A leading widget to put in front of the field.
  final Widget? leadingWidget;

  /// A trailing widget to put at the back of the field.
  final Widget? trailingWidget;

  /// An override style to apply vs. the overall app theme.
  final CUiInputDecorationTheme? style;

  /// A way of grouping like minded widgets together.
  final Key? key;

  @override
  Widget _build() {
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

  /// Constructor for the class.
  CUiTextFieldWidget({
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.obscuringCharacter = '•',
    this.textInputAction,
    this.keyboardType,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.validator,
    this.inputFormatters,
    this.errorText,
    this.helperText,
    this.hintText,
    this.labelText,
    this.leadingWidget,
    this.trailingWidget,
    this.style,
    this.key,
  });
}

/// Provides the [CUiWidget] the ability to show / hide a widget and
/// setup how to treat other aspects of the widget.
class CUiVisibilityWidget extends CUiWidget {
  /// The widget that will be shown / hidden.
  final Widget child;

  /// A way of grouping like minded widgets.
  final Key? key;

  /// A state thing.
  final bool maintainState;

  /// A state thing.
  final bool maintainAnimation;

  /// A state thing.
  final bool maintainSize;

  /// A state thing.
  final bool maintainSemantics;

  /// A state thing.
  final bool maintainInteractivity;

  /// Show or hide the widget already.
  final bool visible;

  @override
  Widget _build() {
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

  /// Constructor for the class.
  CUiVisibilityWidget({
    required this.child,
    this.key,
    this.maintainState = false,
    this.maintainAnimation = false,
    this.maintainSize = false,
    this.maintainSemantics = false,
    this.maintainInteractivity = false,
    this.visible = true,
  });
}

/// Enumerations set specifying the allowed actions within
/// [CUiWebViewWidget] widget.
enum CUiWebViewSandboxAllow {
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

  const CUiWebViewSandboxAllow(this.sandbox);
}

/// The web view controller to support the [CUiWebViewWidget] for widget
/// creation.
class CUiWebViewController {
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

  /// The set of [CUiWebViewSandboxAllow] permissions for the web view.
  final List<CUiWebViewSandboxAllow> sandbox;

  /// Constructor for the object.
  CUiWebViewController({
    required String initialUrl,
    this.allow = "",
    this.allowFullScreen = true,
    this.sandbox = const [],
  }) {
    _url = initialUrl;
  }
}

/// Provides the [CUiWidget] with an embedded web view via an iFrame to
/// load other HTML documents.
class CUiWebViewWidget extends CUiWidget {
  /// The [CUiWebViewController] to allow working with the view context.
  final CUiWebViewController controller;

  @override
  Widget _build() {
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

  /// Constructor for the class.
  CUiWebViewWidget({required this.controller});
}

/// Provides a wrapper around the Flutter ThemeData object that isolates
/// the application theming to the material3 constructs of Flutter. Extended
/// existing ThemeData objects utilized to provide a similar theming experience.
/// The theme is created via the [CodeMeltedAPI.ui_theme] function.
extension ThemeDataExtension on ThemeData {
  /// Gets access to the specialized input decoration theme to pick up styles
  /// for all items that may utilize it.
  CUiInputDecorationTheme get cUiInputDecorationTheme =>
      inputDecorationTheme as CUiInputDecorationTheme;
}

// ============================================================================
// [MODULE API IMPLEMENTATION] ================================================
// ============================================================================

/// Something Something star wars.
class CodeMeltedAPI {
  // ==========================================================================
  // [API DATA DEFINITIONS] ===================================================
  // ==========================================================================

  /// Holds the `codemelted.js` location when codemelted_web module is built.
  static const scriptFile = "/assets/packages/codemelted_web/assets/"
    "js/codemelted.js";

  /// Sets up a global navigator key for usage with dialogs rendered with the
  /// [ui_dialog] function.
  static final uiNavigationKey = GlobalKey<NavigatorState>();

  /// Sets up a global scaffold key for opening drawers and such on the
  /// [CUiAppView] widget..
  static final uiScaffoldKey = GlobalKey<ScaffoldState>();

  /// Holds the instance reference for the factory.
  static CodeMeltedAPI? _instance;

  /// Holds the JSObject `codemelted.js` exported module reference.
  JSObject? _module;

  /// Accesses the `codemelted.js` Flutter binding.
  JSObject get module {
    assert(_module != null, "codemelted.js module was not loaded!");
    return _module!;
  }

  /// Responsible for loading the `codemelted.js` script file to provide
  /// the flutter bindings for the `codemelted.dart` module.
  /// YOU SHOULD NOT NEED TO CALL THIS. THE JS MODULE IS PACKAGED AND DEPLOYED
  /// WITH THE `codemelted.dart` MODULE.
  Future<CResult> loadScript([String script = scriptFile]) async {
    try {
      _module ??= await importModule(script.toJS).toDart;
      return CResult();
    } catch (err, st) {
      return CResult(error: err.toString(), st: st);
    }
  }

  // ==========================================================================
  // [ASYNC UC BINDING] =======================================================
  // ==========================================================================

  /// Will put a currently running async task to sleep for a specified delay
  /// in milliseconds.
  ///
  /// **Example:**
  /// ```dart
  /// /// Sleeps an asynchronous task for 1 second.
  /// await async_sleep(1000);
  /// ```
  Future<void> async_sleep(int delay) async {
    return Future.delayed(Duration(milliseconds: delay));
  }

  /// Schedules an asynchronous [CTaskCB] for a given delay in milliseconds
  /// into the future with the ability to process the specified data and return
  /// a result.
  ///
  /// **Example:**
  /// ```dart
  /// // Schedule a task to run a calculation in the future to learn about
  /// // the answer to life.
  /// var result = await async_task<int>(
  ///   task: ([data]) {
  ///     return data + 5;
  ///   },
  ///   data: 37,
  /// );
  /// if (result.isOk) {
  ///   print(result.value);
  /// } else {
  ///   print("${result.error}\n${result.st}");
  /// }
  /// ```
  Future<CResult<T>> async_task<T>({
    required CTaskCB<T> task,
    dynamic data,
    int delay = 0,
  }) async {
    return Future.delayed(
      Duration(milliseconds: delay),
      () async {
        try {
          var answer = await task(data);
          return CResult(value: answer);
        } catch (err, st) {
          return CResult(error: err.toString(), st: st);
        }
      },
    );
  }

  /// Creates a repeating [CTimerCB] on the specified interval in milliseconds.
  /// You top the task by calling the [CTimerResult.stop] returned by the
  /// call.
  ///
  /// **Example:**
  /// ```dart
  /// // Do some repeating task on a 1 second boundary.
  /// var timer = async_timer(
  ///   task: () {
  ///     // Do a repeating task.
  ///   },
  ///   interval: 1000,
  /// );
  ///
  /// // Sometime later after the repeating task is no longer needed.
  /// timer.stop();
  /// ```
  CTimerResult async_timer({required CTimerCB task, required int interval}) {
    return CTimerResult(
      Timer.periodic(
        Duration(milliseconds: interval),
        (timer) {
          task();
        },
      ),
    );
  }

  // ==========================================================================
  // [CONSOLE UC BINDING] =====================================================
  // ==========================================================================

  // NOT APPLICABLE TO FLUTTER WEB TARGET

  // ==========================================================================
  // [DB UC BINDING] ==========================================================
  // ==========================================================================

  // TO BE DEVELOPED.

  // ==========================================================================
  // [DISK UC BINDING] ========================================================
  // ==========================================================================

  // TO BE DEVELOPED.

  // ==========================================================================
  // [HW UC BINDING] ==========================================================
  // ==========================================================================

  // TO BE DEVELOPED.

  // ==========================================================================
  // [JSON UC BINDING] ==========================================================
  // ==========================================================================

  /// Checks the type of the dynamic data to ensure it is of an expected type
  /// with an option to throw rather then checking the returned bool.
  ///
  /// **Example:**
  /// ```dart
  /// // Some random data received somehow that is dynamic and you would not
  /// // know the type.
  /// var data = "duh";
  ///
  /// // Go perform a check of the type. Remember you can specify to throw
  /// // vs. checking this way.
  /// var isExpectedType = json_check_type<bool>(data: data);
  /// if (!isExpectedType) {
  ///   // Handle that it is not what you expected.
  /// }
  /// ```
  bool json_check_type<T>({required dynamic data, bool shouldThrow = false}) {
    var result = data is T;
    if (shouldThrow && !result) {
      throw "data was not an expected type.";
    }
    return result;
  }

  /// Creates a JSON compliant [CArray] object.
  ///
  /// **Example:**
  /// ```dart
  /// // To get a new CArray
  /// var data = json_create_array();
  ///
  /// // To get a copy of a CArray
  /// var data2 = <CArray>[1, true, "false", 42.2, null];
  /// var copy = json_create_array(data2);
  /// ```
  CArray json_create_array([CArray? data]) {
    return data != null ? data.copy() : [];
  }

  /// Creates a JSON compliant [CObject] object.
  ///
  /// **Example:**
  /// ```dart
  /// // To create a new CObject
  /// var obj = json_create_object();
  ///
  /// // To copy an existing object to a new object
  /// var obj2 = <CObject>{
  ///   "field1": 1,
  ///   "field2": true,
  ///   "field3": "duh",
  ///   "field4": [1, 2, null, 4, false],
  ///   "field5": {
  ///     "life_answer": 42.2,
  ///     "other_answers": null,
  ///   }
  /// };
  /// var copy = json_create_object(obj2);
  /// ```
  CObject json_create_object([CObject? data]) {
    return data != null ? CObject.from(data) : CObject();
  }

  /// Determines if a particular [CObject] has an expected key.
  ///
  /// **Example:**
  /// ```dart
  /// // Given some data
  /// var obj = <CObject>{
  ///   "field1": 1,
  ///   "field2": true,
  ///   "field3": "duh",
  ///   "field4": [1, 2, null, 4, false],
  ///   "field5": {
  ///     "life_answer": 42.2,
  ///     "other_answers": null,
  ///   }
  /// };
  ///
  /// // Do what you will with the check
  /// // You can also throw
  /// var hasProperty = json_has_key(
  ///   obj: obj,
  ///   key: "field6"
  /// );
  /// print(hasProperty);
  /// ```
  bool json_has_key({
    required CObject obj,
    required String key,
    bool shouldThrow = false,
  }) {
    var result = obj.containsKey(key);
    if (shouldThrow && !result) {
      throw "data did not contain expected key.";
    }
    return result;
  }

  /// Will parse the given string data into a JSON compliant data type.
  ///
  /// **Example:**
  /// ```dart
  /// // Given some string data
  /// var data = "duh";
  /// var parsed = json_parse<int>(data);
  /// if (parsed != null) {
  ///   // Do something with the parsed data.
  /// } else {
  ///   print("Data not as expected");
  /// }
  /// ```
  T? json_parse<T>(String data) {
    if (T.toString().containsIgnoreCase("carray")) {
      return data.asArray() as T?;
    } else if (T.toString().containsIgnoreCase("bool")) {
      return data.asBool() as T;
    } else if (T.toString().containsIgnoreCase("double")) {
      return data.asDouble() as T?;
    } else if (T.toString().containsIgnoreCase("int")) {
      return data.asInt() as T?;
    } else if (T.toString().containsIgnoreCase("cobject")) {
      return data.asObject() as T?;
    }
    throw "SyntaxError: T was not a compliant JSON type.";
  }

  /// Will stringify either [CArray] or [CObject] data to a JSON compliant
  /// string. Null is returned if it cannot be stringified.
  ///
  /// **Example:**
  /// ```dart
  /// // Given some data
  /// var obj = <CObject>{
  ///   "field1": 1,
  ///   "field2": true,
  ///   "field3": "duh",
  ///   "field4": [1, 2, null, 4, false],
  ///   "field5": {
  ///     "life_answer": 42.2,
  ///     "other_answers": null,
  ///   }
  /// };
  ///
  /// var stringified = json_stringify(obj);
  /// print(stringified);
  /// ```
  String? json_stringify(dynamic data) {
    assert(
      data is CArray || data is CObject,
      "data must be CArray or CObject types",
    );
    return data.stringify();
  }

  /// Validates that a given string URL is valid with an option to throw vs
  /// checking the return bool.
  ///
  /// **Example:**
  /// ```dart
  /// // Given some url.
  /// var url = "https://something.com";
  /// json_valid_url(
  ///   url: url,
  ///   shouldThrow: true, // Throw because we never expect it to be bad.
  /// );
  /// ```
  bool json_valid_url({required String url, bool shouldThrow = false}) {
    var valid = Uri.tryParse(url) != null;
    if (shouldThrow && !valid) {
      throw "url was not valid.";
    }
    return valid;
  }

  // ==========================================================================
  // [LOGGER UC BINDING] ======================================================
  // ==========================================================================

  // TO BE DEVELOPED.

  // ==========================================================================
  // [MONITOR UC BINDING] =====================================================
  // ==========================================================================

  // NOT APPLICABLE TO FLUTTER WEB TARGET

  // ==========================================================================
  // [NETWORK UC BINDING] =====================================================
  // ==========================================================================

  // TO BE DEVELOPED.

  // ==========================================================================
  // [NPU UC BINDING] =========================================================
  // ==========================================================================

  /// Executes the specified [MATH_FORMULA] based on the given arguments to
  /// retrieve the calculated answer. NaN is returned in the event of
  /// division by 0 or squaring of a negative number.
  ///
  /// **Example:**
  /// ```dart
  /// // 0 °C == 32 °F
  /// var answer = codemelted_js.npu_math(
  ///   formula: MATH_FORMULA.TemperatureCelsiusToFahrenheit,
  ///   args: [0.0]
  /// );
  /// ```
  double npu_math({required MATH_FORMULA formula, required List<double> args}) {
    var formulaObj = module.getProperty<JSObject>("MATH_FORMULA".toJS);
    var formulaArgs = <JSNumber>[];
    for (var v in args) {
      formulaArgs.add(v.toJS);
    }
    var theFormula = formulaObj.getProperty<JSFunction>(formula.name.toJS);
    var params = <String, dynamic>{
      "formula": theFormula,
      "args": formulaArgs.toJS
    };
    var answer = module.callMethod<JSNumber>("npu_math".toJS, params.jsify());
    return answer.toDartDouble;
  }

  // ==========================================================================
  // [PROCESS UC BINDING] =====================================================
  // ==========================================================================

  // NOT APPLICABLE TO FLUTTER WEB TARGET

  // ==========================================================================
  // [RUNTIME UC BINDING] =====================================================
  // ==========================================================================

  /// Determines the available CPU processors for background workers.
  ///
  /// **Example:**
  /// ```dart
  /// var cpuCount = codemelted_js.runtime_cpu_count();
  /// ```
  int runtime_cpu_count() {
    return module.callMethod<JSNumber>("runtime_cpu_count".toJS).toDartInt;
  }

  /// Provides the ability to search the document search parameters for
  /// queryable parameters on the web document.
  ///
  /// **Example:**
  /// ```dart
  /// var value = codemelted_js.runtime_environment("username");
  /// ```
  String? runtime_environment(String name) {
    var value = module.callMethod<JSString?>(
      "runtime_environment".toJS,
      name.toJS
    );
    return value.isUndefinedOrNull ? null : value!.toDart;
  }

  /// Adds or removes an event listener to the JavaScript browser runtime or
  /// individual EventSource object. The action parameter will take either
  /// "add" or "remove". The type parameter corresponds to the event you are
  /// registering to handle. The listener represents the listener to respond
  /// to the events.
  ///
  /// **Example:**
  /// ```dart
  /// // To add an event to react to when the web document is loaded
  /// void listener(web.Event e) {
  ///   // Do something with the events...
  /// }
  ///
  /// codemelted_js.runtime_event(
  ///   action: "add",
  ///   type: "DOMContentLoaded",
  ///   listener: listener
  /// );
  ///
  /// // To eventually remove the event
  /// codemelted_js.runtime_event(
  ///   action: "remove",
  ///   type: "DOMContentLoaded",
  ///   listener: listener
  /// );
  /// ```
  void runtime_event({
    required String action,
    required String type,
    required CEventHandler listener,
    web.EventSource? obj
  }) {
    var params = <String, dynamic>{
      "action": action.toJS,
      "type": type.toJS,
      "listener": listener.jsify(),
      "obj": obj.jsify()
    };
    module.callMethod("runtime_event".toJS, params.jsify());
  }

  /// Determines the hostname of the browser runtime.
  ///
  /// **Example:**
  /// ```dart
  /// var hostname = codemelted_js.hostname();
  /// ```
  String runtime_hostname() {
    return module.callMethod<JSString>("runtime_hostname".toJS).toDart;
  }

  /// Determines what browser the JavaScript runtime represents.
  ///
  /// **Example:**
  /// ```dart
  /// var runtime = codemelted_js.runtime_name();
  /// ```
  String runtime_name() {
    return module.callMethod<JSString>("runtime_name".toJS).toDart;
  }

  /// Determines if the web document has access to the Internet.
  ///
  /// **Example:**
  /// ```dart
  /// var online = codemelted_js.runtime_online();
  /// ```
  bool runtime_online() {
    return module.callMethod<JSBoolean>("runtime_online".toJS).toDart;
  }

  // ==========================================================================
  // [STORAGE UC BINDING] =====================================================
  // ==========================================================================

  // TO BE DEVELOPED.

  // ==========================================================================
  // [UI UC BINDING] ==========================================================
  // ==========================================================================

  /// Configures the [CUiAppView] utilizing the [CUiAppViewConfig] objects to setup
  /// the SPA.
  void ui_app_config(CUiAppViewConfig config) {
    config._execute();
  }

  /// Handles the opening / closing of the drawer areas of the [CUiAppView].
  void ui_app_drawer({
    required CUiAppDrawerAction action,
    required bool isEndDrawer,
  }) {
    if (action == CUiAppDrawerAction.open) {
      CUiAppView.openDrawer(isEndDrawer: isEndDrawer);
    } else if (action == CUiAppDrawerAction.close) {
      CUiAppView.closeDrawer();
    }
  }

  /// Provides the ability to get items from the global app state.
  T ui_app_state_get<T>({required String key}) {
    return CUiAppView.uiState.get<T>(key: key);
  }

  /// Provides the ability to set items on the global app state.
  void ui_app_state_set<T>({required String key, required T value}) {
    CUiAppView.uiState.set<T>(key: key, value: value);
  }

  // TODO: Future instead of appRun when running full PWA the runWidget.

  /// Kicks off the running of a web applications within a runZoneGuarded
  /// so any errors during runtime are logged. Specify the webApp parameter if
  /// you have your own UI you are using or leave null if you are utilizing the
  /// [CUiAppView] construct of this module setup via the
  /// [CodeMeltedAPI.ui_app_config] method.
  void ui_app_run({
    Future<void> Function()? preInit,
    Widget? webApp,
    Future<void> Function()? postInit,
  }) {
    runZonedGuarded<Future<void>>(() async {
      // Ensure flutter is initialized.
      WidgetsFlutterBinding.ensureInitialized();

      // Do any pre-initialization
      await loadScript();
      await preInit?.call();

      // Kick-off the application.
      runApp(webApp ?? CUiAppView());

      // Do any post-initialization
      await postInit?.call();
    }, (error, stack) {
      // TODO: Run with logging
      print("$error, $stack");
    });
  }

  /// Provides the ability utilize Flutter's [BottomSheet] / [SnackBar] /
  /// [LicensePage] constructs to interact with a user. The different
  /// [DIALOG_REQUEST] actions in combination with the named parameters provide
  /// this interaction. Certain [DIALOG_REQUEST] will return values with their
  /// own close action vs. other actions where you will need to call the
  /// [DIALOG_REQUEST.close] to properly return values.
  Future<T?> ui_dialog<T>({
    required DIALOG_REQUEST action,
    Widget? appIcon,
    String? appName,
    String? appVersion,
    String? appLegalese,
    Widget? leading,
    List<Widget>? actions,
    List<String>? choices,
    String? title,
    String? message,
    Widget? content,
    double? height,
    T? returnValue,
  }) async {
    if (action == DIALOG_REQUEST.About) {
      showLicensePage(
        context: uiNavigationKey.currentContext!,
        applicationIcon: appIcon,
        applicationName: appName,
        applicationVersion: appVersion,
        applicationLegalese: appLegalese,
        useRootNavigator: true,
      );
    } else if (action == DIALOG_REQUEST.Close) {
      Navigator.of(
        uiNavigationKey.currentContext!,
        rootNavigator: true,
      ).pop(returnValue);
    } else {
      // Setup our widgets for the dialog
      var closeButton = ui_widget(
        CUiButtonWidget(
          icon: Icons.close,
          type: CUiButtonType.icon,
          title: "Close",
          onPressed: () => ui_dialog<void>(action: DIALOG_REQUEST.Close),
        ),
      );
      List<Widget>? sheetActions;
      Widget? sheetContent;
      double maxHeight = height ?? 300.0;

      // Determine the type of dialog we are going to build.
      if (action == DIALOG_REQUEST.Alert) {
        sheetContent = ui_widget(
          CUiCenterWidget(
            child: ui_widget(
              CUiContainerWidget(
                padding: EdgeInsets.all(15.0),
                child: ui_widget(
                  CUiLabelWidget(
                    data: message!,
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ),
        );
        ScaffoldMessenger.of(
          uiNavigationKey.currentContext!,
        ).showSnackBar(SnackBar(content: sheetContent));
        return null;
      } else if (action == DIALOG_REQUEST.Browser) {
        sheetActions = [closeButton];
        if (actions != null) {
          sheetActions.insertAll(0, actions);
        }
        sheetContent = ui_widget(
          CUiWebViewWidget(
            controller: CUiWebViewController(
              initialUrl: message!,
            ),
          ),
        );
      } else if (action == DIALOG_REQUEST.Choose) {
        int answer = 0;
        sheetActions = [
          ui_widget(
            CUiButtonWidget(
              type: CUiButtonType.text,
              title: "OK",
              onPressed: () => ui_dialog<int>(
                action: DIALOG_REQUEST.Close,
                returnValue: answer,
              ),
            ),
          ),
        ];

        final dropdownItems = <DropdownMenuEntry<int>>[];
        for (final (index, choices) in choices!.indexed) {
          dropdownItems.add(DropdownMenuEntry(label: choices, value: index));
        }

        sheetContent = ui_widget(
          CUiCenterWidget(
            child: ui_widget(
              CUiContainerWidget(
                padding: EdgeInsets.all(15.0),
                child: ui_widget(
                  CUiComboBoxWidget<int>(
                    width: double.maxFinite,
                    label: ui_widget(
                      CUiLabelWidget(
                        data: message ?? "",
                        softWrap: true,
                      ),
                    ),
                    dropdownMenuEntries: dropdownItems,
                    enableSearch: false,
                    initialSelection: 0,
                    onSelected: (v) {
                      answer = v!;
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (action == DIALOG_REQUEST.Confirm) {
        sheetActions = [
          ui_widget(
            CUiButtonWidget(
              type: CUiButtonType.text,
              title: "Yes",
              onPressed: () => ui_dialog<bool>(
                action: DIALOG_REQUEST.Close,
                returnValue: true,
              ),
            ),
          ),
          ui_widget(
            CUiButtonWidget(
              type: CUiButtonType.text,
              title: "No",
              onPressed: () => ui_dialog<bool>(
                action: DIALOG_REQUEST.Close,
                returnValue: true,
              ),
            ),
          ),
        ];
        sheetContent = ui_widget(
          CUiCenterWidget(
            child: ui_widget(
              CUiContainerWidget(
                padding: EdgeInsets.all(15.0),
                child: ui_widget(
                  CUiLabelWidget(
                    data: message!,
                    softWrap: true,
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (action == DIALOG_REQUEST.Custom) {
        sheetActions = actions;
        sheetContent = content!;
      } else if (action == DIALOG_REQUEST.Loading) {
        sheetContent = ui_widget(
          CUiCenterWidget(
            child: ui_widget(
              CUiContainerWidget(
                padding: EdgeInsets.all(15.0),
                child: ui_widget(
                  CUiColumnWidget(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 25.0,
                        width: 25.0,
                        child: CircularProgressIndicator(),
                      ),
                      ui_widget(CUiDividerWidget(height: 5.0)),
                      ui_widget(
                        CUiLabelWidget(
                          data: message!,
                          softWrap: true,
                          style: TextStyle(overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      } else if (action == DIALOG_REQUEST.Prompt) {
        String answer = "";
        sheetActions = [
          ui_widget(
            CUiButtonWidget(
              type: CUiButtonType.text,
              title: "OK",
              onPressed: () => ui_dialog<String>(
                action: DIALOG_REQUEST.Close,
                returnValue: answer,
              ),
            ),
          ),
        ];
        sheetContent = ui_widget(
          CUiCenterWidget(
            child: ui_widget(
              CUiContainerWidget(
                padding: EdgeInsets.all(15.0),
                child: ui_widget(
                  CUiTextFieldWidget(
                    labelText: message ?? "",
                    onChanged: (v) => answer = v,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      // Now go show the dialog as a bottom sheet to the page.
      return showModalBottomSheet<T>(
        constraints: BoxConstraints(
          maxHeight: maxHeight,
        ),
        enableDrag: false,
        isDismissible: false,
        isScrollControlled: true,
        useSafeArea: true,
        useRootNavigator: true,
        context: uiNavigationKey.currentContext!,
        builder: (context) {
          return PointerInterceptor(
            child: Scaffold(
              appBar: AppBar(
                leading: leading,
                automaticallyImplyLeading: false,
                actions: sheetActions,
                centerTitle: false,
                title: Text(title ?? action.name.toUpperCase()),
                titleSpacing: 15.0,
              ),
              body: sheetContent!,
            ),
          );
        },
      );
    }
    return null;
  }

  /// Boolean queries of the given browser runtime to discover different
  /// features about the given browser window.
  ///
  /// **Example:**
  /// ```dart
  /// var isTouchEnabled = codemelted.ui_is(IS_REQUEST.TouchEnabled);
  /// ```
  bool ui_is(IS_REQUEST request) {
    return module.callMethod<JSBoolean>("ui_is".toJS, request.name.toJS).toDart;
  }

  /// Opens the specified schema to a browser window or native app configured
  /// to handle the specified schema.
  ///
  /// **Example:**
  /// ```dart
  ///
  /// ```
  web.Window? ui_open({
    required SCHEMA schema,
    bool popupWindow = false,
    String? url,
    List<String> mailto = const [],
    List<String> cc = const [],
    List<String> bcc = const [],
    String subject = "",
    String body = "",
    TARGET target = TARGET.Blank,
    double width = 900.0,
    double height = 600.0,
  }) {
    var params = {
      "schema": schema.schema,
      "popupWindow": popupWindow,
      "url": url,
      "mailto": mailto,
      "cc": cc,
      "bcc": bcc,
      "subject": subject,
      "body": body,
      "target": target.target,
      "width": width,
      "height": height,
    };
    var result = module.callMethod<web.Window?>("ui_open".toJS, params.jsify());
    return result;
  }

  /// Creates a [ThemeData] object but it only exposes the material3 themes so
  /// that any application theming is done with the future in mind.
  ThemeData ui_theme({
    ActionIconThemeData? actionIconTheme,
    AppBarTheme? appBarTheme,
    BadgeThemeData? badgeTheme,
    MaterialBannerThemeData? bannerTheme,
    BottomAppBarTheme? bottomAppBarTheme,
    BottomNavigationBarThemeData? bottomNavigationBarTheme,
    BottomSheetThemeData? bottomSheetTheme,
    Brightness? brightness,
    ButtonThemeData? buttonTheme,
    CardThemeData? cardTheme,
    CheckboxThemeData? checkboxTheme,
    ChipThemeData? chipTheme,
    ColorScheme? colorScheme,
    DataTableThemeData? dataTableTheme,
    DatePickerThemeData? datePickerTheme,
    DividerThemeData? dividerTheme,
    DialogThemeData? dialogTheme,
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
    TabBarThemeData? tabBarTheme,
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
      dialogTheme: dialogTheme,
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

  /// Provides the ability to define [CUiWidget] objects to define a Fluter
  /// user interface. This does not prevent the use of regular Flutter widgets.
  /// It simply provides a mechanism of vetted reusable widgets for this
  /// module.
  ///
  /// **Example:**
  /// ```dart
  /// // Example building a button laid out declarative style
  /// // if you were building a UI.
  /// ui_widget(
  ///   CUiButtonWidget(
  ///     title: "POST",
  ///     type: CUiButtonType.elevated,
  ///     onPressed: () {},
  ///   ),
  /// ),
  /// ```
  Widget ui_widget(CUiWidget widget) {
    return widget._build();
  }

  // ==========================================================================
  // [SINGLETON BINDING] ======================================================
  // ==========================================================================

  /// Factory constructor for the object.
  factory CodeMeltedAPI() => _instance ?? CodeMeltedAPI._();

  /// Constructor for the object.
  CodeMeltedAPI._() {
    _instance = this;
    Future.delayed(Duration(milliseconds: 500), loadScript);
  }
}

/// Creates the namespace reference to the [CodeMeltedAPI] object.
///
/// **Example:**
/// ```
///
/// ```
var codemelted = CodeMeltedAPI();