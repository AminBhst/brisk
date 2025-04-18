import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<void> migrateDatabaseLocation() async {
  final documentsDir = await getApplicationDocumentsDirectory();
  final oldDbPath = path.join(documentsDir.path, "Brisk_v2");
  final oldDbDir = Directory(oldDbPath);
  if (!oldDbDir.existsSync()) {
    return;
  }
  final appSupportDir = await getApplicationSupportDirectory();
  final newPath = path.join(appSupportDir.path);
  Directory(newPath).createSync(recursive: true);
  for (final file in oldDbDir.listSync()) {
    if (file is File) {
      final fileName = path.basename(file.path);
      final newFilePath = path.join(newPath, fileName);
      await file.rename(newFilePath);
    }
  }
  oldDbDir.deleteSync();
}
