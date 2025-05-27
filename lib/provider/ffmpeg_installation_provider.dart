import 'dart:io';
import 'package:archive/archive.dart';
import 'package:brisk/util/download_engine_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:brisk/model/download_item.dart';
import 'package:brisk/util/ffmpeg.dart';
import 'package:brisk_download_engine/brisk_download_engine.dart';
import 'package:flutter/material.dart';

Future<void> extractTarXzIsolate(String filePath, String outputDir) async {
  final file = File(filePath);
  final inputBytes = await file.readAsBytes();
  final tarBytes = XZDecoder().decodeBytes(inputBytes);
  final archive = TarDecoder().decodeBytes(tarBytes);

  for (final archiveFile in archive) {
    if (archiveFile.name.trim().isEmpty) continue;

    final unixParts = archiveFile.name.split('/');
    final strippedPath = unixParts.length > 1
        ? unixParts.sublist(1).join(Platform.pathSeparator)
        : unixParts.first;
    final outPath = join(outputDir, strippedPath);

    if (archiveFile.isFile) {
      final outFile = File(outPath);
      await outFile.create(recursive: true);
      await outFile.writeAsBytes(archiveFile.content as List<int>);
    } else {
      await Directory(outPath).create(recursive: true);
    }
  }
}

Future<void> extractTarXzCompute(Map<String, String> args) async {
  await extractTarXzIsolate(args['filePath']!, args['outputDir']!);
}

class FFmpegInstallationProvider with ChangeNotifier {
  DownloadProgressMessage? progress;

  void start({Function? onComplete}) async {
    final downloadItem = DownloadItem.fromUrl(installationUrl);
    Directory ffmpegDir = Directory(
      join(File(Platform.resolvedExecutable).parent.path, "ffmpeg"),
    );
    downloadItem.filePath = join(
      File(Platform.resolvedExecutable).parent.path,
      "ffmpeg.tar.xz",
    );
    if (File(downloadItem.filePath).existsSync()) {
      File(downloadItem.filePath).deleteSync();
    }
    if (ffmpegDir.existsSync()) {
      ffmpegDir.deleteSync();
    }
    final fileInfo = await requestFileInfo(downloadItem, null);
    downloadItem.contentLength = fileInfo!.contentLength;
    downloadItem.supportsPause = fileInfo.supportsPause;
    final downloadItemModel = buildFromDownloadItem(downloadItem);
    DownloadEngine.start(
      downloadItemModel,
      downloadSettingsFromCache(),
      downloadItemModel.downloadType,
      onButtonAvailability: (_) {},
      onDownloadProgress: (progress) async {
        this.progress = progress;
        if (progress.status == DownloadStatus.assembling ||
            progress.status == DownloadStatus.validatingFiles) {
          this.progress!.status = "Finalizing...";
        } else if (progress.status == DownloadStatus.assembleComplete) {
          this.progress!.status = "Finalizing...";
          await extractFFmpegCompute(downloadItem);
          File(downloadItem.filePath).deleteSync();
          onComplete?.call();
        } else {
          this.progress!.status = "Downloading FFmpeg...";
        }
        notifyListeners();
      },
    );
  }

  Future<void> extractFFmpegCompute(DownloadItem downloadItem) async {
    await compute(
      extractTarXzCompute,
      {
        'filePath': downloadItem.filePath,
        'outputDir': join(
          File(Platform.resolvedExecutable).parent.path,
          "ffmpeg",
        ),
      },
    );
  }

  void extractTarXz(DownloadItem downloadItem) {
    final file = File(downloadItem.filePath);
    final inputBytes = file.readAsBytesSync();
    final tarBytes = XZDecoder().decodeBytes(inputBytes);
    final archive = TarDecoder().decodeBytes(tarBytes);
    final baseOutputDir = join(
      File(Platform.resolvedExecutable).parent.path,
      "ffmpeg",
    );
    for (int i = 0; i < archive.length; i++) {
      final archiveFile = archive[i];
      if (archiveFile.name.trim().isEmpty) continue;
      final unixParts = archiveFile.name.split('/');
      final strippedPath = unixParts.length > 1
          ? unixParts.sublist(1).join(Platform.pathSeparator)
          : unixParts.first;
      final outPath = join(baseOutputDir, strippedPath);
      if (archiveFile.isFile) {
        final outFile = File(outPath);
        outFile.createSync(recursive: true);
        outFile.writeAsBytesSync(archiveFile.content as List<int>);
      } else {
        Directory(outPath).createSync(recursive: true);
      }
    }
  }

  String get installationUrl {
    if (Platform.isLinux) {
      return FFmpeg.linuxInstallationUrl;
    }
    if (Platform.isWindows) {}
    if (Platform.isMacOS) {}
    return "";
  }
}
