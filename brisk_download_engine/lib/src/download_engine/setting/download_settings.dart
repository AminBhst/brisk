import 'dart:io';

import 'package:brisk_download_engine/src/download_engine/setting/proxy_setting.dart';

class DownloadSettings extends ConnectionSettings {
  final Directory baseSaveDir;
  int totalConnections;
  int totalM3u8Connections;

  DownloadSettings({
    required this.baseSaveDir,
    required this.totalConnections,
    required this.totalM3u8Connections,
    required super.loggerEnabled,
    required super.baseTempDir,
    required super.connectionRetryTimeoutMillis,
    required super.maxConnectionRetryCount,
    super.proxySetting,
  });
}

class ConnectionSettings {
  final Directory baseTempDir;
  final int connectionRetryTimeoutMillis;
  final int maxConnectionRetryCount;
  final bool loggerEnabled;
  final ProxySetting? proxySetting;

  ConnectionSettings({
    required this.baseTempDir,
    required this.connectionRetryTimeoutMillis,
    required this.maxConnectionRetryCount,
    required this.loggerEnabled,
    this.proxySetting,
  });
}
