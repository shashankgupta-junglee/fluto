// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'fluto_log_model.dart';
//
// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************
//
// class FlutoLogModelAdapter extends TypeAdapter<FlutoLogModel> {
//   @override
//   final int typeId = 0;
//
//   @override
//   FlutoLogModel read(BinaryReader reader) {
//     final numOfFields = reader.readByte();
//     final fields = <int, dynamic>{
//       for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
//     };
//     return FlutoLogModel(
//       logMessage: fields[0] as String,
//       logType: fields[1] as String,
//       logTime: fields[2] as DateTime,
//       errorString: fields[3] as String?,
//       stackTraceString: fields[4] as String?,
//     );
//   }
//
//   @override
//   void write(BinaryWriter writer, FlutoLogModel obj) {
//     writer
//       ..writeByte(5)
//       ..writeByte(0)
//       ..write(obj.logMessage)
//       ..writeByte(1)
//       ..write(obj.logType)
//       ..writeByte(2)
//       ..write(obj.logTime)
//       ..writeByte(3)
//       ..write(obj.errorString)
//       ..writeByte(4)
//       ..write(obj.stackTraceString);
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FlutoLogModelAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
