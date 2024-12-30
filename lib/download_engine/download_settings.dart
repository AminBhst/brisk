import 'dart:io';

import 'package:brisk/setting/proxy/proxy_setting.dart';
import 'package:brisk/util/settings_cache.dart';

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
    required super.connectionRetryTimeout,
    required super.maxConnectionRetryCount,
    super.proxySetting,
  });

  factory DownloadSettings.fromSettingsCache() {
    return DownloadSettings(
      baseTempDir: SettingsCache.temporaryDir,
      baseSaveDir: SettingsCache.saveDir,
      totalConnections: SettingsCache.connectionsNumber,
      totalM3u8Connections: SettingsCache.m3u8ConnectionNumber,
      connectionRetryTimeout: SettingsCache.connectionRetryTimeout * 1000,
      maxConnectionRetryCount: SettingsCache.connectionRetryCount,
      loggerEnabled: SettingsCache.loggerEnabled,
      proxySetting: SettingsCache.proxySetting,
    );
  }
}

class ConnectionSettings {
  final Directory baseTempDir;
  final int connectionRetryTimeout;
  final int maxConnectionRetryCount;
  final bool loggerEnabled;
  final ProxySetting? proxySetting;

  ConnectionSettings({
    required this.baseTempDir,
    required this.connectionRetryTimeout,
    required this.maxConnectionRetryCount,
    required this.loggerEnabled,
    this.proxySetting,
  });
}
