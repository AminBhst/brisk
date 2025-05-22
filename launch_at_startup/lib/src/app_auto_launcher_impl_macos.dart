import 'dart:async';

import 'package:flutter/services.dart';
import 'package:launch_at_startup/src/app_auto_launcher.dart';

class AppAutoLauncherImplMacOS extends AppAutoLauncher {
  AppAutoLauncherImplMacOS({
    required super.appName,
    required super.appPath,
    super.args,
  });

  static const platform = MethodChannel('launch_at_startup');

  @override
  Future<bool> isEnabled() async {
    final isEnabled =
        await platform.invokeMethod<bool>('launchAtStartupIsEnabled');
    if (isEnabled == null) {
      throw Exception(
        'WARNING: AppAutoLauncherImplMacOS.isEnabled null response! platform.invokeMethod<bool>("launchAtStartupIsEnabled") returned a null response when checking if app is set to launch at startup.',
      );
    } else {
      return isEnabled;
    }
  }

  @override
  Future<bool> enable() async {
    if (!await isEnabled()) {
      await platform
          .invokeMethod('launchAtStartupSetEnabled', {'setEnabledValue': true});
    }
    return true;
  }

  @override
  Future<bool> disable() async {
    if (await isEnabled()) {
      await platform.invokeMethod(
        'launchAtStartupSetEnabled',
        {'setEnabledValue': false},
      );
    }
    return true;
  }
}
