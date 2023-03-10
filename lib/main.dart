import 'dart:convert';
import 'dart:io';

import 'package:brisk/db/hive_boxes.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/model/download_queue.dart';
import 'package:brisk/model/setting.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/provider/queue_provider.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/hot_key_util.dart';
import 'package:brisk/util/notification_util.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/download/download_grid.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:brisk/widget/queue/download_queue_list.dart';
import 'package:brisk/widget/side_menu/side_menu.dart';
import 'package:brisk/widget/top_menu/download_queue_top_menu.dart';
import 'package:brisk/widget/top_menu/queue_top_menu.dart';
import 'package:brisk/widget/top_menu/top_menu.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:window_manager/window_manager.dart';
import './util/file_util.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'util/settings_cache.dart';

void main() async {
  tz.initializeTimeZones();
  await initHive();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<DownloadRequestProvider>(
        create: (_) => DownloadRequestProvider(),
      ),
      ChangeNotifierProvider<SettingsProvider>(
        create: (_) => SettingsProvider(),
      ),
      ChangeNotifierProvider<QueueProvider>(
        create: (_) => QueueProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

Future<void> initHive() async {
  await Hive.initFlutter("Brisk");
  Hive.registerAdapter(DownloadItemAdapter());
  Hive.registerAdapter(DownloadQueueAdapter());
  Hive.registerAdapter(SettingAdapter());
  await HiveBoxes.instance.openBoxes();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brisk',
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
        HiveBoxes.instance.putInitialBoxValues().then((value) {
          SettingsCache.setCachedSettings();
        });
      });
    });
    NotificationUtil.initPlugin();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    registerDefaultDownloadAdditionHotKey(context);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
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
    final queueProvider = Provider.of<QueueProvider>(context);
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidget: FileInfoLoader(
        onCancelPressed: () => DownloadAdditionUiUtil.cancelRequest(context),
      ),
      child: Scaffold(
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
                      if (queueProvider.queueTopMenu)
                        QueueTopMenu()
                      else if (queueProvider.downloadQueueTopMenu)
                        DownloadQueueTopMenu()
                      else
                        TopMenu(),
                      if (queueProvider.selectedQueueId != null)
                        DownloadGrid()
                      else if (queueProvider.queueTabSelected)
                        DownloadQueueList()
                      else
                        DownloadGrid()
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
