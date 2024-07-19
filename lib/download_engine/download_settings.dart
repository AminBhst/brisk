import 'dart:io';

class DownloadSettings {
  final Directory baseSaveDir;
  final Directory baseTempDir;
  final int totalConnections;
  final int connectionRetryTimeout;
  final int maxConnectionRetryCount;

  DownloadSettings({
    required this.baseSaveDir,
    required this.baseTempDir,
    required this.totalConnections,
    required this.connectionRetryTimeout,
    required this.maxConnectionRetryCount,
  });
}
