// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vaccine.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VaccineAdapter extends TypeAdapter<Vaccine> {
  @override
  final int typeId = 2;

  @override
  Vaccine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Vaccine(
      pet: fields[0] as String,
      vacina: fields[1] as String,
      data: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Vaccine obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.pet)
      ..writeByte(1)
      ..write(obj.vacina)
      ..writeByte(2)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VaccineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
