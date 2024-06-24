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

/// A collection of extensions, utility functions, and objects with a minimum
/// set dart / flutter package dependencies. Allows for you to leverage the raw
/// power of flutter to build your cross platform applications for all
/// available flutter targets.
library codemelted_flutter;

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:codemelted_flutter/src/codemelted_flutter_platform_interface.dart';
import 'package:codemelted_flutter/src/definitions/app_view.dart';
import 'package:codemelted_flutter/src/definitions/async_io.dart';
import 'package:codemelted_flutter/src/definitions/audio_player.dart';
import 'package:codemelted_flutter/src/definitions/data_broker.dart';
import 'package:codemelted_flutter/src/definitions/fetch.dart';
import 'package:codemelted_flutter/src/definitions/link_opener.dart';
import 'package:codemelted_flutter/src/definitions/logger.dart';
import 'package:codemelted_flutter/src/definitions/math.dart';
import 'package:codemelted_flutter/src/definitions/themes.dart';
import 'package:codemelted_flutter/src/definitions/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher_string.dart';

export 'package:codemelted_flutter/src/definitions/async_io.dart';
export 'package:codemelted_flutter/src/definitions/audio_player.dart';
export 'package:codemelted_flutter/src/definitions/data_broker.dart';
export 'package:codemelted_flutter/src/definitions/fetch.dart';
export 'package:codemelted_flutter/src/definitions/link_opener.dart';
export 'package:codemelted_flutter/src/definitions/logger.dart';
export 'package:codemelted_flutter/src/definitions/math.dart';
export 'package:codemelted_flutter/src/definitions/themes.dart';
export 'package:codemelted_flutter/src/definitions/widgets.dart';

/// Say something cool
class CodeMeltedFlutter {
  // --------------------------------------------------------------------------
  // [App View Definitions] ---------------------------------------------------
  // --------------------------------------------------------------------------

  /// Accesses a Single Page Application (SPA) for the overall module. This
  /// is called after being configured via the appXXX functions in the runApp
  /// of the main().
  Widget get app {
    return CAppView();
  }

  /// Sets the [CodeMeltedFlutter.app] dark theme.
  set appDarkTheme(ThemeData? v) {
    CAppView.darkTheme = v;
  }

  /// Sets the [CodeMeltedFlutter.app] light theme.
  set appTheme(ThemeData? v) {
    CAppView.theme = v;
  }

  /// Sets the [CodeMeltedFlutter.app] theme mode.
  set appThemeMode(ThemeMode v) {
    CAppView.themeMode = v;
  }

  /// Sets / removes the [CodeMeltedFlutter.app] title.
  set appTitle(String? v) {
    CAppView.title = v;
  }

  String? get appTitle {
    return CAppView.title;
  }

  /// Sets / removes the [CodeMeltedFlutter.app] header area.
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

  /// Sets / removes the [CodeMeltedFlutter.app] content area.
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

  /// Sets / removes the [CodeMeltedFlutter.app] footer area.
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

  /// Sets / removes the [CodeMeltedFlutter.app] floating action button.
  void appFloatingActionButton({
    Widget? button,
    FloatingActionButtonLocation? location,
  }) {
    CAppView.floatingActionButton(button: button, location: location);
  }

  /// Sets / removes the [CodeMeltedFlutter.app] drawer.
  void appDrawer({Widget? header, List<Widget>? items}) {
    CAppView.drawer(header: header, items: items);
  }

  /// Sets / removes the [CodeMeltedFlutter.app] end drawer.
  void appEndDrawer({Widget? header, List<Widget>? items}) {
    CAppView.endDrawer(header: header, items: items);
  }

  /// Closes the [CodeMeltedFlutter.app] drawer or end drawer.
  void appCloseDrawer() {
    CAppView.closeDrawer();
  }

  /// Opens the [CodeMeltedFlutter.app] drawer or end drawer.
  void appOpenDrawer({bool isEndDrawer = false}) {
    CAppView.openDrawer(isEndDrawer: isEndDrawer);
  }

  /// Provides the ability to get items from the global app state.
  T getAppState<T>(String key) {
    return CAppView.uiState.get<T>(key);
  }

  /// Provides the ability to set items on the global app state.
  void setAppState<T>(String key, T value) {
    CAppView.uiState.set<T>(key, value);
  }

  // --------------------------------------------------------------------------
  // [Async IO Definition] ----------------------------------------------------
  // --------------------------------------------------------------------------

  /// Will sleep an asynchronous task for the specified delay in milliseconds.
  Future<void> asyncSleep(int delay) async {
    return (await Future.delayed(Duration(milliseconds: delay)));
  }

