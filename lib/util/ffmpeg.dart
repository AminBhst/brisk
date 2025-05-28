import 'dart:async';
import 'dart:io';
import 'package:brisk/db/hive_util.dart';
import 'package:brisk/provider/ffmpeg_installation_provider.dart';
import 'package:brisk/util/app_logger.dart';
import 'package:brisk/util/settings_cache.dart';
import 'package:brisk/widget/base/error_dialog.dart';
import 'package:path/path.dart';
import 'package:brisk/widget/base/info_dialog.dart';
import 'package:brisk/widget/download/ffmpg_installation_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FFmpeg {
  /// TODO url has latest tag
  static const String linux_x64_InstallationUrl =
      "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2025-05-28-14-06/ffmpeg-n7.1.1-20-g9373b442a6-linux64-gpl-7.1.tar.xz";

  static const String linux_arm64_InstallationUrl =
      "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n7.1-latest-linuxarm64-gpl-7.1.tar.xz";

  static const String windowsInstallationUrl =
      "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2025-05-28-14-06/ffmpeg-n7.1.1-20-g9373b442a6-win64-gpl-7.1.zip";

  static final downloadedFFmpegPath =
      '${File(Platform.resolvedExecutable).parent.path}/ffmpeg/bin/ffmpeg';

  static bool get ignoreWarning {
    return HiveUtil.instance.generalDataBox.values
        .where((element) => element.fieldName == 'ffmpegWarningIgnore')
        .first
        .value;
  }

  static Future<void> _ensureExecutable() async {
    if (Platform.isWindows || SettingsCache.ffmpegPath == 'ffmpeg') {
      return;
    }
    final result = await Process.run('chmod', ['+x', downloadedFFmpegPath]);
    if (result.exitCode != 0) {
      Logger.log('chmod failed: ${result.stderr}');
    }
  }

  static Future<bool> isInstalled() async {
    try {
      await _ensureExecutable();
      final result = await Process.run(ffmpegPath, ['-version']);
      return result.exitCode == 0;
    } on ProcessException {
      return false;
    }
  }

  static String get ffmpegPath {
    var ffmpegPath = SettingsCache.ffmpegPath;
    if (Directory(ffmpegPath).existsSync()) {
      ffmpegPath = join(
        ffmpegPath,
        "ffmpeg${Platform.isWindows ? ".exe" : ""}",
      );
    }
    return ffmpegPath;
  }

  static Future<void> install(BuildContext context) async {
    if (Platform.isMacOS) {
      showDialog(
        context: context,
        builder: (context) => ErrorDialog(
          width: 500,
          height: 140,
          textHeight: 70,
          title: "Automatic Installation not supported",
          description: "Automatic installation is not supported for macOS.",
          descriptionHint:
          "Please install FFmpeg using Homebrew or any other package manager that offers it.",
        ),
      );
      return;
    }
    final dialogContextCompleter = Completer<BuildContext>();
    final completer = Completer<void>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        dialogContextCompleter.complete(dialogContext);
        return FfmpegInstallationProgressDialog();
      },
    );
    final installationProvider = Provider.of<FFmpegInstallationProvider>(
      context,
      listen: false,
    );
    installationProvider.start(onComplete: () async {
      final dialogContext = await dialogContextCompleter.future;
      if (Navigator.canPop(dialogContext)) {
        Navigator.of(dialogContext).pop(); // Close progress dialog
      }
      showDialog(
        context: context,
        builder: (context) => InfoDialog(
          titleText: "FFmpeg was successfully installed",
          titleIcon: Icon(Icons.done),
          titleIconBackgroundColor: Colors.lightGreen,
        ),
      );
      completer.complete();
    });
    return completer.future;
  }

  static Future<void> addSoftSubsToVideo(
    File video,
    List<File> subtitles,
  ) async {
    final arguments = [
      '-f',
      'mpegts',
      '-i',
      video.path,
    ];
    subtitles.forEach((sub) => arguments.addAll(['-i', sub.path]));
    arguments.addAll(['-map', '0:v', '-map', '0:a']);
    for (int i = 1; i <= subtitles.length; i++) {
      arguments.addAll(['-map', i.toString()]);
    }
    arguments.addAll(['-c', 'copy']);
    for (int i = 0; i < subtitles.length; i++) {
      final sub = subtitles[i];
      arguments.addAll([
        '-metadata:s:s:$i',
        'language=${basenameWithoutExtension(sub.path)}',
      ]);
    }
    final outputFileName = basenameWithoutExtension(video.path) + ".mkv";
    arguments.add('${join(video.parent.path, outputFileName)}');
    await Process.run(ffmpegPath, arguments);
  }
}
