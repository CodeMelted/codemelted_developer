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

/// Represents the Flutter SDK bindings for the CodeMelted DEV | Modules.
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

/// Supports identifying what module [CodeMeltedAPI.image] is constructed.
enum CImageType { asset, file, memory, network }

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
/// [CodeMeltedAPI.uiWebView] widget.
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
typedef OnResizeEventHandler = bool Function(Size);

/// Provides the Single Page Application for the [CodeMeltedAPI.spa]
/// property that returns the main view.
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

// TODO: Create custom theme to add other items to reflect tab style like other
//       matieral3 widgets.

/// Creates a [CodeMeltedAPI.uiTabbedView] StatefulWidget to display a tabbed
/// interface of content for the [CodeMeltedAPI.spaContent] view.
class CTabbedView extends StatefulWidget {
  /// The list of [CTabItem] definitions of the tabbed content.
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

/// The task to run as part of the [CodeMeltedAPI.task] function.
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

/// This module is the implementation of the CodeMelted DEV Flutter module
/// use cases. It targets the web runtime to allow for building powerful
/// Progressive Web Applications. This module is a mix of utilizing Flutter's
/// powerful UI toolkit with support from the codemelted.js / codemelted.wasm
/// modules to facilitate common logic utilizing the Web Browser API features
/// with no specific Flutter implementation.
class CodeMeltedAPI {
  // --------------------------------------------------------------------------
  // [Async IO Use Cases] -----------------------------------------------------
  // --------------------------------------------------------------------------

  /// The [CodeMeltedAPI.task] provides asynchronous processing of [CTask]
  /// function requests. This allows for scheduling work for later processing
  /// on the Flutter main event loop. This may or may not return a value.
  /// Also is the ability to repeat task on a timer and eventually stop it.
  /// Finally one can simple sleep between asynchronous tasks. The supported
  /// actions are run / start_timer / stop_timer / sleep.
  dynamic task({
    required String action,
    required CTask task,
    dynamic data,
    int delay = 0,
  }) {
    assert(delay >= 0, "delay must be >= 0 for task function");

    if (action == "run") {
      return Future.delayed(
        Duration(milliseconds: delay),
        () => task(data),
      );
    } else if (action == "sleep") {
      return Future.delayed(Duration(milliseconds: delay));
    } else if (action == "start_timer") {
      var timer = Timer.periodic(
        Duration(milliseconds: delay),
        (timer) {
          task();
        },
      );
      _trackerId += 1;
      _objectTracker[_trackerId] = timer;
      return _trackerId;
    } else if (action == "stop_timer") {
      assert(data is int, "data must be an int to support stop_timer action");
      (_objectTracker[data] as Timer).cancel();
      _objectTracker.remove(data);
    }
    throw FormatException("task() received invalid action. Valid actions "
        "are run / sleep / start_timer / stop_timer");
  }

  // TODO: Worker use case facilitated by codemelted.cpp functions.

  // --------------------------------------------------------------------------
  // [Data Use Cases] ---------------------------------------------------------
  // --------------------------------------------------------------------------

  // TODO: database function hooked into codemelted.cpp

  /// The [CodeMeltedAPI.dataCheck] provides the ability to validate the
  /// dynamic data type, whether a CObject has a given property key, and if
  /// a URL is valid or not. This is returned as a bool but can also throw
  /// a string error if the check fails. The valid actions are has_property /
  /// type / url.
  bool dataCheck<T>({
    required String action,
    dynamic data,
    String? key,
    bool shouldThrow = false,
  }) {
    var valid = false;
    if (action == "has_property") {
      valid = (data as CObject).containsKey(key);
    } else if (action == "type") {
      valid = data is T;
    } else if (action == "url") {
      valid = Uri.tryParse(data) != null;
    } else {
      throw FormatException("dataCheck received invalid action. Valid actions "
          "are has_property / create_object / parse / stringify");
    }

    if (shouldThrow && !valid) {
      throw "$action failed data check";
    }
    return valid;
  }

