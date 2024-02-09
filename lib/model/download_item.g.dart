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
      totalConnections: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadItem obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.totalConnections);
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
