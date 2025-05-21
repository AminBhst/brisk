import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class Logger {
  static late final File _logFile;

  static init() async {
    final suppDir = await getApplicationSupportDirectory();
    _logFile = File(join(suppDir.path, "Brisk_logs.log"));
    _logFile.createSync(recursive: true);
    FlutterError.onError = (details) {
      print('Flutter Error: ${details.exceptionAsString()}');
      print(details.stack);
      Logger.log(details.exceptionAsString());
      Logger.log(details.stack);
      Logger.log(details.exception);
    };
  }

  static void log(dynamic msg) {
    if (msg == null) return;
    print(msg);
    _logFile.writeAsStringSync(
      msg.toString(),
      mode: FileMode.writeOnlyAppend,
    );
  }
}
