import 'package:launch_at_startup/src/app_auto_launcher.dart';

class AppAutoLauncherImplNoop extends AppAutoLauncher {
  AppAutoLauncherImplNoop() : super(appName: '', appPath: '');

  @override
  Future<bool> isEnabled() async {
    throw UnsupportedError('isEnabled');
  }

  @override
  Future<bool> enable() async {
    throw UnsupportedError('enable');
  }

  @override
  Future<bool> disable() async {
    throw UnsupportedError('disable');
  }
}
