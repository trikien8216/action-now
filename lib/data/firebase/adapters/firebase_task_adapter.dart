import '../../models/task.dart';
import 'firebase_task_list_adapter.dart';

/// Adapter cho CRUD operations của Task với Firebase Realtime Database
/// Sử dụng FirebaseTaskListAdapter để thao tác với TaskList chứa Task
class FirebaseTaskAdapter {
  final FirebaseTaskListAdapter _taskListAdapter;

  FirebaseTaskAdapter(this._taskListAdapter);

  /// Lấy tất cả Task từ một TaskList
  /// 
  /// [taskListId]: ID của TaskList chứa Task
  /// Returns: Danh sách tất cả Task trong TaskList
  /// Throws: Exception nếu có lỗi hoặc TaskList không tồn tại
  Future<List<Task>> getAllByTaskListId(String taskListId) async {
    try {
      final taskList = await _taskListAdapter.getById(taskListId);
      if (taskList == null) {
        print('📥 Firebase: TaskList $taskListId không tồn tại khi lấy tasks');
        throw Exception('TaskList với ID $taskListId không tồn tại');
      }
      print('📥 Firebase: Đã lấy ${taskList.tasks.length} tasks từ TaskList $taskListId');
      return taskList.tasks;
    } catch (e) {
      print('❌ Firebase: Lỗi khi lấy danh sách Task từ TaskList $taskListId: $e');
      throw Exception('Lỗi khi lấy danh sách Task từ Firebase: $e');
    }
  }

  /// Lấy Task theo ID
  /// 
  /// [taskListId]: ID của TaskList chứa Task
  /// [taskId]: ID của Task cần lấy
  /// Returns: Task nếu tồn tại, null nếu không tìm thấy
  /// Throws: Exception nếu có lỗi khi đọc dữ liệu
  Future<Task?> getById(String taskListId, String taskId) async {
    try {
      final taskList = await _taskListAdapter.getById(taskListId);
      if (taskList == null) {
        print('📥 Firebase: TaskList $taskListId không tồn tại khi lấy Task $taskId');
        return null;
      }

      // Tìm task trong list, tránh throw exception
      for (var task in taskList.tasks) {
        if (task.id == taskId) {
          print('📥 Firebase: Đã tìm thấy Task $taskId trong TaskList $taskListId');
          return task;
        }
      }
      print('📥 Firebase: Task $taskId không tìm thấy trong TaskList $taskListId');
      return null;
    } catch (e) {
      print('❌ Firebase: Lỗi khi lấy Task $taskId từ TaskList $taskListId: $e');
      throw Exception('Lỗi khi lấy Task từ Firebase: $e');
    }
  }

  /// Tạo Task mới trong TaskList
  /// 
  /// [taskListId]: ID của TaskList chứa Task
  /// [task]: Task cần tạo
  /// Returns: Task đã được tạo
  /// Throws: Exception nếu có lỗi khi tạo Task
  Future<Task> create(String taskListId, Task task) async {
    try {
      final taskList = await _taskListAdapter.getById(taskListId);
      if (taskList == null) {
        throw Exception('TaskList với ID $taskListId không tồn tại');
      }

      // Kiểm tra Task đã tồn tại chưa
      final taskExists = taskList.tasks.any((t) => t.id == task.id);
      if (taskExists) {
        throw Exception('Task với ID ${task.id} đã tồn tại trong TaskList');
      }

      // Thêm Task mới
      final updatedTasks = List<Task>.from(taskList.tasks)..add(task);
      final updatedTaskList = taskList.copyWith(tasks: updatedTasks);
      await _taskListAdapter.update(updatedTaskList);

      return task;
    } catch (e) {
      throw Exception('Lỗi khi tạo Task trong Firebase: $e');
    }
  }

  /// Cập nhật Task
  /// 
  /// [taskListId]: ID của TaskList chứa Task
  /// [taskId]: ID của Task cần cập nhật
  /// [updatedTask]: Task đã được cập nhật
  /// Returns: Task đã được cập nhật
  /// Throws: Exception nếu có lỗi khi cập nhật Task
  Future<Task> update(
    String taskListId,
    String taskId,
    Task updatedTask,
  ) async {
    try {
      final taskList = await _taskListAdapter.getById(taskListId);
      if (taskList == null) {
        throw Exception('TaskList với ID $taskListId không tồn tại');
      }

      // Tìm và cập nhật Task
      final taskIndex = taskList.tasks.indexWhere((task) => task.id == taskId);
      if (taskIndex == -1) {
        throw Exception('Task với ID $taskId không tồn tại trong TaskList');
      }

      final updatedTasks = List<Task>.from(taskList.tasks);
      updatedTasks[taskIndex] = updatedTask;
      final updatedTaskList = taskList.copyWith(tasks: updatedTasks);
      await _taskListAdapter.update(updatedTaskList);

      return updatedTask;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật Task trong Firebase: $e');
    }
  }

