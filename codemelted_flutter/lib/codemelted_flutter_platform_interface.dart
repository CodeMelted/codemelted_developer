import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'codemelted_flutter_method_channel.dart';

abstract class CodeMeltedFlutterPlatform extends PlatformInterface {
  /// Constructs a CodeMeltedFlutterPlatform.
  CodeMeltedFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static CodeMeltedFlutterPlatform _instance = MethodChannelCodeMeltedFlutter();

  /// The default instance of [CodeMeltedFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelCodeMeltedFlutter].
  static CodeMeltedFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CodeMeltedFlutterPlatform] when
  /// they register themselves.
  static set instance(CodeMeltedFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
