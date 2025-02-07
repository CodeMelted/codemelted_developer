// ignore_for_file: camel_case_types, constant_identifier_names

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

/// Represents the Flutter SDK bindings for the CodeMelted DEV | PWA Modules.
/// Selecting this will give the construct of those SDK binding. To see
/// examples of the Flutter SDK / JavaScript SDK (plus specifics), click on
/// the CodeMelted DEV | PWA SDK button at the top of the page.
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

// ----------------------------------------------------------------------------
// [MODULE DATA DEFINITION] ---------------------------------------------------
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

/// Supports identifying the module [CodeMeltedAPI.button] widget constructed.
enum CButtonType { elevated, filled, icon, outlined, text }

/// Supports either using a custom type of bottom sheet for simple prompts
/// or building a way to get information via [CodeMeltedAPI.showBottomSheet]
/// before proceeding with the main [CodeMeltedAPI.spaContent] content.
enum CDialogType {
  alert("Attention"),
  browser("Browser"),
  choose("Make a Selection"),
  confirm("Confirm?"),
  custom(""),
  loading("Please Wait..."),
  prompt("Prompt");

  /// The default title associated with the given type.
  final String title;
  const CDialogType(this.title);
}

/// Supports identifying what module [CodeMeltedAPI.image] is constructed.
enum CImageType { asset, file, memory, network }

/// Provides theming of the regular [InputDecorationTheme] but expands to
/// the input style and other attributes of styling. Modeled off the
/// [DropdownMenuTheme] to be consistent with that control.
/// @nodoc
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

/// Enumerations set specifying the allowed actions within
/// [CodeMeltedAPI.webView] widget.
/// @nodoc
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

/// Will allow for hooking up to get resize events update to determine if a
/// change to the UI state is necessary for the SPA. Return true if you are
/// handling the resize event, false to propagate the event up the widget
/// tree.
/// @nodoc
typedef OnResizeEventHandler = bool Function(Size);

/// Identifies the scheme to utilize as part of the module open
/// function.
/// @nodoc
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
  final String scheme;

  const CSchemeType(this.scheme);
}

/// Provides the Single Page Application for the [CodeMeltedAPI.spa]
/// property that returns the main view.
/// @nodoc
class CSpaView extends StatefulWidget {
  /// Tracks if the [CodeMeltedAPI.spa] has already been called.
  static bool _isInitialized = false;

  /// Sets up the dictionary for usage with the SPA.
  static final uiState = <String, dynamic>{
    "darkTheme": ThemeData.dark(useMaterial3: true),
    "themeMode": ThemeMode.system,
    "theme": ThemeData.light(useMaterial3: true),
  };

  /// Sets / gets the ability to detect resize events with the
  /// [CodeMeltedAPI.spa] to update the main body if necessary.
  static OnResizeEventHandler? get onResizeEvent =>
      uiState.get<OnResizeEventHandler?>(key: "onResizeEvent");
  static set onResizeEvent(OnResizeEventHandler? v) =>
      uiState.set<OnResizeEventHandler?>(key: "onResizeEvent", value: v);

  /// Sets / gets the dark theme for the [CodeMeltedAPI.spa].
  static ThemeData get darkTheme => uiState.get<ThemeData>(key: "darkTheme");
  static set darkTheme(ThemeData? v) =>
      uiState.set<ThemeData?>(key: "darkTheme", value: v, notify: true);

  /// Sets / gets the light theme for the [CodeMeltedAPI.spa].
  static ThemeData get theme => uiState.get<ThemeData>(key: "theme");
  static set theme(ThemeData? v) =>
      uiState.set<ThemeData?>(key: "theme", value: v, notify: true);

  /// Sets / gets the theme mode for the [CodeMeltedAPI.spa].
  static ThemeMode get themeMode => uiState.get<ThemeMode>(key: "themeMode");
  static set themeMode(ThemeMode v) =>
      uiState.set<ThemeMode?>(key: "themeMode", value: v, notify: true);

  /// Sets / gets the app title for the [CodeMeltedAPI.spa].
  static String? get title => uiState.get<String?>(key: "title");
  static set title(String? v) =>
      uiState.set<String?>(key: "title", value: v, notify: true);

  /// Sets / removes the header area of the [CodeMeltedAPI.spa].
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

  /// Sets / removes the content area of the [CodeMeltedAPI.spa].
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

  /// Sets / removes the footer area of the [CodeMeltedAPI.spa].
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

