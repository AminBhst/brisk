import 'dart:async';
import 'dart:io';
import 'package:brisk/db/migration_manager.dart';
import 'package:brisk/util/app_logger.dart';
import 'package:brisk/util/auto_updater_util.dart';
import 'package:brisk/browser_extension/browser_extension_server.dart';
import 'package:brisk/constants/app_closure_behaviour.dart';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/provider/download_request_provider.dart';
import 'package:brisk/provider/pluto_grid_check_row_provider.dart';
import 'package:brisk/provider/queue_provider.dart';
import 'package:brisk/provider/settings_provider.dart';
import 'package:brisk/provider/theme_provider.dart';
import 'package:brisk/theme/application_theme_holder.dart';
import 'package:brisk/util/database_migration.dart';
import 'package:brisk/util/download_addition_ui_util.dart';
import 'package:brisk/util/hot_key_util.dart';
import 'package:brisk/util/launch_at_startup_util.dart';
import 'package:brisk/util/notification_manager.dart';
import 'package:brisk/util/tray_util.dart';
import 'package:brisk/widget/base/app_exit_dialog.dart';
import 'package:brisk/widget/base/global_context.dart';
import 'package:brisk/widget/download/download_grid.dart';
import 'package:brisk/widget/loader/file_info_loader.dart';
import 'package:brisk/widget/queue/download_queue_list.dart';
import 'package:brisk/widget/side_menu/side_menu.dart';
import 'package:brisk/widget/top_menu/download_queue_top_menu.dart';
import 'package:brisk/widget/top_menu/queue_top_menu.dart';
import 'package:brisk/widget/top_menu/top_menu.dart';
import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'util/file_util.dart';
import 'util/settings_cache.dart';

// TODO Fix resizing the window when a row is selected
void main() {
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Logger.init();
      FlutterError.onError = (FlutterErrorDetails details) {
        print('Flutter Error: ${details.exceptionAsString()}');
        print(details.stack);
        FlutterError.presentError(details);
        Logger.log(details.exceptionAsString());
        Logger.log(details.stack);
        Logger.log(details.exception);
      };
      await migrateDatabaseLocation();
      await windowManager.ensureInitialized();
      tz.initializeTimeZones();
      await HiveUtil.instance.initHive();
      await setupLaunchAtStartup();
      await FileUtil.setDefaultTempDir();
      await FileUtil.setDefaultSaveDir();
      await HiveUtil.instance.putInitialBoxValues();
      await MigrationManager.runMigrations();
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
              create: (_) =>
                  DownloadRequestProvider(PlutoGridCheckRowProvider()),
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
    },
    (error, stack) {
      print('Unhandled error caught by runZonedGuarded: $error');
      print(stack);
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: globalContext,
      debugShowCheckedModeBanner: false,
      title: 'Brisk',
      theme: ThemeData(
        fontFamily: 'Segoe UI',
        useMaterial3: false,
        dialogTheme: DialogThemeData(backgroundColor: Colors.transparent),
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
          windowManager.setSkipTaskbar(true);
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
    NotificationManager.init();
    windowManager.addListener(this);
    windowManager.setPreventClose(true);
    trayManager.addListener(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HotKeyUtil.registerDefaultDownloadAdditionHotKey(context);
      if (Platform.isMacOS) {
        HotKeyUtil.registerMacOsDefaultWindowHotkeys();
      }
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
  void onTrayIconMouseDown() async {
    var isMinimized = await windowManager.isMinimized();
    var isVisible = await windowManager.isVisible();
    var isSkippingTaskbar = await windowManager.isSkipTaskbar();

    if (Platform.isMacOS && (isMinimized || !isVisible || isSkippingTaskbar)) {
       if (isSkippingTaskbar) {
         await windowManager.setSkipTaskbar(false);
       }
       await windowManager.show();
       windowManager.focus();
     }
    super.onTrayIconMouseDown();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
    super.onTrayIconRightMouseDown();
  }

  @override
  Future<void> onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.setSkipTaskbar(false);
      await windowManager.show();
      windowManager.focus();
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
