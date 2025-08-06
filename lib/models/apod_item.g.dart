// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'apod_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApodItemAdapter extends TypeAdapter<ApodItem> {
  @override
  final int typeId = 0;

  @override
  ApodItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApodItem(
      title: fields[0] as String,
      date: fields[1] as String,
      explanation: fields[2] as String,
      url: fields[3] as String,
      hdurl: fields[4] as String?,
      mediaType: fields[5] as String,
      copyright: fields[6] as String?,
      cachedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ApodItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.explanation)
      ..writeByte(3)
      ..write(obj.url)
      ..writeByte(4)
      ..write(obj.hdurl)
      ..writeByte(5)
      ..write(obj.mediaType)
      ..writeByte(6)
      ..write(obj.copyright)
      ..writeByte(7)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApodItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
