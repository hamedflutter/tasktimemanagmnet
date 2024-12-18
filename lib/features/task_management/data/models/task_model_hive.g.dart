// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_model_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskModelHiveAdapter extends TypeAdapter<TaskModelHive> {
  @override
  final int typeId = 0;

  @override
  TaskModelHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskModelHive(
      id: fields[0] as String,
      content: fields[1] as String?,
      description: fields[2] as String?,
      projectId: fields[3] as String?,
      sectionId: fields[4] as String?,
      parentId: fields[5] as String?,
      order: fields[6] as int?,
      labels: (fields[7] as List?)?.cast<String>(),
      priority: fields[8] as int?,
      dueString: fields[9] as String?,
      dueDate: fields[10] as String?,
      dueDatetime: fields[11] as String?,
      dueLang: fields[12] as String?,
      assigneeId: fields[13] as String?,
      isCompleted: fields[14] as bool?,
      commentCount: fields[15] as int?,
      createdAt: fields[16] as DateTime?,
      duration: fields[17] as String?,
      url: fields[18] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskModelHive obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.projectId)
      ..writeByte(4)
      ..write(obj.sectionId)
      ..writeByte(5)
      ..write(obj.parentId)
      ..writeByte(6)
      ..write(obj.order)
      ..writeByte(7)
      ..write(obj.labels)
      ..writeByte(8)
      ..write(obj.priority)
      ..writeByte(9)
      ..write(obj.dueString)
      ..writeByte(10)
      ..write(obj.dueDate)
      ..writeByte(11)
      ..write(obj.dueDatetime)
      ..writeByte(12)
      ..write(obj.dueLang)
      ..writeByte(13)
      ..write(obj.assigneeId)
      ..writeByte(14)
      ..write(obj.isCompleted)
      ..writeByte(15)
      ..write(obj.commentCount)
      ..writeByte(16)
      ..write(obj.createdAt)
      ..writeByte(17)
      ..write(obj.duration)
      ..writeByte(18)
      ..write(obj.url);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskModelHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
