import 'package:brisk/constants/download_type.dart';
import 'package:brisk/model/download_item.dart';

class DownloadItemModel {
  int id;

  String uid;

  String fileName;

  String filePath;

  String downloadUrl;

  final DateTime startDate;

  int contentLength;

  DateTime? finishDate;

  double progress;

  String fileType;

  bool supportsPause;

  String status;

  String? m3u8FilePath;

  DownloadItemModel({
    required this.id,
    this.uid = "",
    required this.fileName,
    this.filePath = '',
    required this.downloadUrl,
    required this.startDate,
    this.finishDate,
    required this.progress,
    this.contentLength = 0,
    this.fileType = "other",
    this.supportsPause = false,
    this.status = "In Queue",
    this.m3u8FilePath,
  });

  factory DownloadItemModel.fromDownloadItem(DownloadItem item) {
    return DownloadItemModel(
      id: item.key,
      fileName: item.fileName,
      downloadUrl: item.downloadUrl,
      startDate: item.startDate,
      progress: item.progress,
      contentLength: item.contentLength,
      filePath: item.filePath,
      fileType: item.fileType,
      finishDate: item.finishDate,
      status: item.status,
      supportsPause: item.supportsPause,
      uid: item.uid,
      m3u8FilePath: item.extraInfo["m3u8Content"],
    );
  }

  DownloadType get downloadType =>
      m3u8FilePath != null && m3u8FilePath!.isNotEmpty
          ? DownloadType.M3U8
          : DownloadType.HTTP;
}
