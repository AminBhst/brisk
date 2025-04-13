// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_queue.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadQueueAdapter extends TypeAdapter<DownloadQueue> {
  @override
  final int typeId = 1;

  @override
  DownloadQueue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadQueue(
      name: fields[0] as String,
      downloadItemsIds: (fields[1] as List?)?.cast<int>(),
      shutdownAfterCompletion: fields[4] == null ? false : fields[4] as bool,
      simultaneousDownloads: fields[5] == null ? 1 : fields[5] as int,
    )
      ..scheduledStart = fields[2] as DateTime?
      ..scheduledEnd = fields[3] as DateTime?;
  }

  @override
  void write(BinaryWriter writer, DownloadQueue obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.downloadItemsIds)
      ..writeByte(2)
      ..write(obj.scheduledStart)
      ..writeByte(3)
      ..write(obj.scheduledEnd)
      ..writeByte(4)
      ..write(obj.shutdownAfterCompletion)
      ..writeByte(5)
      ..write(obj.simultaneousDownloads);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadQueueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
