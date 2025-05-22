import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:launch_at_startup/src/app_auto_launcher.dart';
import 'package:launch_at_startup/src/app_auto_launcher_impl_linux.dart';
import 'package:launch_at_startup/src/app_auto_launcher_impl_macos.dart';
import 'package:launch_at_startup/src/app_auto_launcher_impl_noop.dart';
import 'package:launch_at_startup/src/app_auto_launcher_impl_windows.dart'
    if (dart.library.html) 'app_auto_launcher_impl_windows_noop.dart';

class LaunchAtStartup {
  LaunchAtStartup._();

  /// The shared instance of [LaunchAtStartup].
  static final LaunchAtStartup instance = LaunchAtStartup._();

  AppAutoLauncher _appAutoLauncher = AppAutoLauncherImplNoop();

  void setup({
    required String appName,
    required String appPath,
    String? packageName,
    List<String> args = const [],
  }) {
    if (!kIsWeb && Platform.isLinux) {
      _appAutoLauncher = AppAutoLauncherImplLinux(
        appName: appName,
        appPath: appPath,
        args: args,
      );
    } else if (!kIsWeb && Platform.isMacOS) {
      _appAutoLauncher = AppAutoLauncherImplMacOS(
        appName: appName,
        appPath: appPath,
        args: args,
      );
    } else if (!kIsWeb && Platform.isWindows) {
      if (packageName != null && isRunningInMsix(packageName)) {
        _appAutoLauncher = AppAutoLauncherImplWindowsMsix(
          appName: appName,
          appPath: appPath,
          packageName: packageName,
          args: args,
        );
        return;
      }
      _appAutoLauncher = AppAutoLauncherImplWindows(
        appName: appName,
        appPath: appPath,
        args: args,
      );
    }
  }

  /// Sets your app to auto-launch at startup
  Future<bool> enable() => _appAutoLauncher.enable();

  /// Disables your app from auto-launching at startup.
  Future<bool> disable() => _appAutoLauncher.disable();

  Future<bool> isEnabled() => _appAutoLauncher.isEnabled();
}

final launchAtStartup = LaunchAtStartup.instance;
