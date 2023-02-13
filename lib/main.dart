import 'dart:convert';
import 'dart:io';

import 'package:brisk/db/db_provider.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/util/notification_util.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/download/download_grid.dart';
import 'package:brisk/widget/side_menu/side_menu.dart';
import 'package:brisk/widget/top_menu/top_menu.dart';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import './util/file_util.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:window_size/window_size.dart';

import 'util/settings_cache.dart';

void main() {
  tz.initializeTimeZones();
  setWindowTitle("Brisk");
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DownloadRequestProvider>(
        create: (_) => DownloadRequestProvider(),
      ),
      ChangeNotifierProvider<SettingsProvider>(
        create: (_) => SettingsProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brisk',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WindowListener {
  final AppWindow appWindow = AppWindow();

  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (!mounted) return;
    if (isPreventClose) {
      showDialog(
        context: context,
        builder: (_) => ConfirmationDialog(
          title: "Are you sure you want to exit Brisk?",
          onConfirmPressed: () {
            Navigator.of(context).pop();
            windowManager.destroy();
          },
        ),
      );
    }
  }

  @override
  void initState() {
    // startExtensionServer();
    FileUtil.setDefaultTempDir().then((value) {
      FileUtil.setDefaultSaveDir().then((value) {
        DBProvider.instance.getDB(init: true).then((_) {
          SettingsCache.setCachedSettings();
        });
      });
    });
    NotificationUtil.initPlugin();
    initSystemTray();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> initSystemTray() async {
    String path =
    Platform.isWindows ? 'assets/icons/logo.svg' : 'assets/app_icon.png';

    final AppWindow appWindow = AppWindow();
    final SystemTray systemTray = SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
      title: "system tray",
      iconPath: path,
    );

    // create context menu
    final Menu menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(label: 'Show', onClicked: (menuItem) => appWindow.show()),
      MenuItemLabel(label: 'Hide', onClicked: (menuItem) => appWindow.hide()),
      MenuItemLabel(label: 'Exit', onClicked: (menuItem) => appWindow.close()),
    ]);

    // set context menu
    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? appWindow.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : appWindow.show();
      }
    });
  }

  void startExtensionServer() async {
    var server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
    await for (var request in server) {
      request.listen((event) async {
        var json = jsonDecode(String.fromCharCodes(event));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromRGBO(40, 46, 58, 1),
      backgroundColor: Colors.black26,
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SideMenu(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TopMenu(),
                    DownloadGrid(),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
