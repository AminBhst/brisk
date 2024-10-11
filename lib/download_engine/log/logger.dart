import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

class Logger {
  Timer? flushTimer;
  final String downloadUid;
  final Directory logBaseDir;
  final int? connectionNumber;

  void enablePeriodicLogFlush() {
    this.flushTimer = Timer.periodic(
      Duration(seconds: 2),
      (_) => writeLogBuffer(),
    );
  }

  StringBuffer logBuffer = StringBuffer();

  Logger({
    required this.downloadUid,
    required this.logBaseDir,
    this.connectionNumber,
  });

  void warn(String message, {bool newLine = true}) => this.log(
        LogLevel.WARN,
        connectionNumber != null
            ? "Connection#$connectionNumber: " + message
            : message,
        newLine: newLine,
      );

  void info(String message, {bool newLine = true}) => this.log(
        LogLevel.INFO,
        connectionNumber != null
            ? "Connection#$connectionNumber: " + message
            : message,
        newLine: newLine,
      );

  void trace(String message, {bool newLine = true}) => this.log(
        LogLevel.TRACE,
        connectionNumber != null
            ? "Connection#$connectionNumber: " + message
            : message,
        newLine: newLine,
      );

  void error(String message, {bool newLine = true}) => this.log(
        LogLevel.ERROR,
        connectionNumber != null
            ? "Connection#$connectionNumber: " + message
            : message,
        newLine: newLine,
      );

  void log(LogLevel logLevel, String message, {bool newLine = true}) {
    if (newLine) {
      this.logBuffer.writeln(logLevel.name + ":: " + message);
    } else {
      this.logBuffer.write(logLevel.name + ":: " + message);
    }
    print(logLevel.name + ":: " + message);
  }

  void writeLogBuffer() {
    if (logBuffer.isEmpty) return;
    if (!logBaseDir.existsSync()) {
      logBaseDir.createSync(recursive: true);
    }
    final logFile = File(
      join(logBaseDir.path, "Logs", "${downloadUid}_logs.log"),
    );
    if (!logFile.existsSync()) {
      logFile.createSync(recursive: true);
    }
    logFile.writeAsStringSync(
      logBuffer.toString(),
      mode: FileMode.writeOnlyAppend,
    );
    logBuffer.clear();
  }
}

enum LogLevel { WARN, ERROR, TRACE, INFO }
