import 'dart:async';
import 'dart:io';
import 'package:brisk/provider/ffmpeg_installation_provider.dart';
import 'package:brisk/util/app_logger.dart';
import 'package:path/path.dart';
import 'package:brisk/widget/base/info_dialog.dart';
import 'package:brisk/widget/download/ffmpg_installation_progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FFmpeg {
  /// TODO url has latest tag
  static const String linuxInstallationUrl =
      "https://github.com/BtbN/FFmpeg-Builds/releases/download/latest/ffmpeg-n7.1-latest-linux64-gpl-7.1.tar.xz";

  static final downloadedFFmpegPath =
      '${File(Platform.resolvedExecutable).parent.path}/ffmpeg/bin/ffmpeg';

  static Future<void> _ensureExecutable() async {
    if (Platform.isWindows) {
      return;
    }
    final result = await Process.run('chmod', ['+x', downloadedFFmpegPath]);
    if (result.exitCode != 0) {
      Logger.log('chmod failed: ${result.stderr}');
    }
  }

  static Future<bool> isInstalled() async {
    try {
      //// TODO fix
      final result = await Process.run('ffmpeg', ['-version']);
      return result.exitCode == 0;
    } on ProcessException {
      try {
        await _ensureExecutable();
        final result = await Process.run(downloadedFFmpegPath, ['-version']);
        return result.exitCode == 0;
      } on ProcessException {
        return false;
      }
    }
  }

  static Future<void> install(BuildContext context) async {
    var completer = Completer();
    final provider = Provider.of<FFmpegInstallationProvider>(
      context,
      listen: false,
    );
    provider.start(onComplete: () {
      Navigator.of(context).pop();
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FfmpegInstallationProgressDialog(),
    );
    return completer.future;
  }

  /// TODO use ffmpeg without path if installed
  static Future<void> addSoftsubsToVideo(
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
    /// TODO dynamicly decide ffmpeg
    await Process.run('ffmpeg', arguments);
    print("subtitles added!");
  }
}