  /// Sets / removes a floating action button for the [CodeMeltedAPI.spa].
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

  /// Sets / removes a left sided drawer for the [CodeMeltedAPI.spa].
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

  /// Sets / removes a right sided drawer from the [CodeMeltedAPI.spa].
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

  /// Will programmatically close an open drawer on the [CodeMeltedAPI.spa].
  static void closeDrawer() {
    if (CodeMeltedAPI.scaffoldKey.currentState!.isDrawerOpen) {
      CodeMeltedAPI.scaffoldKey.currentState!.closeDrawer();
    }
    if (CodeMeltedAPI.scaffoldKey.currentState!.isEndDrawerOpen) {
      CodeMeltedAPI.scaffoldKey.currentState!.closeEndDrawer();
    }
  }

  /// Will programmatically open a drawer on the [CodeMeltedAPI.spa].
  static void openDrawer({bool isEndDrawer = false}) {
    if (!isEndDrawer && CodeMeltedAPI.scaffoldKey.currentState!.hasDrawer) {
      CodeMeltedAPI.scaffoldKey.currentState!.openDrawer();
    } else if (CodeMeltedAPI.scaffoldKey.currentState!.hasEndDrawer) {
      CodeMeltedAPI.scaffoldKey.currentState!.openEndDrawer();
    }
  }

  @override
  State<StatefulWidget> createState() => _CSpaViewState();

  CSpaView({super.key}) {
    assert(
      !_isInitialized,
      "Only one CSpaView can be created. It sets up a SPA.",
    );
    _isInitialized = true;
  }
}

