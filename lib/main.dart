import 'dart:io';
import 'package:brisk/util/auto_updater_util.dart';
import 'package:brisk/widget/other/brisk_change_log_dialog.dart';
import 'package:flutter_emoji/flutter_emoji.dart';
import 'package:brisk/browser_extension//browser_extension_server.dart';
import 'package:brisk/constants/app_closure_behaviour.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/pluto_grid_check_row_provider.dart';
import 'package:brisk/provider/queue_provider.dart';
import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/theme/application_theme_holder.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/hot_key_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:brisk/util/launch_at_startup_util.dart';
import 'package:brisk/util/notification_util.dart';
import 'package:brisk/widget/base/app_exit_dialog.dart';
import 'package:brisk/widget/base/confirmation_dialog.dart';
import 'package:brisk/widget/download/download_grid.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:brisk/widget/queue/download_queue_list.dart';
import 'package:brisk/widget/side_menu/side_menu.dart';
import 'package:brisk/widget/top_menu/download_queue_top_menu.dart';
import 'package:brisk/widget/top_menu/queue_top_menu.dart';
import 'package:brisk/widget/top_menu/top_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tray_manager/tray_manager.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

import 'util/file_util.dart';
import 'util/settings_cache.dart';

// TODO add current version in settings
// TODO Fix resizing the window when a row is selected
// TODO handle stop all button availability as well as download and stop buttons in queue top menu
/// TODO fix assemble file called multiple times, ending up with multiple files
/// TODO Remove logs for succeeding downloads
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  tz.initializeTimeZones();
  await HiveUtil.instance.initHive();
  await setupLaunchAtStartup();
  await FileUtil.setDefaultTempDir();
  await FileUtil.setDefaultSaveDir();
  await HiveUtil.instance.putInitialBoxValues();
  await SettingsCache.setCachedSettings();
  await updateLaunchAtStartupSetting();
  ApplicationThemeHolder.setActiveTheme();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
        ChangeNotifierProvider<QueueProvider>(
          create: (_) => QueueProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<PlutoGridCheckRowProvider>(
          create: (_) => PlutoGridCheckRowProvider(),
        ),
        ChangeNotifierProxyProvider<PlutoGridCheckRowProvider,
            DownloadRequestProvider>(
          create: (_) => DownloadRequestProvider(PlutoGridCheckRowProvider()),
          update: (context, plutoProvider, downloadProvider) {
            if (downloadProvider == null) {
              return DownloadRequestProvider(plutoProvider);
            } else {
              downloadProvider.plutoProvider = plutoProvider;
              return downloadProvider;
            }
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brisk',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with WindowListener, TrayListener {
  @override
  void onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();
    if (!mounted || !isPreventClose) return;
    switch (SettingsCache.appClosureBehaviour) {
      case AppClosureBehaviour.ask:
        showAppClosureDialog();
        break;
      case AppClosureBehaviour.minimizeToTray:
        initTray();
        windowManager.hide();
        break;
      case AppClosureBehaviour.exit:
        windowManager.destroy().then((_) => exit(0));
        break;
    }
  }

  void showAppClosureDialog() {
    showDialog(
      context: context,
      builder: (_) => AppExitDialog(
        onExitPressed: (rememberChecked) async {
          Navigator.of(context).pop();
          if (rememberChecked) {
            await saveNewAppClosureBehaviour(AppClosureBehaviour.exit);
          }
          windowManager.destroy().then((_) => exit(0));
        },
        onMinimizeToTrayPressed: (rememberChecked) {
          if (rememberChecked) {
            saveNewAppClosureBehaviour(AppClosureBehaviour.minimizeToTray);
          }
          initTray();
          windowManager.hide();
        },
      ),
    );
  }

  Future<void> saveNewAppClosureBehaviour(AppClosureBehaviour behaviour) async {
    SettingsCache.appClosureBehaviour = behaviour;
    await SettingsCache.saveCachedSettingsToDB();
  }

  @override
  void initState() {
    NotificationUtil.initPlugin();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
    trayManager.addListener(this);
    super.initState();
  }

  void initTray() {
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Window',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
        ),
      ],
    );
    trayManager
        .setIcon(
          Platform.isWindows
              ? 'assets/icons/logo.ico'
              : 'assets/icons/logo.png',
        )
        .then((_) => trayManager.setContextMenu(menu));
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      registerDefaultDownloadAdditionHotKey(context);
      BrowserExtensionServer.setup(context);
      handleBriskUpdateCheck(context);
    });
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
    super.dispose();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
    super.onTrayIconRightMouseDown();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    if (menuItem.key == 'show_window') {
      windowManager.show();
    } else if (menuItem.key == 'exit_app') {
      windowManager.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final queueProvider = Provider.of<QueueProvider>(context);
    return LoaderOverlay(
      overlayWidgetBuilder: (progress) => FileInfoLoader(
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
                  SideMenu(),
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
