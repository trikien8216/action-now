import 'package:hive/hive.dart';
import '../../models/task.dart';

/// Adapter cho TaskList model để lưu vào Hive database
/// TypeId: 1
/// Lưu ý: TaskAdapter (typeId: 0) phải được register trước TaskListAdapter
class TaskListAdapter extends TypeAdapter<TaskList> {
  @override
  final int typeId = 1;

  @override
  TaskList read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    try {
      // Read tasks list - handle null và invalid data
      List<Task> tasks = [];
      if (fields[2] != null) {
        final tasksList = fields[2] as List?;
        if (tasksList != null) {
          tasks = tasksList
              .where((item) => item is Task) // Filter chỉ lấy Task objects
              .map((item) => item as Task)
              .toList();
        }
      }
      
      return TaskList(
        id: fields[0] as String? ?? '',
        title: fields[1] as String? ?? '',
        tasks: tasks,
      );
    } catch (e) {
      // Fallback: return empty TaskList if deserialization fails
      return TaskList(
        id: fields[0]?.toString() ?? '',
        title: fields[1]?.toString() ?? 'Unknown List',
        tasks: [],
      );
    }
  }

  @override
  void write(BinaryWriter writer, TaskList obj) {
    writer
      ..writeByte(3) // Total number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.tasks); // Hive sẽ tự động serialize List<Task> vì TaskAdapter đã được register
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskListAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

