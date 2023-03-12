import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:windows_notification/notification_message.dart';
import 'package:windows_notification/windows_notification.dart';

class NotificationUtil {
  static final FlutterLocalNotificationsPlugin flnPlugin =
  FlutterLocalNotificationsPlugin();
  static final _winNotifyPlugin = WindowsNotification(applicationId: "Brisk");

  static const downloadCompletionHeader = "Download Complete";
  static const downloadFailureHeader = "Download Failed!";

  static void initPlugin() async {
    const LinuxInitializationSettings linuxInitSettings =
    LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    const DarwinInitializationSettings darwinInitSettings =
    DarwinInitializationSettings(
    );
    await flnPlugin.initialize(
      const InitializationSettings(linux: linuxInitSettings, macOS: darwinInitSettings),
    );
  }

  static void showNotification(String header, String body) async {
    final id = Random().nextInt(100);
    if (Platform.isLinux || Platform.isMacOS) {
      const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();
      const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();
      const NotificationDetails notificationDetails = NotificationDetails(
        linux: linuxDetails,
        macOS: darwinDetails,
      );
      await flnPlugin.show(
        id,
        header,
        body,
        notificationDetails,
      );
    } else if (Platform.isWindows) {
      NotificationMessage message = NotificationMessage.fromPluginTemplate(
        id.toString(),
        header,
        body,
      );
      _winNotifyPlugin.showNotificationPluginTemplate(message);
    }
  }
}
