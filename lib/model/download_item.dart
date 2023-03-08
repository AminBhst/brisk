import 'package:brisk/util/file_util.dart';
import 'package:brisk/util/http_util.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../constants/file_type.dart';

part 'download_item.g.dart';

@HiveType(typeId: 0)
class DownloadItem extends HiveObject{

  @HiveField(1)
  String uid;

  @HiveField(2)
  String fileName;

  @HiveField(3)
  String filePath;

  @HiveField(4)
  String downloadUrl;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  int contentLength;

  @HiveField(7)
  DateTime? finishDate;

  @HiveField(8)
  double progress;

  @HiveField(9)
  final int queueOrder;

  @HiveField(10)
  String fileType;

  @HiveField(11)
  bool supportsPause;

  @HiveField(12)
  String status;

  DownloadItem({
    this.uid = "",
    required this.fileName,
    this.filePath = '',
    required this.downloadUrl,
    required this.startDate,
    this.finishDate,
    required this.progress,
    this.queueOrder = 0,
    this.contentLength = 0,
    this.fileType = "other",
    this.supportsPause = false,
    this.status = "In Queue",
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
      fileType: fileType.name,
    );
  }
}
