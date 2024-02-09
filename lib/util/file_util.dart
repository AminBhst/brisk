import 'dart:async';
import 'dart:io';

import 'package:brisk/db/hive_util.dart';
import 'package:brisk/util/file_extensions.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../constants/file_type.dart';
import '../model/isolate/isolate_args_pair.dart';
import 'settings_cache.dart';

class FileUtil {
  static final versionedFileRegex = RegExp('.*_\d*');
  static late Directory defaultTempFileDir;
  static late Directory defaultSaveDir;

  /// Due to the fact that on Linux, temporary directory (/tmp) is cleaned on
  /// reboot, another default temp directory has to be created.
  static Future<Directory> setDefaultTempDir() async {
    Completer<Directory> completer = Completer();
    Directory tempDir =
        Platform.isLinux ? await linuxDefaultTempDir : await defaultTempDir;
    tempDir.createSync(recursive: true);
    defaultTempFileDir = tempDir;
    completer.complete(tempDir);
    return completer.future;
  }

  static Future<Directory> get defaultTempDir async {
    final baseTempDir = await getTemporaryDirectory();
    return Directory(join(baseTempDir.path, 'Brisk'));
  }

  static Future<Directory> get linuxDefaultTempDir async {
    final downloadsDir = await getDownloadsDirectory();
    return Directory(join(downloadsDir!.path, 'Brisk', 'Temp'));
  }

  static Future<Directory> setDefaultSaveDir() {
    Completer<Directory> completer = Completer();
    getDownloadsDirectory().then((dir) {
      defaultSaveDir = Directory(join(dir!.path, 'Brisk'));

      /// TODO FIX NULL CHECK
      defaultSaveDir.createSync(recursive: true);
      completer.complete(defaultSaveDir);
    });
    return completer.future;
  }

  static String getFilePath(String fileName,
      {Directory? baseSaveDir, bool checkFileDuplicationOnly = false}) {
    final saveDir = baseSaveDir ?? SettingsCache.saveDir;
    if (!saveDir.existsSync()) {
      saveDir.createSync();
      _createSubDirectories(saveDir.path);
    }

    final subDir = _fileTypeToFolderName(detectFileType(fileName));
    var filePath = join(saveDir.path, subDir, fileName);
    final subDirFullPath = join(saveDir.path, subDir);
    var file = File(filePath);
    final extension = fileName.endsWith("tar.gz")
        ? "tar.gz"
        : fileName.substring(fileName.lastIndexOf('.') + 1);
    int version = 1;

    while (checkDownloadDuplication(file, checkFileDuplicationOnly)) {
      var rawName = getRawFileName(fileName);
      if (versionedFileRegex.hasMatch(rawName)) {
        rawName = rawName.substring(0, rawName.lastIndexOf('_'));
      }
      ++version;
      fileName = '${rawName}_$version.$extension';
      file = File(join(subDirFullPath, fileName));
    }

    return join(saveDir.path, subDir, fileName);
  }

  static bool checkDownloadDuplication(
      File file, bool checkFileDuplicationOnly) {
    if (checkFileDuplicationOnly) return file.existsSync();

    return HiveUtil.instance.downloadItemsBox.values
            .where((element) => element.filePath == file.path)
            .isNotEmpty ||
        file.existsSync();
  }

  static String getRawFileName(String fileName) {
    return fileName.substring(
        0,
        fileName.endsWith(".tar.gz")
            ? fileName.lastIndexOf('.') - 4
            : fileName.lastIndexOf('.'));
  }

  static void _createSubDirectories(String path) async {
    final dirs = [
      Directory(join(path, 'Music')),
      Directory(join(path, 'Compressed')),
      Directory(join(path, 'Videos')),
      Directory(join(path, 'Programs')),
      Directory(join(path, 'Documents')),
      Directory(join(path, 'Other'))
    ];
    for (var dir in dirs) {
      await dir.create();
    }
  }