  /// Will process a one off asynchronous task either on the main flutter thread
  /// or in a background isolate. The isBackground is only supported on native
  /// and mobile platforms.
  Future<dynamic> asyncTask({
    required CAsyncTask task,
    dynamic data,
    int delay = 0,
    bool isBackground = false,
  }) async {
    assert(
      !kIsWeb && isBackground,
      "background processing is only available on native platforms",
    );

    if (isBackground) {
      return (await Isolate.run<dynamic>(() => task(data)));
    }

    return (
      await Future.delayed(
        Duration(milliseconds: delay),
        () => task(data),
      ),
    );
  }

  /// Kicks off a timer to schedule tasks on the thread for which it is created
  /// calling the task on the interval specified in milliseconds.
  Timer asyncTimer({
    required CAsyncTask task,
    required int interval,
  }) {
    assert(interval > 0, "interval specified must be greater than 0.");
    return Timer.periodic(
      Duration(milliseconds: interval),
      (timer) {
        task();
      },
    );
  }

  /// @nodoc
  CAsyncWorker asyncWorker({
    required CAsyncWorkerListener listener,
    required dynamic config,
  }) {
    // if (config is CIsolateConfig) {
    //   return platform.createIsolate(listener: listener, config: config);
    // } else if (config is CProcessConfig) {
    //   return platform.createProcess(listener: listener, config: config);
    // } else if (config is CWorkerConfig) {
    //   return platform.createWorker(listener: listener, config: config);
    // }
    throw "CodeMeltedFlutter.asyncWorker: did not receive a supported "
        "configuration object";
  }

