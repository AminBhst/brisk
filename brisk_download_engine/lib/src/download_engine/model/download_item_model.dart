import 'package:brisk_download_engine/src/download_engine/download_type.dart';

class DownloadItemModel {
  int? id;

  String uid;

  String fileName;

  String filePath;

  String downloadUrl;

  DateTime? startDate;

  int fileSize;

  DateTime? finishDate;

  double progress;

  String fileType;

  bool supportsPause;

  String status;

  String? m3u8Content;

  String? refererHeader;

  /// Only used for m3u8
  int? duration;

  Map<String, String> requestHeaders;

  DownloadItemModel({
    this.id,
    this.uid = "",
    required this.fileName,
    this.filePath = '',
    required this.downloadUrl,
    this.startDate,
    this.finishDate,
    required this.progress,
    this.fileSize = 0,
    this.fileType = "other",
    this.supportsPause = false,
    this.status = "In Queue",
    this.m3u8Content,
    this.duration,
    this.refererHeader,
    this.requestHeaders = const {},
  });

  DownloadType get downloadType =>
      m3u8Content != null && m3u8Content!.isNotEmpty
          ? DownloadType.m3u8
          : DownloadType.http;
}