  // TODO: disk function hooked into codemelted.cpp

  // TODO: file function hooked into codemelted.cpp

  /// The [CodeMeltedAPI.json] provides the ability to create objects that
  /// are JSON compliant along with parsing and stringifying those objects.
  /// The supported actions are create_array / create_object / parse /
  /// stringify. The returned value is either CArray / CObject / String /
  /// null if the conversion cannot be done. The data object provides the
  /// optional ability to copy data when creating or performing the parsing /
  /// stringifying.
  dynamic json({required String action, dynamic data}) {
    if (action == "create_array") {
      return data != null ? data.copy() : [];
    } else if (action == "create_object") {
      return data != null ? CObject.from(data) : CObject();
    } else if (action == "parse") {
      return (data as String?)?.asObject();
    } else if (action == "stringify") {
      return (data as CObject?)?.stringify();
    }
    throw FormatException("json received invalid action. Valid actions are "
        "create_array / create_object / parse / stringify");
  }

  // TODO: storage function hooked into codemelted.cpp

  /// The [CodeMeltedAPI.stringParse] provides the ability to convert string
  /// data into different object types. The supported actions are array / bool
  /// / double / int / object. If the conversion fails a null is returned.
  dynamic stringParse({required String action, required String data}) {
    if (action == "array") {
      return data.asArray();
    } else if (action == "bool") {
      return data.asBool();
    } else if (action == "double") {
      return data.asDouble();
    } else if (action == "int") {
      return data.asInt();
    } else if (action == "object") {
      return data.asObject();
    }
    throw FormatException("stringParse received invalid action. Valid actions "
        "are array / bool / double / int / object");
  }

  // TODO: xml function hooked into codemelted.cpp

  // --------------------------------------------------------------------------
  // [NPU Use Cases] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  // TODO: Compute use case via codemelted.js / .wasm

  // TODO: Math use case via codemelted.js / .wasm

  // TODO: Memory use case via codemelted.js / .wasm

  // --------------------------------------------------------------------------
  // [SDK Use Cases] ----------------------------------------------------------
  // --------------------------------------------------------------------------

  // TODO: events use case via codemelted.js / .wasm

  // TODO: logger use case via codemelted.js / .wasm

  // TODO: hardware use case via codemelted.js / .wasm

  // TODO: network use case via codemelted.js / .wasm

  // TODO: orientation use case via codemelted.js / .wasm

  /// The [CodeMeltedAPI.runtime] provides a queryable set of properties along
  /// with one off actions carried out by a SPA within the web runtime.
  /// Supported actions are is_pwa / is_touch_enabled.
  dynamic runtime({required String action}) {
    // TODO: Update codemelted.js / .wasm binding names
    if (action == "is_pwa") {
      return web.window.callMethod<JSBoolean>("codemelted_is_pwa".toJS).toDart;
    } else if (action == "is_touch_enabled") {
      return web.window
          .callMethod<JSBoolean>("codemelted_is_touch_enabled".toJS)
          .toDart;
    }

    throw FormatException("runtime() received invalid action. Valid actions "
        "are is_pwa / is_touch_enabled");
  }

  /// The [CodeMeltedAPI.schema] provides the ability to utilize desktop
  /// services (i.e. mobile / desktop / browser) based on the specified schema
  /// and support parameters. This will attempt to open the desktop service
  /// associated with the schema. The supported schemas are 'file:' / 'http://'
  /// 'https://' / 'mailto:' / 'tel:' / 'sms:'
  web.Window? schema({
    required String schema,
    bool popupWindow = false,
    String? mailtoParams,
    String? url,
    String target = "_blank",
    double? width,
    double? height,
  }) {
    var params = <String, dynamic>{
      "schema": schema,
      "popupWindow": popupWindow,
      "mailtoParams": mailtoParams,
      "url": url,
      "target": target,
      "width": width,
      "height": height,
    }.jsify();
    // TODO: Update codemelted.js / .wasm binding names
    return web.window.callMethod<web.Window?>(
      "codemelted_open_schema".toJS,
      params,
    );
  }

