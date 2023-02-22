import 'package:brisk/model/download_item.dart';
import 'package:brisk/util/parse_util.dart';

import 'abstract_base_dao.dart';

class DownloadItemDao extends AbstractBaseDao<DownloadItem> {
  DownloadItemDao._();

  static final DownloadItemDao instance = DownloadItemDao._();

  @override
  String get tableName => "download_item";

  @override
  DownloadItem mapToEntity(Map<String, Object?> map) {
    var item = DownloadItem(
      id: map['id'] as int,
      uid: map['uid'] as String,
      fileName: map['file_name'] as String,
      downloadUrl: map['download_url'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      progress: map['progress'] as double,
      queueOrder: map['queue_order'] as int,
      status: map['status'] as String,
      contentLength: map['content_length'] as int,
      filePath: map['file_path'] != null ? map['file_path'] as String : '',
      fileType: parseFileType(map["file_type"] as String),
      supportsPause: parseBool(map["supports_pause"] as String),
    );
    if (map['finish_date'] != null) {
      item.finishDate = DateTime.parse(map['finish_date'] as String);
    }
    return item;
  }

  @override
  Map<String, Object> entityToMap(DownloadItem entity) {
    return {
      'id': entity.id,
      'uid': entity.uid,
      'file_name': entity.fileName,
      'download_url': entity.downloadUrl,
      'start_date': entity.startDate.toString(),
      if (entity.finishDate != null)
        'finish_date': entity.finishDate.toString(),
      'progress': entity.progress,
      'status' : entity.status,
      'queue_order': entity.queueOrder,
      'content_length': entity.contentLength,
      'file_path': entity.filePath,
      'file_type': entity.fileType.name,
      'supports_pause' : parseBoolStr(entity.supportsPause),
    };
  }

}
