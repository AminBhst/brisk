import 'dart:io';
import 'dart:isolate';

import '../download_item.dart';

class BaseIsolateArgs {
  final SendPort sendPort;

  BaseIsolateArgs({required this.sendPort});
}

class HandleSingleConnectionArgs extends BaseIsolateArgs {
  final int segmentNumber;
  final int maxConnectionRetryCount;
  final int connectionRetryTimeout;

  HandleSingleConnectionArgs({
    required this.segmentNumber,
    required super.sendPort,
    required this.maxConnectionRetryCount,
    required this.connectionRetryTimeout,
  });
}



class FileAssemblerArgs extends BaseIsolateArgs {
  final DownloadItem downloadItem;
  final Directory tempDir;

  FileAssemblerArgs({
    required super.sendPort,
    required this.downloadItem,
    required this.tempDir,
  });
}
