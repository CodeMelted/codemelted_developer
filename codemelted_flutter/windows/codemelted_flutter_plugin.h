#ifndef FLUTTER_PLUGIN_CODEMELTED_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_CODEMELTED_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace codemelted_flutter {

class CodeMeltedFlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  CodeMeltedFlutterPlugin();

  virtual ~CodeMeltedFlutterPlugin();

  // Disallow copy and assign.
  CodeMeltedFlutterPlugin(const CodeMeltedFlutterPlugin&) = delete;
  CodeMeltedFlutterPlugin& operator=(const CodeMeltedFlutterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace codemelted_flutter

#endif  // FLUTTER_PLUGIN_CODEMELTED_FLUTTER_PLUGIN_H_
