import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:uuid/uuid.dart';
import '../constants/file_type.dart';

class DownloadItem {
  int id;
  String uid;
  String fileName;
  String filePath;
  final String downloadUrl;
  final DateTime startDate;
  int contentLength;
  DateTime? finishDate;
  double progress;
  final int queueOrder;
  DLFileType fileType;
  bool supportsPause;
  String status;

  DownloadItem({
    this.id = 0,
    this.uid = "",
    required this.fileName,
    this.filePath = '',
    required this.downloadUrl,
    required this.startDate,
    this.finishDate,
    required this.progress,
    this.queueOrder = 0,
    this.contentLength = 0,
    this.fileType = DLFileType.other,
    this.supportsPause = false,
    this.status = "In Queue"
  });

  factory DownloadItem.fromUrl(String url) {
    final fileName = extractFileNameFromUrl(url);
    final fileType = FileUtil.detectFileType(fileName);
    return DownloadItem(
      uid: const Uuid().v4(),
      fileName: fileName,
      downloadUrl: url,
      startDate: DateTime.now(),
      progress: 0,
      fileType: fileType,
    );
  }
}