  // --------------------------------------------------------------------------
  // [Audio Player Definition] ------------------------------------------------
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
    return CAudioPlayer(player, audioSource);
  }

  /// Builds a [CAudioPlayer] to perform text-to-speech of the specified data.
  Future<CAudioPlayer> audioTTS({
    required String data,
    double volume = 0.5,
    double pitch = 1.0,
    double rate = 1.0,
    FlutterTts? mock,
  }) async {
    final player = mock ?? FlutterTts();
    await player.setPitch(pitch);
    await player.setVolume(volume);
    await player.setSpeechRate(rate);
    player.setErrorHandler((message) {
      if (message.toString().containsIgnoreCase("interrupted")) {
        return;
      }
      logError(data: message, st: StackTrace.current);
    });
    return CAudioPlayer(player, data);
  }

  // --------------------------------------------------------------------------
  // [Console] ----------------------------------------------------------------
  // --------------------------------------------------------------------------

  // Console is not applicable to flutter as it is a widget based library.

  // --------------------------------------------------------------------------
  // [Database Definition] ----------------------------------------------------
  // --------------------------------------------------------------------------

  // TBD

  // --------------------------------------------------------------------------
  // [Data Broker Definitions] ------------------------------------------------
  // --------------------------------------------------------------------------

  /// Determines if a [CObject] has a given property contained within.
  bool checkHasProperty(CObject obj, String key) {
    return obj.containsKey(key);
  }

  /// Determines if the variable is of the expected type.
  bool checkType<T>(dynamic v) {
    return v is T;
  }

  /// Determines if the data type is a valid URL.
  bool checkValidUrl(String v) {
    return Uri.tryParse(v) != null;
  }

  /// Will convert data into a JSON [CObject] or return null if the decode
  /// could not be achieved.
  CObject? jsonParse(String data) {
    return data.asObject();
  }

  /// Will encode the JSON [CObject] into a string or null if the encode
  /// could not be achieved.
  String? jsonStringify(CObject data) {
    return data.stringify();
  }

  /// Same as [checkHasProperty] but throws an exception if the key
  /// is not found.
  void tryHasProperty(CObject obj, String key) {
    if (!checkHasProperty(obj, key)) {
      throw "obj does not contain '$key' key";
    }
  }

  /// Same as [checkType] but throws an exception if not of the
  /// expected type.
  void tryType<T>(dynamic v) {
    if (!checkType<T>(v)) {
      throw "variable was not of type '$T'";
    }
  }

  /// Same as [checkValidUrl] but throws an exception if not a valid
  /// URL type.
  void tryValidUrl(String v) {
    if (!checkValidUrl(v)) {
      throw "v was not a valid URL string";
    }
  }

  // --------------------------------------------------------------------------
  // [Device Orientation Definition] ------------------------------------------
  // --------------------------------------------------------------------------

  // TBD

  // --------------------------------------------------------------------------
  // [Dialog Definition] ------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Internal tracking variable to properly handle browser display within
  /// rounded borders or the other types of dialogs.
  bool _isBrowserAction = false;

  /// The default height for a medium dialog.
  static const _smallHeight = 256.0;

  /// The default width for a medium dialog.
  static const _smallWidth = 320.0;

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
      _platform.openWebBrowser(
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
      content: uiWebView(CWebViewController.create(url: url)),
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
  /// [CodeMeltedFlutter.dlgClose] for returning values via your actions array.
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
  /// is important you call [codemelted_dlg_close] to properly clear the
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

  // --------------------------------------------------------------------------
  // [Disk Manager Definition] ------------------------------------------------
  // --------------------------------------------------------------------------

  // TBD

  // --------------------------------------------------------------------------
  // [Fetch Definitions] ------------------------------------------------------
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
  // [Hardware Device Definition] ---------------------------------------------
  // --------------------------------------------------------------------------

  // TBD

  // --------------------------------------------------------------------------
  // [Link Opener Definition] -------------------------------------------------
  // --------------------------------------------------------------------------

  /// Utilizes available desktop services to open te specified scheme protocol
  /// url link.
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
  // [Logger Definitions] -----------------------------------------------------
  // --------------------------------------------------------------------------

  /// Sets up the internal logger for the module.
  final _logger = Logger("CodeMelted-Logger");

  /// Sets / gets the [CLogLevel] of the codemelted_flutter module logging
  /// facility.
  set logLevel(CLogLevel v) {
    Logger.root.level = v.level;
  }

  CLogLevel get logLevel {
    return CLogLevel.values.firstWhere(
      (element) => element.level == Logger.root.level,
    );
  }

  /// Establishes the [CLogEventHandler] to facilitate post log processing
  /// of a codemelted_flutter module logged event.
  CLogEventHandler? onLoggedEvent;

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

  // --------------------------------------------------------------------------
  // [Math Definition] --------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Runs the specified [CMathFormula] with the specified variables returning
  /// the calculated result.
  double math({
    required CMathFormula formula,
    required List<double> vars,
  }) {
    return formula.calculate(vars);
  }

  // --------------------------------------------------------------------------
  // [Network Socket Definition] ----------------------------------------------
  // --------------------------------------------------------------------------

  // TBD

  // --------------------------------------------------------------------------
  // [Runtime Definition] -----------------------------------------------------
  // --------------------------------------------------------------------------

  /// Copies data to the system clipboard
  Future<void> copyToClipboard(String data) async {
    return Clipboard.setData(ClipboardData(text: data));
  }

  /// Will search for the specified environment variable returning null if not
  /// found.
  String? environment(String key) => _platform.environment(key);

  /// Determines if the application is a PWA. Will only return true if the
  /// app is a web targeted app and installed as a PWA.
  bool get isPWA => _platform.isPWA;

  // --------------------------------------------------------------------------
  // [Share Definition] -------------------------------------------------------
  // --------------------------------------------------------------------------

  // TBD

  // --------------------------------------------------------------------------
  // [Storage Definition] -----------------------------------------------------
  // --------------------------------------------------------------------------

  // TBD

  // --------------------------------------------------------------------------
  // [Themes Definitions] -----------------------------------------------------
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
    SnackBarThemeData? snackBarTheme,
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
      snackBarTheme: snackBarTheme,
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
  // [Web RTC Definition] -----------------------------------------------------
  // --------------------------------------------------------------------------

  // TBD

  // --------------------------------------------------------------------------
  // [Widget Definition] ------------------------------------------------------
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
      leading: leading is IconData ? Icon(leading) : leading,
      initiallyExpanded: false,
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
    EdgeInsetsGeometry? iconMargin,
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
          iconMargin: iconMargin,
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
  Widget uiWebView(CWebViewController controller) {
    return _platform.createWebView(controller);
  }

  /// Retrieves the available width of the specified context.
  double uiWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Future<String?> getPlatformVersion() {
  //   return CodeMeltedFlutterPlatform.instance.getPlatformVersion();
  // }

  // --------------------------------------------------------------------------
  // [API Setup] --------------------------------------------------------------
  // --------------------------------------------------------------------------

  /// Holds the singular instance of the API.
  static CodeMeltedFlutter? _instance;

  /// Factory constructor to support the [codemelted] namespace setup.
  factory CodeMeltedFlutter() => _instance ?? CodeMeltedFlutter._();

  /// Hold a reference to the platform runtime for native target methods.
  final _platform = CodeMeltedFlutterPlatform.instance;

  /// Private constructor so no-one can construct another instance of this API.
  CodeMeltedFlutter._() {
    _instance = this;
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
    Logger.root.level = CLogLevel.warning.level;
    Logger.root.onRecord.listen((v) {
      var record = CLogRecord(v);
      if (kDebugMode || kIsWeb) {
        if (_platform.environment('FLUTTER_TEST') == null) {
          // ignore: avoid_print
          print(record);
        }
      }

      if (onLoggedEvent != null) {
        onLoggedEvent!(record);
      }
    });
  }
}

/// Sets up a namespace object to access the [CodeMeltedFlutter] main API.
final codemelted = CodeMeltedFlutter();
