import 'dart:io';

import 'package:launch_at_startup/src/app_auto_launcher.dart';

class AppAutoLauncherImplLinux extends AppAutoLauncher {
  AppAutoLauncherImplLinux({
    required super.appName,
    required super.appPath,
    super.args,
  });

  File get _desktopFile {
    final homePath = Platform.environment.containsKey('SNAP')
        ? Platform.environment['SNAP_REAL_HOME']
        : Platform.environment['HOME'];
    return File(
      '$homePath/.config/autostart/$appName.desktop',
    );
  }

  @override
  Future<bool> isEnabled() async {
    return _desktopFile.existsSync();
  }

  @override
  Future<bool> enable() async {
    String contents = '''
[Desktop Entry]
Type=Application
Name=$appName
Comment=$appName startup script
Exec=${args.isEmpty ? appPath : '$appPath ${args.join(' ')}'}
StartupNotify=false
Terminal=false
''';
    if (!_desktopFile.parent.existsSync()) {
      _desktopFile.parent.createSync(recursive: true);
    }
    _desktopFile.writeAsStringSync(contents);
    return true;
  }

  @override
  Future<bool> disable() async {
    if (_desktopFile.existsSync()) {
      _desktopFile.deleteSync();
    }
    return true;
  }
}
