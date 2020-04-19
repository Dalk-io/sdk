import 'package:cli_pkg/cli_pkg.dart' as pkg;
import 'package:grinder/grinder.dart';

/// Generate a JS version of the library
/// doesn't work for now as we need to add some JS interop operation to be compatible
void main(List<String> args) {
  pkg.name = 'bot-name';
  pkg.humanName = 'My App';
  pkg.executables = {};
  pkg.jsModuleMainLibrary = 'lib/sdk_interop.dart';
  pkg.addNpmTasks();
  grind(args);
}

/*
command that actually work to compile
dart2js -Dnode=false -Dversion=1.0.0 -Ddart-version=2.8.0-dev.18.0.flutter-eea9717938 -obuild/dalk-sdk.dart.js build/dalk-sdk_npm.dart
 */
