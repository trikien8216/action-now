import 'package:hive/hive.dart';

class Task extends HiveObject {
  final String id;
  final String title;
  final String? description;
  final String? folderTask;
  final bool isCompleted;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? delayCompletion;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.folderTask,
    this.isCompleted = false,
    this.isFavorite = false,
    DateTime? createdAt,
    this.completedAt,
    this.delayCompletion,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? folderTask,
    bool? isCompleted,
    bool? isFavorite,
    DateTime? delayCompletion,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      folderTask: folderTask ?? this.folderTask,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      delayCompletion: delayCompletion ?? this.delayCompletion,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'folderTask': folderTask,
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
      'delayCompletion': delayCompletion?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    // Parse DateTime với error handling
    DateTime? parseDateTime(String? dateString) {
      if (dateString == null || dateString.isEmpty) return null;
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        print('Lỗi khi parse DateTime: $dateString - $e');
        return null;
      }
    }

    return Task(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      folderTask: json['folderTask'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      delayCompletion: parseDateTime(json['delayCompletion'] as String?),
      createdAt: parseDateTime(json['createdAt'] as String?) ?? DateTime.now(),
      completedAt: parseDateTime(json['completedAt'] as String?),
    );
  }
}

class TaskList extends HiveObject {
  final String id;
  final String title;
  final List<Task> tasks;

  TaskList({
    required this.id,
    required this.title,
    required this.tasks,
  });

  TaskList copyWith({
    String? id,
    String? title,
    List<Task>? tasks,
  }) {
    return TaskList(
      id: id ?? this.id,
      title: title ?? this.title,
      tasks: tasks ?? this.tasks,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tasks': tasks.map((task) => task.toJson()).toList(),
    };
  }

  factory TaskList.fromJson(Map<String, dynamic> json) {
    // Parse tasks - handle null hoặc empty list
    List<Task> tasks = [];
    if (json['tasks'] != null) {
      try {
        final tasksData = json['tasks'];
        if (tasksData is List) {
          tasks = tasksData
              .map((task) {
                try {
                  Map<String, dynamic> taskJson;
                  if (task is Map<String, dynamic>) {
                    taskJson = task;
                  } else if (task is Map) {
                    // Convert Map<dynamic, dynamic> thành Map<String, dynamic>
                    taskJson = _convertMapToStringDynamic(task);
                  } else {
                    print('⚠️ TaskList.fromJson: Task item không phải Map, type: ${task.runtimeType}');
                    return null;
                  }
                  
                  return Task.fromJson(taskJson);
                } catch (e) {
                  print('❌ Lỗi khi parse Task: $e');
                  return null;
                }
              })
              .where((task) => task != null)
              .cast<Task>()
              .toList();
        }
      } catch (e) {
        print('Lỗi khi parse tasks list: $e');
        tasks = []; // Fallback to empty list
      }
    }

    return TaskList(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      tasks: tasks,
    );
  }

  /// Helper method để convert Map<dynamic, dynamic> thành Map<String, dynamic>
  static Map<String, dynamic> _convertMapToStringDynamic(Map map) {
    final result = <String, dynamic>{};
    for (var entry in map.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      
      if (value is Map) {
        // Recursively convert nested Maps
        result[key] = _convertMapToStringDynamic(value);
      } else if (value is List) {
        // Convert List items
        result[key] = value.map((item) {
          if (item is Map) {
            return _convertMapToStringDynamic(item);
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    }
    return result;
  }
}

