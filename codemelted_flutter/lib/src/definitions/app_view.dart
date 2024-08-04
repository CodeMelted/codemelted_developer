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

import 'package:codemelted_flutter/src/definitions/data_broker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// Sets up a global navigator key for usage with dialogs rendered with the
/// codemelted_dlg_xxx functions.
final cNavigatorKey = GlobalKey<NavigatorState>();

/// Sets up a global scaffold key for opening drawers and such on the
/// codemelted_aoo_xxx functions.
final cScaffoldKey = GlobalKey<ScaffoldState>();

/// Provides the Single Page Application for the [codemelted_app] property
/// that returns the main view.
class CAppView extends StatefulWidget {
  /// Tracks if the [codemelted_app] has already been called.
  static bool _isInitialized = false;

  /// Sets up the dictionary for usage with the SPA.
  static final uiState = <String, dynamic>{
    "darkTheme": ThemeData.dark(useMaterial3: true),
    "themeMode": ThemeMode.system,
    "theme": ThemeData.light(useMaterial3: true),
  };

  /// Sets / gets the dark theme for the [codemelted_app].
  static ThemeData get darkTheme => uiState.get<ThemeData>("darkTheme");
  static set darkTheme(ThemeData? v) =>
      uiState.set<ThemeData?>("darkTheme", v, notify: true);

  /// Sets / gets the light theme for the [codemelted_app].
  static ThemeData get theme => uiState.get<ThemeData>("theme");
  static set theme(ThemeData? v) =>
      uiState.set<ThemeData?>("theme", v, notify: true);

  /// Sets / gets the theme mode for the [codemelted_app].
  static ThemeMode get themeMode => uiState.get<ThemeMode>("themeMode");
  static set themeMode(ThemeMode v) =>
      uiState.set<ThemeMode?>("themeMode", v, notify: true);

  /// Sets / gets the app title for the [codemelted_app].
  static String? get title => uiState.get<String?>("title");
  static set title(String? v) => uiState.set<String?>("title", v, notify: true);

  /// Sets / removes the header area of the [codemelted_app].
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

  /// Sets / removes the content area of the [codemelted_app].
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

  /// Sets / removes the footer area of the [codemelted_app].
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

  /// Sets / removes a floating action button for the [codemelted_app].
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

  /// Sets / removes a left sided drawer for the [codemelted_app].
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

  /// Sets / removes a right sided drawer from the [codemelted_app].
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

  /// Will programmatically close an open drawer on the [codemelted_app].
  static void closeDrawer() {
    if (cScaffoldKey.currentState!.isDrawerOpen) {
      cScaffoldKey.currentState!.closeDrawer();
    }
    if (cScaffoldKey.currentState!.isEndDrawerOpen) {
      cScaffoldKey.currentState!.closeEndDrawer();
    }
  }

  /// Will programmatically open a drawer on the [codemelted_app].
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
        key: cScaffoldKey,
      ),
    );
  }
}
