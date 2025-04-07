import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationManager {
  static final FlutterLocalNotificationsPlugin flnPlugin =
      FlutterLocalNotificationsPlugin();
  static const downloadCompletionHeader = "Download Complete";
  static const downloadFailureHeader = "Download Failed!";

  static void init() async {
    const LinuxInitializationSettings linuxInitSettings =
        LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );
    const DarwinInitializationSettings darwinInitSettings =
        DarwinInitializationSettings();
    const WindowsInitializationSettings windowsInitSettings =
        WindowsInitializationSettings(
      appName: 'Brisk',
      appUserModelId: 'aminbhst.brisk',
      guid: '0e55ea0a-de5b-4d9a-97d8-3349aef0d9ca',
    );
    await flnPlugin.initialize(
      const InitializationSettings(
        linux: linuxInitSettings,
        macOS: darwinInitSettings,
        windows: windowsInitSettings,
      ),
    );
  }

  static void showNotification(String header, String body) async {
    final id = Random().nextInt(100);
    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();
    const WindowsNotificationDetails windowsDetails =
        WindowsNotificationDetails();
    const DarwinNotificationDetails darwinDetails = DarwinNotificationDetails();
    const NotificationDetails notificationDetails = NotificationDetails(
        linux: linuxDetails, macOS: darwinDetails, windows: windowsDetails);
    await flnPlugin.show(
      id,
      header,
      body,
      notificationDetails,
    );
  }
}
