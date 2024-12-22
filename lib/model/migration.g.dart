// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'migration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MigrationAdapter extends TypeAdapter<Migration> {
  @override
  final int typeId = 4;

  @override
  Migration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Migration(
      fields[1] as int,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Migration obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.version)
      ..writeByte(2)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MigrationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
