import 'package:launch_at_startup/src/app_auto_launcher_impl_noop.dart';

bool isRunningInMsix(String packageName) {
  return false;
}

class AppAutoLauncherImplWindows extends AppAutoLauncherImplNoop {
  AppAutoLauncherImplWindows({
    required String appName,
    required String appPath,
    List<String> args = const [],
  }) : super();
}

class AppAutoLauncherImplWindowsMsix extends AppAutoLauncherImplNoop {
  AppAutoLauncherImplWindowsMsix({
    required String appName,
    required String appPath,
    required String packageName,
    List<String> args = const [],
  }) : super();
}
