import 'dart:async';
import 'dart:io';

import 'package:brisk_auto_updater/downloader/update_downloader.dart';
import 'package:brisk_auto_updater/provider/download_progress_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(580, 100),
    minimumSize: Size(580, 10),
    center: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DownloadProgressProvider>(
          create: (_) => DownloadProgressProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Timer? forceCloseTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateDownloader.installUpdate(
        context,
        onInstallComplete: relaunchBrisk,
      );
    });
  }

  void relaunchBrisk() async {
    String executablePath = Platform.resolvedExecutable;
    final briskPath = path.join(
      Directory(executablePath).parent.parent.path,
      "brisk.exe",
    );
    Process.run(briskPath, [])
        .then((_) => forceCloseTimer = Timer.periodic(
              Duration(milliseconds: 300),
              (_) {
                windowManager.destroy().then((_) => exit(0));
              },
            ))
        .then((_) => windowManager.destroy())
        .then(exit(0));
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DownloadProgressProvider>(context);
    return Scaffold(
      backgroundColor: const Color.fromRGBO(25, 25, 25, 1),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    provider.progress != 1
                        ? "Downloading update..."
                        : "Complete",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 300,
                    height: 20,
                    child: LinearProgressIndicator(
                      // color: const Color.fromRGBO(99, 130, 239, 1),
                      color: Colors.lightGreen,
                      backgroundColor: Colors.white,
                      value: provider.progress,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => UpdateDownloader.installUpdate(
                    context,
                    onInstallComplete: relaunchBrisk,
                    reset: true,
                  ),
                  icon: const Icon(
                    Icons.restart_alt_rounded,
                    color: Colors.white70,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
