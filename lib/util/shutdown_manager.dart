import 'dart:async';
import 'dart:io';

import 'package:brisk/util/notification_manager.dart';
import 'package:brisk/widget/base/shutdown_warning_dialog.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_to_front/window_to_front.dart';
import 'package:brisk/widget/base/global_context.dart';

class ShutdownManager {
  static Timer? _shutdownTimer;

  static void scheduleShutdown() async {
    await windowManager.show();
    await windowManager.focus();
    await WindowToFront.activate();
    NotificationManager.showNotification(
      "Scheduled Shutdown",
      "Your PC will shut down in 1 minute. Open Brisk to cancel the shutdown.",
    );
    _shutdownTimer ??= Timer.periodic(
      Duration(minutes: 1),
      (_) => shutdownNow(),
    );
    showDialog(
      barrierDismissible: false,
      context: globalContext.currentState!.context,
      builder: (context) => ShutdownWarningDialog(
        onShutdownNowPressed: shutdownNow,
        onCancelShutdownPressed: () {
          _shutdownTimer?.cancel();
          _shutdownTimer = null;
        },
      ),
    );
  }

  static void shutdownNow() async {
    if (Platform.isWindows) {
      await Process.run('shutdown', ['/s', '/t', '0']);
    } else if (Platform.isLinux) {
      await Process.run('shutdown', ['-h', 'now']);
    } else if (Platform.isMacOS) {
      await Process.run(
        'osascript',
        ['-e', 'tell app "System Events" to shut down'],
      );
    }
  }
}
