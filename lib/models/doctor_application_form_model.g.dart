// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_application_form_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoctorApplicationFormAdapter extends TypeAdapter<DoctorApplicationForm> {
  @override
  final int typeId = 11;

  @override
  DoctorApplicationForm read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoctorApplicationForm()
      ..step1PersonalInfo = (fields[0] as Map?)?.cast<String, dynamic>()
      ..step2ClinicInfo = (fields[1] as Map?)?.cast<String, dynamic>()
      ..step3Documents = (fields[2] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, String>())
          ?.toList()
      ..isSubmitted = fields[3] as bool;
  }

  @override
  void write(BinaryWriter writer, DoctorApplicationForm obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.step1PersonalInfo)
      ..writeByte(1)
      ..write(obj.step2ClinicInfo)
      ..writeByte(2)
      ..write(obj.step3Documents)
      ..writeByte(3)
      ..write(obj.isSubmitted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorApplicationFormAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
