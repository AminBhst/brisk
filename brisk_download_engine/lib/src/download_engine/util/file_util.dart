import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart';

class FileUtil {
  static final versionedFileRegex = RegExp('.*_\d*');

  static String getFilePath(
    String fileName,
    Directory saveDir, {
    bool checkFileDuplicationOnly = false,
  }) {
    if (!saveDir.existsSync()) {
      saveDir.createSync();
    }

    var file = File(join(saveDir.path, fileName));
    final extension = fileName.endsWith("tar.gz")
        ? "tar.gz"
        : fileName.substring(fileName.lastIndexOf('.') + 1);
    int version = 1;

    while (file.existsSync()) {
      var rawName = getRawFileName(fileName);
      if (versionedFileRegex.hasMatch(rawName)) {
        rawName = rawName.substring(0, rawName.lastIndexOf('_'));
      }
      ++version;
      fileName = '${rawName}_$version.$extension';
      file = File(join(saveDir.path, fileName));
    }

    return join(saveDir.path, fileName);
  }

  static String getRawFileName(String fileName) {
    return fileName.substring(
        0,
        fileName.endsWith(".tar.gz")
            ? fileName.lastIndexOf('.') - 4
            : fileName.lastIndexOf('.'));
  }

  static bool isFileName(String str) {
    final fileNameRegex = RegExp(r'^[^<>:"/\\|?*\n]+(\.[a-zA-Z0-9]{1,10})$');
    return fileNameRegex.hasMatch(str.trim());
  }
}

extension Util on File {
  Uint8List safeReadSync(int count) {
    final fileOpen = openSync();
    final result = fileOpen.readSync(count);
    fileOpen.closeSync();
    return result;
  }
}
