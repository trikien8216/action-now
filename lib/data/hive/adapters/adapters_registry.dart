import 'package:hive/hive.dart';
import 'task_adapter.dart';
import 'task_list_adapter.dart';

/// Registry để quản lý tất cả Hive adapters
/// 
/// Usage:
/// ```dart
/// await AdaptersRegistry.registerAll();
/// ```
class AdaptersRegistry {
  /// TypeId constants để tránh conflict
  static const int taskTypeId = 0;
  static const int taskListTypeId = 1;

  /// Register tất cả adapters cho Hive
  /// 
  /// Lưu ý: Thứ tự register quan trọng - adapter của nested objects 
  /// (Task) phải được register trước adapter của parent objects (TaskList)
  static Future<void> registerAll() async {
    // Register TaskAdapter trước (vì TaskList chứa List<Task>)
    if (!Hive.isAdapterRegistered(taskTypeId)) {
      Hive.registerAdapter(TaskAdapter());
    }

    // Register TaskListAdapter sau
    if (!Hive.isAdapterRegistered(taskListTypeId)) {
      Hive.registerAdapter(TaskListAdapter());
    }
  }

  /// Kiểm tra xem tất cả adapters đã được register chưa
  static bool areAllRegistered() {
    return Hive.isAdapterRegistered(taskTypeId) &&
           Hive.isAdapterRegistered(taskListTypeId);
  }

  /// Unregister tất cả adapters (chủ yếu dùng cho testing)
  /// 
  /// Lưu ý: Hive không hỗ trợ unregister adapters sau khi đã register.
  /// Method này chỉ để documentation. Nếu cần reset, phải restart app.
  static void unregisterAll() {
    // Hive không hỗ trợ unregister adapters
    // Để reset, cần restart app hoặc delete box và recreate
  }
}

