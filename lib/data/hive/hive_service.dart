import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'adapters/adapters_registry.dart';

class HiveService {
  static const String _taskListBoxName = 'taskLists';
  static Box<TaskList>? _taskListBox;

  // Initialize Hive
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register tất cả adapters thông qua registry
    await AdaptersRegistry.registerAll();

    // Try to open box, if it fails due to schema mismatch, delete and recreate
    try {
      _taskListBox = await Hive.openBox<TaskList>(_taskListBoxName);
      // Try to access box to ensure it works with current adapter
      // If it fails during read, the catch block will handle it
      if (_taskListBox!.isNotEmpty) {
        // Try to read first value to check if schema matches
        _taskListBox!.values.first;
      }
    } catch (e) {
      // If there's an error (likely due to schema mismatch), delete the box and recreate
      try {
        await Hive.deleteBoxFromDisk(_taskListBoxName);
      } catch (_) {
        // Box might already be deleted or not exist
      }
      _taskListBox = await Hive.openBox<TaskList>(_taskListBoxName);
    }

    // Không khởi tạo sample data - Hive sẽ rỗng khi mới tạo
  }

  // Get all task lists
  static List<TaskList> getAllTaskLists() {
    return _taskListBox?.values.toList() ?? [];
  }

  // Get task list by id
  static TaskList? getTaskListById(String id) {
    return _taskListBox?.get(id);
  }

  // Add task list - Tự động lưu vào database
  static Future<void> addTaskList(TaskList taskList) async {
    await _taskListBox?.put(taskList.id, taskList);
    // Đảm bảo dữ liệu được flush vào disk ngay lập tức
    await _taskListBox?.flush();
  }

  // Update task list - Tự động lưu vào database
  static Future<void> updateTaskList(TaskList taskList) async {
    await _taskListBox?.put(taskList.id, taskList);
    // Đảm bảo dữ liệu được flush vào disk ngay lập tức
    await _taskListBox?.flush();
  }

  // Delete task list
  static Future<void> deleteTaskList(String id) async {
    await _taskListBox?.delete(id);
  }

  // Add task to a task list
  static Future<void> addTaskToTaskList(String taskListId, Task task) async {
    final taskList = getTaskListById(taskListId);
    if (taskList != null) {
      final updatedTasks = List<Task>.from(taskList.tasks)..add(task);
      final updatedTaskList = taskList.copyWith(tasks: updatedTasks);
      await updateTaskList(updatedTaskList);
    }
  }

  // Update task in a task list
  static Future<void> updateTaskInTaskList(
      String taskListId, String taskId, Task updatedTask) async {
    final taskList = getTaskListById(taskListId);
    if (taskList != null) {
      final updatedTasks = taskList.tasks.map((task) {
        return task.id == taskId ? updatedTask : task;
      }).toList();
      final updatedTaskList = taskList.copyWith(tasks: updatedTasks);
      await updateTaskList(updatedTaskList);
    }
  }

  // Delete task from a task list
  static Future<void> deleteTaskFromTaskList(
      String taskListId, String taskId) async {
    final taskList = getTaskListById(taskListId);
    if (taskList != null) {
      final updatedTasks =
          taskList.tasks.where((task) => task.id != taskId).toList();
      final updatedTaskList = taskList.copyWith(tasks: updatedTasks);
      await updateTaskList(updatedTaskList);
    }
  }

  // Toggle task completion
  static Future<void> toggleTaskCompletion(
      String taskListId, String taskId) async {
    final taskList = getTaskListById(taskListId);
    if (taskList != null) {
      final task = taskList.tasks.firstWhere((t) => t.id == taskId);
      final isNowCompleted = !task.isCompleted;
      final updatedTask = task.copyWith(
        isCompleted: isNowCompleted,
        completedAt: isNowCompleted ? DateTime.now() : null,
      );
      await updateTaskInTaskList(taskListId, taskId, updatedTask);
    }
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _taskListBox?.clear();
  }

  // Get box for watch/listen changes
  static Box<TaskList>? get taskListBox => _taskListBox;
}

