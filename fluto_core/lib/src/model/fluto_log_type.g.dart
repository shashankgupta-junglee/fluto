// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'fluto_log_type.dart';
//
// // **************************************************************************
// // TypeAdapterGenerator
// // **************************************************************************
//
// class FlutoLogTypeAdapter extends TypeAdapter<FlutoLogType> {
//   @override
//   final int typeId = 1;
//
//   @override
//   FlutoLogType read(BinaryReader reader) {
//     switch (reader.readByte()) {
//       case 0:
//         return FlutoLogType.debug;
//       case 1:
//         return FlutoLogType.info;
//       case 2:
//         return FlutoLogType.warning;
//       case 3:
//         return FlutoLogType.error;
//       case 4:
//         return FlutoLogType.print;
//       default:
//         return FlutoLogType.debug;
//     }
//   }
//
//   @override
//   void write(BinaryWriter writer, FlutoLogType obj) {
//     switch (obj) {
//       case FlutoLogType.debug:
//         writer.writeByte(0);
//         break;
//       case FlutoLogType.info:
//         writer.writeByte(1);
//         break;
//       case FlutoLogType.warning:
//         writer.writeByte(2);
//         break;
//       case FlutoLogType.error:
//         writer.writeByte(3);
//         break;
//       case FlutoLogType.print:
//         writer.writeByte(4);
//         break;
//     }
//   }
//
//   @override
//   int get hashCode => typeId.hashCode;
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FlutoLogTypeAdapter &&
//           runtimeType == other.runtimeType &&
//           typeId == other.typeId;
// }
