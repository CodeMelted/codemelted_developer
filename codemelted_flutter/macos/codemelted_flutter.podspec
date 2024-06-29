#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint codemelted_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'codemelted_flutter'
  s.version          = '0.0.0'
  s.summary          = 'Welcome to the CodeMelted - Flutter Module project. This project aims to provide a developer with the ability to build client applications regardless of deployment target. Those deployment targets include desktop, mobile, and web. By leveraging the CodeMelted - Developer identified use cases, you can be assured to building a powerful native application.''
  s.description      = <<-DESC
Welcome to the CodeMelted - Flutter Module project. This project aims to provide a developer with the ability to build client applications regardless of deployment target. Those deployment targets include desktop, mobile, and web. By leveraging the CodeMelted - Developer identified use cases, you can be assured to building a powerful native application.'
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mark Shaffer' => 'mark.shaffer@codemelted.com' }

  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.11'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
