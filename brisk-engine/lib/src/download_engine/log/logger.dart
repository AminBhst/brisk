import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';

class Logger {
  Timer? flushTimer;
  final String downloadUid;
  final Directory logBaseDir;
  final int? connectionNumber;

  void enablePeriodicLogFlush() {
    flushTimer = Timer.periodic(
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
        LogLevel.warn,
        connectionNumber != null
            ? "Connection#$connectionNumber: $message"
            : message,
        newLine: newLine,
      );

  void info(String message, {bool newLine = true}) => this.log(
        LogLevel.info,
        connectionNumber != null
            ? "Connection#$connectionNumber: $message"
            : message,
        newLine: newLine,
      );

  void trace(String message, {bool newLine = true}) => this.log(
        LogLevel.trace,
        connectionNumber != null
            ? "Connection#$connectionNumber: $message"
            : message,
        newLine: newLine,
      );

  void error(String message, {bool newLine = true}) => this.log(
        LogLevel.error,
        connectionNumber != null
            ? "Connection#$connectionNumber: $message"
            : message,
        newLine: newLine,
      );

  void log(LogLevel logLevel, String message, {bool newLine = true}) {
    if (newLine) {
      logBuffer.writeln(
        "@${DateTime.now().millisecondsSinceEpoch} ${logLevel.name.toUpperCase()}:: $message",
      );
    } else {
      logBuffer.write(
        "@${DateTime.now().millisecondsSinceEpoch} ${logLevel.name.toUpperCase()}:: $message",
      );
    }
    print("${logLevel.name}:: $message");
  }

  File get logFile => File(
        join(logBaseDir.path, "Logs", "${downloadUid}_logs.log"),
      );

  void writeLogBuffer() {
    if (logBuffer.isEmpty) return;
    if (!logBaseDir.existsSync()) {
      logBaseDir.createSync(recursive: true);
    }
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

enum LogLevel { warn, error, trace, info }
