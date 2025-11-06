import '../data/models/task.dart';

/// File chứa các void cơ bản (helper functions) cho TaskList
class ActTaskList {
  /// Get all tasks từ tất cả TaskList (có thể filter theo taskListId hoặc showFavoritesOnly)
  static List<Task> getAllTasks(List<TaskList> allTaskLists, {
    String? taskListId,
    bool showFavoritesOnly = false,
  }) {
    final allTasks = <Task>[];
    
    for (final taskList in allTaskLists) {
      // Nếu có taskListId cụ thể, chỉ lấy task từ TaskList đó
      if (taskListId != null && taskList.id != taskListId) {
        continue;
      }

      if (showFavoritesOnly) {
        allTasks.addAll(taskList.tasks.where((t) => t.isFavorite));
      } else {
        allTasks.addAll(taskList.tasks);
      }
    }

    return allTasks;
  }
}