  /// Xóa Task
  /// 
  /// [taskListId]: ID của TaskList chứa Task
  /// [taskId]: ID của Task cần xóa
  /// Throws: Exception nếu có lỗi khi xóa Task
  Future<void> delete(String taskListId, String taskId) async {
    try {
      final taskList = await _taskListAdapter.getById(taskListId);
      if (taskList == null) {
        throw Exception('TaskList với ID $taskListId không tồn tại');
      }

      // Xóa Task
      final updatedTasks =
          taskList.tasks.where((task) => task.id != taskId).toList();
      
      if (updatedTasks.length == taskList.tasks.length) {
        throw Exception('Task với ID $taskId không tồn tại trong TaskList');
      }

      final updatedTaskList = taskList.copyWith(tasks: updatedTasks);
      await _taskListAdapter.update(updatedTaskList);
    } catch (e) {
      throw Exception('Lỗi khi xóa Task từ Firebase: $e');
    }
  }

  /// Toggle trạng thái hoàn thành của Task
  /// 
  /// [taskListId]: ID của TaskList chứa Task
  /// [taskId]: ID của Task cần toggle
  /// Returns: Task đã được cập nhật
  /// Throws: Exception nếu có lỗi khi toggle Task
  Future<Task> toggleCompletion(String taskListId, String taskId) async {
    try {
      final task = await getById(taskListId, taskId);
      if (task == null) {
        throw Exception('Task với ID $taskId không tồn tại trong TaskList');
      }

      final isNowCompleted = !task.isCompleted;
      final updatedTask = task.copyWith(
        isCompleted: isNowCompleted,
        completedAt: isNowCompleted ? DateTime.now() : null,
      );

      return await update(taskListId, taskId, updatedTask);
    } catch (e) {
      throw Exception('Lỗi khi toggle Task trong Firebase: $e');
    }
  }

  /// Kiểm tra Task có tồn tại không
  /// 
  /// [taskListId]: ID của TaskList chứa Task
  /// [taskId]: ID của Task cần kiểm tra
  /// Returns: true nếu tồn tại, false nếu không
  Future<bool> exists(String taskListId, String taskId) async {
    try {
      final task = await getById(taskListId, taskId);
      return task != null;
    } catch (e) {
      return false;
    }
  }

  /// Đếm số lượng Task trong TaskList
  /// 
  /// [taskListId]: ID của TaskList
  /// Returns: Số lượng Task hiện có
  Future<int> countByTaskListId(String taskListId) async {
    try {
      final tasks = await getAllByTaskListId(taskListId);
      return tasks.length;
    } catch (e) {
      return 0;
    }
  }

  /// Cập nhật nhiều Task cùng lúc (batch update)
  /// 
  /// [taskListId]: ID của TaskList chứa Task
  /// [tasks]: Danh sách Task đã được cập nhật
  /// Throws: Exception nếu có lỗi khi cập nhật
  Future<void> updateBatch(String taskListId, List<Task> tasks) async {
    try {
      final taskList = await _taskListAdapter.getById(taskListId);
      if (taskList == null) {
        throw Exception('TaskList với ID $taskListId không tồn tại');
      }

      // Tạo map để merge Task mới với Task cũ
      final taskMap = Map<String, Task>.fromEntries(
        taskList.tasks.map((t) => MapEntry(t.id, t)),
      );

      // Cập nhật Task mới
      for (var task in tasks) {
        taskMap[task.id] = task;
      }

      final updatedTaskList = taskList.copyWith(
        tasks: taskMap.values.toList(),
      );
      await _taskListAdapter.update(updatedTaskList);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật batch Task trong Firebase: $e');
    }
  }

  /// Xóa tất cả Task trong TaskList
  /// 
  /// [taskListId]: ID của TaskList
  /// Throws: Exception nếu có lỗi khi xóa
  Future<void> deleteAllByTaskListId(String taskListId) async {
    try {
      final taskList = await _taskListAdapter.getById(taskListId);
      if (taskList == null) {
        throw Exception('TaskList với ID $taskListId không tồn tại');
      }

      final updatedTaskList = taskList.copyWith(tasks: []);
      await _taskListAdapter.update(updatedTaskList);
    } catch (e) {
      throw Exception('Lỗi khi xóa tất cả Task từ Firebase: $e');
    }
  }
}

