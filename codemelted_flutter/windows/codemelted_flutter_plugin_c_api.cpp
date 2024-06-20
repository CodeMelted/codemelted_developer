#include "include/codemelted_flutter/codemelted_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "codemelted_flutter_plugin.h"

void CodemeltedFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  codemelted_flutter::CodemeltedFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
