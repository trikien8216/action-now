import 'package:hive/hive.dart';
import '../../models/task.dart';

/// Adapter cho Task model để lưu vào Hive database
/// TypeId: 0
class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    
    // Backward compatibility: Handle old schema (8 fields) vs new schema (9 fields)
    // Old schema (8 fields): id, title, description, isCompleted, isFavorite, createdAt, completedAt, delayCompletion
    // New schema (9 fields): id, title, description, folderTask, isCompleted, isFavorite, createdAt, completedAt, delayCompletion
    
    try {
      String? folderTask;
      bool isCompleted;
      bool isFavorite;
      
      if (numOfFields == 8) {
        // Old schema: no folderTask field
        folderTask = null;
        isCompleted = fields[3] as bool? ?? false;
        isFavorite = fields[4] as bool? ?? false;
        
        return Task(
          id: fields[0] as String? ?? '',
          title: fields[1] as String? ?? '',
          description: fields[2] as String?,
          folderTask: folderTask,
          isCompleted: isCompleted,
          isFavorite: isFavorite,
          createdAt: fields[5] != null 
              ? DateTime.fromMillisecondsSinceEpoch(fields[5] as int)
              : DateTime.now(),
          completedAt: fields[6] != null 
              ? DateTime.fromMillisecondsSinceEpoch(fields[6] as int) 
              : null,
          delayCompletion: fields[7] != null 
              ? DateTime.fromMillisecondsSinceEpoch(fields[7] as int) 
              : null,
        );
      } else {
        // New schema: has folderTask field
        folderTask = fields[3] as String?;
        isCompleted = fields[4] as bool? ?? false;
        isFavorite = fields[5] as bool? ?? false;
        
        return Task(
          id: fields[0] as String? ?? '',
          title: fields[1] as String? ?? '',
          description: fields[2] as String?,
          folderTask: folderTask,
          isCompleted: isCompleted,
          isFavorite: isFavorite,
          createdAt: fields[6] != null 
              ? DateTime.fromMillisecondsSinceEpoch(fields[6] as int)
              : DateTime.now(),
          completedAt: fields[7] != null 
              ? DateTime.fromMillisecondsSinceEpoch(fields[7] as int) 
              : null,
          delayCompletion: fields[8] != null 
              ? DateTime.fromMillisecondsSinceEpoch(fields[8] as int) 
              : null,
        );
      }
    } catch (e) {
      // Fallback: return default task if deserialization fails
      return Task(
        id: fields[0]?.toString() ?? '',
        title: fields[1]?.toString() ?? 'Unknown Task',
        description: fields[2]?.toString(),
        folderTask: fields[3]?.toString(),
        isCompleted: fields[4] as bool? ?? false,
        isFavorite: fields[5] as bool? ?? false,
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(9) // Total number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.folderTask)
      ..writeByte(4)
      ..write(obj.isCompleted)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(7)
      ..write(obj.completedAt?.millisecondsSinceEpoch)
      ..writeByte(8)
      ..write(obj.delayCompletion?.millisecondsSinceEpoch);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}


