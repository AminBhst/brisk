import 'dart:io';
import 'dart:isolate';

import '../download_item.dart';

class BaseIsolateArgs {
  final SendPort sendPort;

  BaseIsolateArgs({required this.sendPort});
}

class HandleSingleConnectionArgs extends BaseIsolateArgs {
  int segmentNumber;
  int totalSegments;

  HandleSingleConnectionArgs({
    required this.segmentNumber,
    required this.totalSegments,
    required super.sendPort,
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
