// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadItemAdapter extends TypeAdapter<DownloadItem> {
  @override
  final int typeId = 0;

  @override
  DownloadItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadItem(
      uid: fields[1] as String,
      fileName: fields[2] as String,
      filePath: fields[3] as String,
      downloadUrl: fields[4] as String,
      startDate: fields[5] as DateTime,
      finishDate: fields[7] as DateTime?,
      progress: fields[8] as double,
      contentLength: fields[6] as int,
      fileType: fields[9] as String,
      supportsPause: fields[10] as bool,
      status: fields[11] as String,
      extraInfo:
          fields[12] == null ? {} : (fields[12] as Map).cast<String, dynamic>(),
      downloadType: fields[13] == null ? 'HTTP' : fields[13] as String,
      subtitles: fields[15] == null
          ? []
          : (fields[15] as List)
              .map((dynamic e) => (e as Map).cast<String, String>())
              .toList(),
      requestHeaders:
          fields[16] == null ? {} : (fields[16] as Map).cast<String, String>(),
    )..referer = fields[14] as String?;
  }

  @override
  void write(BinaryWriter writer, DownloadItem obj) {
    writer
      ..writeByte(16)
      ..writeByte(1)
      ..write(obj.uid)
      ..writeByte(2)
      ..write(obj.fileName)
      ..writeByte(3)
      ..write(obj.filePath)
      ..writeByte(4)
      ..write(obj.downloadUrl)
      ..writeByte(5)
      ..write(obj.startDate)
      ..writeByte(6)
      ..write(obj.contentLength)
      ..writeByte(7)
      ..write(obj.finishDate)
      ..writeByte(8)
      ..write(obj.progress)
      ..writeByte(9)
      ..write(obj.fileType)
      ..writeByte(10)
      ..write(obj.supportsPause)
      ..writeByte(11)
      ..write(obj.status)
      ..writeByte(12)
      ..write(obj.extraInfo)
      ..writeByte(13)
      ..write(obj.downloadType)
      ..writeByte(14)
      ..write(obj.referer)
      ..writeByte(15)
      ..write(obj.subtitles)
      ..writeByte(16)
      ..write(obj.requestHeaders);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
