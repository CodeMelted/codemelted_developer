import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'codemelted_flutter_method_channel.dart';

abstract class CodemeltedFlutterPlatform extends PlatformInterface {
  /// Constructs a CodemeltedFlutterPlatform.
  CodemeltedFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static CodemeltedFlutterPlatform _instance = MethodChannelCodemeltedFlutter();

  /// The default instance of [CodemeltedFlutterPlatform] to use.
  ///
  /// Defaults to [MethodChannelCodemeltedFlutter].
  static CodemeltedFlutterPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [CodemeltedFlutterPlatform] when
  /// they register themselves.
  static set instance(CodemeltedFlutterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
