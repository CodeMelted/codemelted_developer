import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'codemelted_flutter_platform_interface.dart';

/// An implementation of [CodemeltedFlutterPlatform] that uses method channels.
class MethodChannelCodemeltedFlutter extends CodemeltedFlutterPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('codemelted_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
