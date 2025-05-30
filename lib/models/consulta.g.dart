// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consulta.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConsultaAdapter extends TypeAdapter<Consulta> {
  @override
  final int typeId = 0;

  @override
  Consulta read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Consulta(
      pet: fields[0] as String,
      data: fields[1] as String,
      veterinario: fields[2] as String,
      observacoes: fields[3] as String,
      assunto: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Consulta obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.pet)
      ..writeByte(1)
      ..write(obj.data)
      ..writeByte(2)
      ..write(obj.veterinario)
      ..writeByte(3)
      ..write(obj.observacoes)
      ..writeByte(4)
      ..write(obj.assunto);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConsultaAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