  // TODO: share use case via codemelted.js / .wasm

  // TODO: webrtc use case via codemelted.js / .wasm

  // --------------------------------------------------------------------------
  // [User Interface Use Cases] -----------------------------------------------
  // --------------------------------------------------------------------------

  // TODO: audio use case via codemelted.js / .wasm

  /// The [CodeMeltedAPI.dialog] provides the ability display information about
  /// the develop SPA by supplying the appXXXX parameters or utilize a bottom
  /// modal sheet for simple prompts to full page actions with the other
  /// parameters. Eventually one can utilize the close action with custom /
  /// loading types to return custom values. This is an asynchronous call
  /// allowing for the dialog display and returned answer. The supported types
  /// are about / alert / browser / choose / close / confirm / custom /
  /// loading / prompt.
  Future<T?> dialog<T>({
    required String type,
    Widget? appIcon,
    String? appName,
    String? appVersion,
    String? appLegalese,
    List<Widget>? actions,
    List<String>? choices,
    String? title,
    String? message,
    Widget? content,
    double? height,
    T? returnValue,
  }) async {
    if (type == "about") {
      showLicensePage(
        context: navigatorKey.currentContext!,
        applicationIcon: appIcon,
        applicationName: appName,
        applicationVersion: appVersion,
        applicationLegalese: appLegalese,
        useRootNavigator: true,
      );
    } else if (type == "close") {
      Navigator.of(
        navigatorKey.currentContext!,
        rootNavigator: true,
      ).pop(returnValue);
    } else {
      // Setup our widgets for the dialog
      var closeButton = uiButton(
        icon: Icons.close,
        type: CButtonType.icon,
        title: "Close",
        onPressed: () => dialog<void>(type: "close"),
      );
      List<Widget>? sheetActions;
      Widget? sheetContent;
      double maxHeight = height ?? 300.0;

      // Determine the type of dialog we are going to build.
      if (type == "alert") {
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
      } else if (type == "browser") {
        sheetActions = [closeButton];
        sheetContent = uiWebView(
          controller: CWebViewController(
            initialUrl: message!,
          ),
        );
      } else if (type == "choose") {
        int answer = 0;
        sheetActions = [
          uiButton(
            type: CButtonType.text,
            title: "OK",
            onPressed: () => dialog<int>(type: "close", returnValue: answer),
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
      } else if (type == "confirm") {
        sheetActions = [
          uiButton(
            type: CButtonType.text,
            title: "Yes",
            onPressed: () => dialog<bool>(type: "close", returnValue: true),
          ),
          uiButton(
            type: CButtonType.text,
            title: "No",
            onPressed: () => dialog<bool>(type: "close", returnValue: true),
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
      } else if (type == "custom") {
        sheetActions = actions;
        sheetContent = content!;
      } else if (type == "loading") {
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
      } else if (type == "prompt") {
        String answer = "";
        sheetActions = [
          uiButton(
            type: CButtonType.text,
            title: "OK",
            onPressed: () => dialog<String>(type: "close", returnValue: answer),
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
      } else {
        throw FormatException("dialog() received invalid type. Valid "
            "types are about / alert / browser / choose / close / confirm / "
            "custom / loading / prompt");
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
        context: navigatorKey.currentContext!,
        builder: (context) {
          return PointerInterceptor(
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                actions: sheetActions,
                centerTitle: false,
                title: Text(title ?? type.toUpperCase()),
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

  // TODO: gamepad use case via codemelted.js / .wasm

  /// Accesses a Single Page Application (SPA) for the overall module. This
  /// is called after being configured via the appXXX functions in the runApp
  /// of the main().
  Widget get spa {
    return CSpaView();
  }

  /// Sets the [CodeMeltedAPI.spa] dark theme.
  set spaDarkTheme(ThemeData? v) {
    CSpaView.darkTheme = v;
  }

  /// Sets the [CodeMeltedAPI.spa] light theme.
  set spaTheme(ThemeData? v) {
    CSpaView.theme = v;
  }

  /// Sets the [CodeMeltedAPI.spa] theme mode.
  set spaThemeMode(ThemeMode v) {
    CSpaView.themeMode = v;
  }

  /// Sets / removes the [CodeMeltedAPI.spa] title.
  set spaTitle(String? v) {
    CSpaView.title = v;
  }

  String? get spaTitle {
    return CSpaView.title;
  }

  /// Sets up the ability to detect resize events with the SPA.
  set onResizeEvent(OnResizeEventHandler? v) {
    CSpaView.onResizeEvent = v;
  }

  /// Sets / removes the [CodeMeltedAPI.spa] header area.
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
  void spaFloatingActionButton({
    Widget? button,
    FloatingActionButtonLocation? location,
  }) {
    CSpaView.floatingActionButton(button: button, location: location);
  }

  /// Sets / removes the [CodeMeltedAPI.spa] drawer.
  void spaDrawer({Widget? header, List<Widget>? items}) {
    CSpaView.drawer(header: header, items: items);
  }

  /// Sets / removes the [CodeMeltedAPI.spa] end drawer.
  void spaEndDrawer({Widget? header, List<Widget>? items}) {
    CSpaView.endDrawer(header: header, items: items);
  }

  /// Closes the [CodeMeltedAPI.spa] drawer or end drawer.
  void spaCloseDrawer() {
    CSpaView.closeDrawer();
  }

  /// Opens the [CodeMeltedAPI.spa] drawer or end drawer.
  void spaOpenDrawer({bool isEndDrawer = false}) {
    CSpaView.openDrawer(isEndDrawer: isEndDrawer);
  }

  /// Provides the ability to get items from the global app state.
  T getSpaState<T>({required String key}) {
    return CSpaView.uiState.get<T>(key: key);
  }

  /// Provides the ability to set items on the global app state.
  void setSpaState<T>({required String key, required T value}) {
    CSpaView.uiState.set<T>(key: key, value: value);
  }

  /// Retrieves the total height of the specified context.
  double spaHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Retrieves the available width of the specified context.
  double spaWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Creates a ThemeData object but it only exposes the material3 themes so
  /// that any application theming is done with the future in mind.
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
  /// it if to long.
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

  // --------------------------------------------------------------------------
  // [API Setup] --------------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Holds the tracking of objects created by the module where a
  /// [CodeMeltedAPI._trackerId] is returned as a handle to facilitate work.
  final _objectTracker = <int, dynamic>{};

  /// The current tracker id to support the [CodeMeltedAPI._trackerId].
  int _trackerId = 0;

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
      "/assets/packages/codemelted_developer/assets/cpp/codemelted.js";

  /// Handles errors within the module to expose it via the [CodeMeltedAPI]
  /// namespace.
  // ignore: unused_element
  void _handleError(dynamic ex, StackTrace? st) {
    error = st is String
        ? "$ex\n${st?.toString()}"
        : "${ex.toString()}\n${st?.toString()}";
  }

  /// Initializes module assets that support the flutter codemelted.dart
  /// for flutter web PWA development.
  Future<bool> init({
    String codemeltedJsModuleUrl = CodeMeltedAPI.codemeltedJsModuleUrl,
  }) async {
    try {
      var now = DateTime.now().millisecond;
      await importModule(
        "$codemeltedJsModuleUrl?t=$now".toJS,
      ).toDart;
      await Future.delayed(Duration(milliseconds: 250));
      return web.window.has("codemelted");
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
