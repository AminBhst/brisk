// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GeneralDataAdapter extends TypeAdapter<GeneralData> {
  @override
  final int typeId = 3;

  @override
  GeneralData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GeneralData(
      fieldName: fields[1] as String,
      value: fields[2] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, GeneralData obj) {
    writer
      ..writeByte(2)
      ..writeByte(1)
      ..write(obj.fieldName)
      ..writeByte(2)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeneralDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
