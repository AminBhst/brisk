import 'dart:io';

class Settings {
  final Directory baseSaveDir;
  final Directory baseTempDir;
  final int totalConnections;
  final int connectionRetryTimeout;
  final int maxConnectionRetryCount;

  Settings({
    required this.baseSaveDir,
    required this.baseTempDir,
    required this.totalConnections,
    required this.connectionRetryTimeout,
    required this.maxConnectionRetryCount,
  });
}
