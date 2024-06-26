#include "include/codemelted_flutter/codemelted_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "codemelted_flutter_plugin.h"

void CodeMeltedFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  codemelted_flutter::CodeMeltedFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
