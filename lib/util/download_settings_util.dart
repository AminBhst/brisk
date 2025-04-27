import 'package:brisk/util/settings_cache.dart';
import 'package:brisk_download_engine/brisk_engine.dart';

DownloadSettings downloadSettingsFromCache() {
  return DownloadSettings(
    baseTempDir: SettingsCache.temporaryDir,
    baseSaveDir: SettingsCache.saveDir,
    totalConnections: SettingsCache.connectionsNumber,
    totalM3u8Connections: SettingsCache.m3u8ConnectionNumber,
    connectionRetryTimeoutMillis: SettingsCache.connectionRetryTimeout * 1000,
    maxConnectionRetryCount: SettingsCache.connectionRetryCount,
    loggerEnabled: SettingsCache.loggerEnabled,
    proxySetting: SettingsCache.proxySetting,
  );
}