class _CSpaViewState extends State<CSpaView> {
  @override
  void initState() {
    CSpaView.uiState.addListener(listener: () => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      darkTheme: CSpaView.darkTheme,
      navigatorKey: CodeMeltedAPI.navigatorKey,
      theme: CSpaView.theme,
      themeMode: CSpaView.themeMode,
      title: CSpaView.title ?? "",
      home: NotificationListener<SizeChangedLayoutNotification>(
        onNotification: (notification) {
          var handler = CSpaView.onResizeEvent;
          if (handler != null) {
            return handler(MediaQuery.of(context).size);
          }
          return false;
        },
        child: Scaffold(
          appBar: CSpaView.uiState.get<AppBar?>(key: "appBar"),
          body: SizeChangedLayoutNotifier(
            child: CSpaView.uiState.get<CObject?>(key: "content")?['body'],
          ),
          extendBody:
              CSpaView.uiState.get<CObject?>(key: "content")?['extendBody'] ??
                  false,
          extendBodyBehindAppBar: CSpaView.uiState
                  .get<CObject?>(key: "content")?["extendBodyBehindAppBar"] ??
              false,
          bottomNavigationBar:
              CSpaView.uiState.get<BottomAppBar?>(key: "bottomAppBar"),
          drawer: CSpaView.uiState.get<Widget?>(key: "drawer"),
          endDrawer: CSpaView.uiState.get<Widget?>(key: "endDrawer"),
          floatingActionButton:
              CSpaView.uiState.get<Widget?>(key: "floatingActionButton"),
          floatingActionButtonLocation: CSpaView.uiState
              .get<FloatingActionButtonLocation?>(
                  key: "floatingActionButtonLocation"),
          key: CodeMeltedAPI.scaffoldKey,
        ),
      ),
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

/// Defines a tab item to utilize with the [CTabbedView] object.
/// @nodoc
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

/// TBD
/// @nodoc
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

/// The task to run as part of the different module async functions.
typedef CTask = Future<dynamic> Function([dynamic]);

/// Provides a wrapper around the Flutter ThemeData object that isolates
/// the application theming to the material3 constructs of Flutter. Extended
/// existing ThemeData objects utilized to provide a similar theming experience.
/// The theme is created via the [CodeMeltedAPI.createTheme] method.
/// @nodoc
extension ThemeDataExtension on ThemeData {
  /// Gets access to the specialized input decoration theme to pick up styles
  /// for all items that may utilize it.
  CInputDecorationTheme get cInputDecorationTheme =>
      inputDecorationTheme as CInputDecorationTheme;
}

/// The web view controller to support the [CodeMeltedAPI.webView] widget
/// creation.
/// @nodoc
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

// ----------------------------------------------------------------------------
// [Public API] ---------------------------------------------------------------
// ----------------------------------------------------------------------------

/// This module is the implementation of the CodeMelted DEV module use cases.
/// It targets the web runtime to allow for building powerful Progressive Web
/// Applications. This module is a mix of utilizing Flutter's powerful UI
/// toolkit with support from the codemelted.js module for the more JavaScript
/// Web Browser API features. See that module for more details.
class CodeMeltedAPI {
  // --------------------------------------------------------------------------
  // [Dialog Use Case] --------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Will close any open dialog via the [CodeMeltedAPI.showAboutPage],
  /// [CodeMeltedAPI.showSnackbar] or [CodeMeltedAPI.showBottomSheet] with
  /// the option to return a value if those methods allow it.
  /// @nodoc
  void closeDialog<T>([T? value]) => Navigator.of(
        navigatorKey.currentContext!,
        rootNavigator: true,
      ).pop(value);

  /// Will display the information about your flutter app to include all
  /// license information of the 3rd party plugins you utilize.
  /// @nodoc
  Future<void> showAboutPage({
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

  /// Provides a modal bottom sheet to facilitate either alerting the customer
  /// to changes in status, needing quick information, or providing the ability
  /// to utilize a custom full page by specifying the height as
  /// double.maxFinite. Each of the corresponding optional parameters support
  /// the specify [CDialogType] value. If you do not specify a proper one, an
  /// error is thrown. The return value is based on the [CDialogType] specified
  /// and works in conjunction with the [CodeMeltedAPI.closeDialog] function.
  /// @nodoc
  Future<T?> showDialog<T>({
    required CDialogType type,
    List<Widget>? actions,
    List<String>? choices,
    String? title,
    String? message,
    Widget? content,
    double? height,
  }) async {
    // Setup our widgets for the dialog
    var closeButton = uiButton(
      icon: Icons.close,
      type: CButtonType.icon,
      title: "Close",
      onPressed: closeDialog,
    );
    List<Widget>? sheetActions;
    Widget? sheetContent;
    double maxHeight = height ?? 300.0;

    // Determine the type of dialog we are going to build.
    if (type == CDialogType.alert) {
      sheetActions = [closeButton];
      sheetContent = uiCenter(
        child: uiContainer(
          padding: EdgeInsets.all(15.0),
          child: uiLabel(
            data: message!,
            softWrap: true,
          ),
        ),
      );
    } else if (type == CDialogType.browser) {
      sheetActions = [closeButton];
      sheetContent = uiWebView(
        controller: CWebViewController(
          initialUrl: message!,
        ),
      );
    } else if (type == CDialogType.choose) {
      int answer = 0;
      sheetActions = [
        uiButton(
          type: CButtonType.text,
          title: "OK",
          onPressed: () => closeDialog<int>(answer),
        ),
      ];

      final dropdownItems = <DropdownMenuEntry<int>>[];
      for (final (index, choices) in choices!.indexed) {
        dropdownItems.add(DropdownMenuEntry(label: choices, value: index));
      }

      sheetContent = uiCenter(
        child: uiContainer(
          padding: EdgeInsets.all(15.0),
          child: uiComboBox<int>(
            width: double.maxFinite,
            label: uiLabel(data: message ?? "", softWrap: true),
            dropdownMenuEntries: dropdownItems,
            enableSearch: false,
            initialSelection: 0,
            onSelected: (v) {
              answer = v!;
            },
          ),
        ),
      );
    } else if (type == CDialogType.confirm) {
      sheetActions = [
        uiButton(
          type: CButtonType.text,
          title: "Yes",
          onPressed: () => closeDialog<bool>(true),
        ),
        uiButton(
          type: CButtonType.text,
          title: "No",
          onPressed: () => closeDialog<bool>(false),
        ),
      ];
      sheetContent = uiCenter(
        child: uiContainer(
          padding: EdgeInsets.all(15.0),
          child: uiLabel(
            data: message!,
            softWrap: true,
          ),
        ),
      );
    } else if (type == CDialogType.custom) {
      sheetActions = actions;
      sheetContent = content!;
    } else if (type == CDialogType.loading) {
      sheetContent = uiCenter(
        child: uiContainer(
          padding: EdgeInsets.all(15.0),
          child: uiColumn(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 25.0,
                width: 25.0,
                child: CircularProgressIndicator(),
              ),
              uiDivider(height: 5.0),
              uiLabel(
                data: message!,
                softWrap: true,
                style: TextStyle(overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      );
    } else if (type == CDialogType.prompt) {
      String answer = "";
      sheetActions = [
        uiButton(
          type: CButtonType.text,
          title: "OK",
          onPressed: () => closeDialog<String>(answer),
        ),
      ];
      sheetContent = uiCenter(
        child: uiContainer(
          padding: EdgeInsets.all(15.0),
          child: uiTextField(
            labelText: message ?? "",
            onChanged: (v) => answer = v,
          ),
        ),
      );
    }

    // Now go show the dialog as a bottom sheet to the page.
    return showModalBottomSheet(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
      ),
      enableDrag: false,
      isDismissible: false,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      context: navigatorKey.currentContext!,
      builder: (context) {
        return PointerInterceptor(
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              actions: sheetActions,
              centerTitle: false,
              title: Text(title ?? type.title),
              titleSpacing: 15.0,
            ),
            body: sheetContent!,
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // [JSON Use Case] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Converts the given string data to a bool or null if not of that type.
  bool? asBool({required String data}) => data.asBool();

  /// Converts the given string data to a double or null if not of that type.
  double? asDouble({required String data}) => data.asDouble();

  /// Converts the given string data to a int or null if not of that type.
  int? asInt({required String data}) => data.asInt();

  /// Determines if a [CObject] has a given property contained within.
  bool checkHasProperty({required CObject obj, required String key}) {
    return obj.containsKey(key);
  }

  /// Determines if the variable is of the expected type.
  bool checkType<T>({required dynamic data}) {
    return data is T;
  }

  /// Determines if the data type is a valid URL.
  bool checkValidUrl({required String data}) {
    return Uri.tryParse(data) != null;
  }

  /// Creates a new CArray object and initializes it if initData is specified.
  CArray createArray({CArray? data}) {
    return data != null ? data.copy() : [];
  }

  /// Creates a new CObject object and initializes it if initData is specified.
  CObject createObject({CObject? data}) {
    return data != null ? CObject.from(data) : CObject();
  }

  /// Will convert data into a JSON [CObject] or return null if the decode
  /// could not be achieved.
  CObject? parse({required String data}) {
    return data.asObject();
  }

  /// Will encode the JSON [CObject] into a string or null if the encode
  /// could not be achieved.
  String? stringify({required CObject data}) {
    return data.stringify();
  }

  /// Same as [checkHasProperty] but throws an exception if the key
  /// is not found.
  void tryHasProperty({required CObject obj, required String key}) {
    if (!checkHasProperty(obj: obj, key: key)) {
      throw "obj does not contain specified key";
    }
  }

  /// Same as [checkType] but throws an exception if not of the
  /// expected type.
  void tryType<T>({required dynamic data}) {
    if (!checkType<T>(data: data)) {
      throw "variable was not of an expected type.'";
    }
  }

  /// Same as [checkValidUrl] but throws an exception if not a valid
  /// URL type.
  void tryValidUrl({required String data}) {
    if (!checkValidUrl(data: data)) {
      throw "data was not a valid URL string";
    }
  }

  // --------------------------------------------------------------------------
  // [Runtime Use Case] -------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Provides the ability to load either a JavaScript ES6 module or a WASM
  /// into the codemelted.dart environment.
  /// @nodoc
  Future<JSObject?> importJSModule({
    required String moduleUrl,
  }) async {
    try {
      return importModule(moduleUrl.toJS).toDart;
    } catch (err) {
      // TODO: How to signal error.
      return null;
    }
  }

  /// Will load a WASM module into the flutter web context. Returns null if
  /// unable to be loaded.
  /// @nodoc
  Future<web.WebAssemblyInstantiatedSource?> importWASM(String url) async {
    try {
      return (web.WebAssembly.instantiateStreaming(
        web.window.fetch(url.toJS),
      ).toDart);
    } catch (err) {
      // TODO: How to signal error.
      return null;
    }
  }

  // --------------------------------------------------------------------------
  // [SPA Use Case] -----------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Determines if the SPA is an installed PWA or not.
  bool get isPWA {
    assert(
      _codemeltedJsModule != null,
      "codemelted.js Module not initialized.",
    );
    return _codemeltedJsModule!
        .getProperty<JSBoolean>(
          "isPWA".toJS,
        )
        .toDart;
  }

  /// Determines if the flutter app is running in a touch enabled environment.
  bool get isTouchEnabled {
    assert(
      _codemeltedJsModule != null,
      "codemelted.js Module not initialized.",
    );
    return _codemeltedJsModule!
        .getProperty<JSBoolean>(
          "isTouchEnabled".toJS,
        )
        .toDart;
  }

  /// Accesses a Single Page Application (SPA) for the overall module. This
  /// is called after being configured via the appXXX functions in the runApp
  /// of the main().
  /// @nodoc
  Widget get spa {
    return CSpaView();
  }

  /// Sets the [CodeMeltedAPI.spa] dark theme.
  /// @nodoc
  set spaDarkTheme(ThemeData? v) {
    CSpaView.darkTheme = v;
  }

  /// Sets the [CodeMeltedAPI.spa] light theme.
  /// @nodoc
  set spaTheme(ThemeData? v) {
    CSpaView.theme = v;
  }

  /// Sets the [CodeMeltedAPI.spa] theme mode.
  /// @nodoc
  set spaThemeMode(ThemeMode v) {
    CSpaView.themeMode = v;
  }

  /// Sets / removes the [CodeMeltedAPI.spa] title.
  /// @nodoc
  set spaTitle(String? v) {
    CSpaView.title = v;
  }

  String? get spaTitle {
    return CSpaView.title;
  }

  /// Sets up the ability to detect resize events with the SPA.
  /// @nodoc
  set onResizeEvent(OnResizeEventHandler? v) {
    CSpaView.onResizeEvent = v;
  }

  // TBD
  // @nodoc
  void openScheme({
    required CSchemeType scheme,
    bool popupWindow = false,
    String? mailtoParams,
    String? url,
    String target = "_blank",
    double? width,
    double? height,
  }) {
    assert(
      _codemeltedJsModule != null,
      "codemelted.js Module not initialized.",
    );
    var params = <String, dynamic>{
      "scheme": scheme.scheme,
      "popupWindow": popupWindow,
      "mailtoParams": mailtoParams,
      "url": url,
      "target": target,
      "width": width,
      "height": height,
    }.jsify();
    _codemeltedJsModule!.callMethod("open".toJS, params);
  }

  /// Sets / removes the [CodeMeltedAPI.spa] header area.
  /// @nodoc
  void spaHeader({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    CSpaView.header(
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      forceMaterialTransparency: forceMaterialTransparency,
      leading: leading,
      style: style,
      title: title,
    );
  }

  /// Sets / removes the [CodeMeltedAPI.spa] content area.
  /// @nodoc
  void spaContent({
    required Widget? body,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
  }) {
    CSpaView.content(
      body: body,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
    );
  }

  /// Sets / removes the [CodeMeltedAPI.spa] footer area.
  /// @nodoc
  void spaFooter({
    List<Widget>? actions,
    bool automaticallyImplyLeading = true,
    bool forceMaterialTransparency = false,
    Widget? leading,
    AppBarTheme? style,
    Widget? title,
  }) {
    CSpaView.footer(
      actions: actions,
      automaticallyImplyLeading: automaticallyImplyLeading,
      forceMaterialTransparency: forceMaterialTransparency,
      leading: leading,
      style: style,
      title: title,
    );
  }

  /// Sets / removes the [CodeMeltedAPI.spa] floating action button.
  /// @nodoc
  void spaFloatingActionButton({
    Widget? button,
    FloatingActionButtonLocation? location,
  }) {
    CSpaView.floatingActionButton(button: button, location: location);
  }

  /// Sets / removes the [CodeMeltedAPI.spa] drawer.
  /// @nodoc
  void spaDrawer({Widget? header, List<Widget>? items}) {
    CSpaView.drawer(header: header, items: items);
  }

  /// Sets / removes the [CodeMeltedAPI.spa] end drawer.
  /// @nodoc
  void spaEndDrawer({Widget? header, List<Widget>? items}) {
    CSpaView.endDrawer(header: header, items: items);
  }

  /// Closes the [CodeMeltedAPI.spa] drawer or end drawer.
  /// @nodoc
  void spaCloseDrawer() {
    CSpaView.closeDrawer();
  }

  /// Opens the [CodeMeltedAPI.spa] drawer or end drawer.
  /// @nodoc
  void spaOpenDrawer({bool isEndDrawer = false}) {
    CSpaView.openDrawer(isEndDrawer: isEndDrawer);
  }

  /// Provides the ability to get items from the global app state.
  /// @nodoc
  T getSpaState<T>({required String key}) {
    return CSpaView.uiState.get<T>(key: key);
  }

  /// Provides the ability to set items on the global app state.
  /// @nodoc
  void setSpaState<T>({required String key, required T value}) {
    CSpaView.uiState.set<T>(key: key, value: value);
  }

  /// Retrieves the total height of the specified context.
  /// @nodoc
  double spaHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Retrieves the available width of the specified context.
  /// @nodoc
  double spaWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // --------------------------------------------------------------------------
  // [Task Use Case] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Holds the mapping of timer objects of repeating tasks.
  final _data = <int, dynamic>{};

  /// The currently held timer id.
  int _timerId = 0;

  /// Runs a task and returns any calculated results. Can be scheduled into
  /// the future if necessary if delay is specified.
  /// @nodoc
  Future<dynamic> runTask({
    required CTask task,
    dynamic data,
    int delay = 0,
  }) async {
    assert(delay > 0, "delay specified must be greater than 0.");
    return Future.delayed(
      Duration(milliseconds: (delay < 0 ? 0 : delay)),
      () => task(data),
    );
  }

  /// Starts a repeating [CTask] on the specified interval.
  /// @nodoc
  int startTimer({required CTask task, required int interval}) {
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
  /// @nodoc
  void stopTimer({required int timerId}) {
    assert(_data.containsKey(timerId), "timerId was not found.");
    (_data[timerId] as Timer).cancel();
    _data.remove(timerId);
  }

  /// Will allow for a delay in an asynchronous function.
  /// @nodoc
  Future<void> sleepTask({required int delay}) async {
    assert(delay >= 0, "delay specified must be greater than 0.");
    return Future.delayed(Duration(milliseconds: delay));
  }

  // --------------------------------------------------------------------------
  // [Theme Use Case] ---------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Creates a ThemeData object but it only exposes the material3 themes so
  /// that any application theming is done with the future in mind.
  /// @nodoc
  ThemeData createTheme({
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

  // --------------------------------------------------------------------------
  // [Widget Use Case] --------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Will construct a stateless button to handle press events of said button.
  /// The button is determined via the [CButtonType] enumeration which will
  /// provide the look and feel of the button. The style is handled by that
  /// particular buttons theme data object but to set the button individually,
  /// utilize the style override. These are stateless buttons so any changing
  /// of them is up to the parent.
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
  Widget uiExpansionTile({
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
  /// @nodoc
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
  /// @nodoc
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

  /// Will create an image widget based on the specified [CImageType]
  /// enumerated value and display it when available based on the
  /// characteristics specified with the widget. No theme controls this widget
  /// type so the characteristics are unique to each widget created.
  /// @nodoc
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
  /// it if to long.
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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
  /// @nodoc
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

  // --------------------------------------------------------------------------
  // [API Setup] --------------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Will hold the last error encountered by the module.
  String? error;

  /// Sets up a global navigator key for usage with dialogs rendered with the
  /// [CodeMeltedAPI] dialog functions.
  static final navigatorKey = GlobalKey<NavigatorState>();

  /// Sets up a global scaffold key for opening drawers and such on the
  /// [CodeMeltedAPI.spa] functions.
  static final scaffoldKey = GlobalKey<ScaffoldState>();

  /// The NPU module location when compiling a codemelted_developer flutter
  /// module with the WASM / PWA resources that support utilizing those assets
  /// within this module.
  /// @nodoc
  static const codemeltedJsModuleUrl =
      "/assets/packages/codemelted_developer/pwa/codemelted.js";

  /// Holds the reference to the codemelted.js module for hooking up logic that
  /// their is no direct dart / flutter implementation that is better.
  JSObject? _codemeltedJsModule;

  /// Handles errors within the module to expose it via the [CodeMeltedAPI]
  /// namespace.
  // ignore: unused_element
  void _handleError(dynamic ex, StackTrace? st) {
    error = st is String
        ? "$ex\n${st?.toString()}"
        : "${ex.toString()}\n${st?.toString()}";
  }

  /// Initializes module assets that support the flutter codemelted.dart
  /// for flutter web PwA development.
  Future<bool> init({
    String codemeltedJsModuleUrl = CodeMeltedAPI.codemeltedJsModuleUrl,
  }) async {
    try {
      var now = DateTime.now().millisecond;
      _codemeltedJsModule = (await importJSModule(
        moduleUrl: "$codemeltedJsModuleUrl?t=$now",
      ))
          ?.getProperty("default".toJS);
      return _codemeltedJsModule != null;
    } catch (ex, st) {
      _handleError(ex, st);
      return false;
    }
  }

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