  /// Detects the [DLFileType] based on the file extension.
  /// TODO : Read from setting cache
  static DLFileType detectFileType(String fileName) {
    final type = extension(fileName.toLowerCase()).replaceAll(".", "");
    if (FileExtensions.document.contains(type)) {
      return DLFileType.documents;
    } else if (FileExtensions.program.contains(type)) {
      return DLFileType.program;
    } else if (FileExtensions.compressed.contains(type) ||
        fileName.endsWith("tar.gz")) {
      return DLFileType.compressed;
    } else if (FileExtensions.music.contains(type)) {
      return DLFileType.music;
    } else if (FileExtensions.video.contains(type)) {
      return DLFileType.video;
    } else {
      return DLFileType.other;
    }
  }

  static String _fileTypeToFolderName(DLFileType fileType) {
    if (fileType == DLFileType.video) {
      return 'Videos';
    } else if (fileType == DLFileType.music) {
      return 'Music';
    } else if (fileType == DLFileType.program) {
      return 'Programs';
    } else if (fileType == DLFileType.documents) {
      return 'Documents';
    } else if (fileType == DLFileType.compressed) {
      return 'Compressed';
    } else {
      return 'Other';
    }
  }

  /// Iterates through all written file parts and adds their byte length.
  /// Returns the total byte length which is used to display part write progress
  /// in the UI and also to set the proper download headers for a resume download request.
  static int calculateReceivedBytesSync(Directory dir) {
    int totalLength = 0;
    for (var file in dir.listSync(recursive: true)) {
      totalLength += (file as File).lengthSync();
    }
    return totalLength;
  }

  /// Simply calls [calculateReceivedBytesSync] but is intended to be used by an isolate
  static void calculateReceivedBytesIsolated(IsolateArgsPair<Directory> args) {
    args.sendPort.send(calculateReceivedBytesSync(args.obj));
  }

  static String resolveFileTypeIconPath(String fileType) {
    if (fileType == DLFileType.music.name) {
      return 'assets/icons/music.svg';
    } else if (fileType == DLFileType.video.name) {
      return 'assets/icons/video_2.svg';
    } else if (fileType == DLFileType.compressed.name) {
      return 'assets/icons/archive.svg';
    } else if (fileType == DLFileType.documents.name) {
      return 'assets/icons/document.svg';
    } else if (fileType == DLFileType.program.name) {
      return 'assets/icons/program.svg';
    } else {
      return 'assets/icons/file.svg';
    }
  }

  static Color resolveFileTypeIconColor(String fileType) {
    if (fileType == DLFileType.music.name) {
      return Colors.cyanAccent;
    } else if (fileType == DLFileType.video.name) {
      return Colors.pinkAccent;
    } else if (fileType == DLFileType.compressed.name) {
      return Colors.blue;
    } else if (fileType == DLFileType.documents.name) {
      return Colors.orangeAccent;
    } else if (fileType == DLFileType.program.name) {
      return const Color.fromRGBO(163, 74, 40, 1);
    } else {
      return Colors.grey;
    }
  }

  static void deleteDownloadTempDirectory(int id) {
    final path = join(defaultTempFileDir.path, id.toString());
    final dir = Directory(path);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }

  static int sortByFileName(FileSystemEntity a, FileSystemEntity b) {
    final aName = basename(a.path);
    final bName = basename(b.path);
    final aStartByte = aName.substring(0, aName.indexOf("-"));
    final bStartByte = bName.substring(0, bName.indexOf("-"));
    return int.parse(aStartByte).compareTo(int.parse(bStartByte));
  }

  static int getStartByteFromTempFileName(String tempFileName) {
    return int.parse(tempFileName.substring(0, tempFileName.indexOf("-")));
  }

  static int getEndByteFromTempFileName(String fileName) {
    return int.parse(fileName.substring(fileName.indexOf("-")));
  }

  static int fileNameToInt(FileSystemEntity file) {
    return int.parse(basename(file.path).toString());
  }

  static bool checkFileDuplication(String fileName) {
    final subDir = _fileTypeToFolderName(detectFileType(fileName));
    final filePath = join(SettingsCache.saveDir.path, subDir, fileName);
    return File(filePath).existsSync();
  }
}
