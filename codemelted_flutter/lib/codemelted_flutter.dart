
import 'codemelted_flutter_platform_interface.dart';

class CodemeltedFlutter {
  Future<String?> getPlatformVersion() {
    return CodemeltedFlutterPlatform.instance.getPlatformVersion();
  }
}
