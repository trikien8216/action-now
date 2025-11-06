import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/hive/hive_service.dart';
import '../../data/firebase/firebase_auth_service.dart';
import '../../data/firebase/firebase_database_service.dart';
import '../../data/models/task.dart';
import 'task_event.dart';
import 'task_state.dart';

/// TaskBloc - Quản lý các tính năng chính cho individual Tasks
/// Các void cơ bản (helper functions) đã được chuyển vào action/act_task.dart và action/act_task_list.dart
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(const TaskInitial()) {
    on<TaskAddEvent>(_onAddTask);
    on<TaskUpdateEvent>(_onUpdateTask);
    on<TaskDeleteEvent>(_onDeleteTask);
    on<TaskToggleCompletionEvent>(_onToggleTaskCompletion);
  }

  Future<void> _onAddTask(
    TaskAddEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      // Nếu đã đăng nhập: Chỉ lưu vào Firebase, không lưu vào Hive
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          // Kiểm tra TaskList có tồn tại trong Firebase không
          final taskList = await FirebaseDatabaseService.getTaskListById(event.taskListId);
          if (taskList == null) {
            throw Exception('TaskList với ID ${event.taskListId} không tồn tại trong Firebase');
          }

          await FirebaseDatabaseService.addTaskToTaskList(event.taskListId, event.task);
          print('✅ TaskBloc: Đã thêm task vào Firebase: ${event.task.id}');
          emit(const TaskOperationSuccess());
          return;
        } catch (e) {
          print('❌ TaskBloc: Lỗi khi thêm task vào Firebase: $e');
          emit(TaskError('Lỗi khi thêm task: ${e.toString()}'));
          return;
        }
      }

      // Chưa đăng nhập: Lưu vào Hive
      final localTaskList = HiveService.getTaskListById(event.taskListId);
      if (localTaskList == null) {
        throw Exception('TaskList với ID ${event.taskListId} không tồn tại trong Hive');
      }

      await HiveService.addTaskToTaskList(event.taskListId, event.task);
      print('✅ TaskBloc: Đã thêm task vào Hive: ${event.task.id} trong TaskList: ${event.taskListId}');
      emit(const TaskOperationSuccess());
    } catch (e) {
      print('❌ TaskBloc: Lỗi khi thêm task: $e');
      emit(TaskError('Lỗi khi thêm task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTask(
    TaskUpdateEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      // Nếu đã đăng nhập: Chỉ cập nhật Firebase, không cập nhật Hive
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          await FirebaseDatabaseService.updateTaskInTaskList(
            event.taskListId,
            event.taskId,
            event.updatedTask,
          );
          print('✅ TaskBloc: Đã cập nhật task trong Firebase: ${event.taskId}');
          emit(const TaskOperationSuccess());
          return;
        } catch (e) {
          print('❌ TaskBloc: Lỗi khi cập nhật task trong Firebase: $e');
          emit(TaskError('Lỗi khi cập nhật task: ${e.toString()}'));
          return;
        }
      }

      // Chưa đăng nhập: Cập nhật trong Hive
      await HiveService.updateTaskInTaskList(
        event.taskListId,
        event.taskId,
        event.updatedTask,
      );
      print('✅ TaskBloc: Đã cập nhật task trong Hive: ${event.taskId}');
      emit(const TaskOperationSuccess());
    } catch (e) {
      print('❌ TaskBloc: Lỗi khi cập nhật task: $e');
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTask(
    TaskDeleteEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      // Nếu đã đăng nhập: Chỉ xóa trong Firebase, không xóa trong Hive
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          await FirebaseDatabaseService.deleteTaskFromTaskList(event.taskListId, event.taskId);
          print('✅ TaskBloc: Đã xóa task khỏi Firebase: ${event.taskId}');
          emit(const TaskOperationSuccess());
          return;
        } catch (e) {
          print('❌ TaskBloc: Lỗi khi xóa task khỏi Firebase: $e');
          emit(TaskError('Lỗi khi xóa task: ${e.toString()}'));
          return;
        }
      }

      // Chưa đăng nhập: Xóa khỏi Hive
      await HiveService.deleteTaskFromTaskList(event.taskListId, event.taskId);
      print('✅ TaskBloc: Đã xóa task khỏi Hive: ${event.taskId}');
      emit(const TaskOperationSuccess());
    } catch (e) {
      print('❌ TaskBloc: Lỗi khi xóa task: $e');
      emit(TaskError(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
    TaskToggleCompletionEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      // Nếu đã đăng nhập: Chỉ toggle trong Firebase, không toggle trong Hive
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          await FirebaseDatabaseService.toggleTaskCompletion(event.taskListId, event.taskId);
          print('✅ TaskBloc: Đã toggle task completion trong Firebase: ${event.taskId}');
          emit(const TaskOperationSuccess());
          return;
        } catch (e) {
          print('❌ TaskBloc: Lỗi khi toggle task completion trong Firebase: $e');
          emit(TaskError('Lỗi khi toggle task completion: ${e.toString()}'));
          return;
        }
      }

      // Chưa đăng nhập: Toggle trong Hive
      await HiveService.toggleTaskCompletion(event.taskListId, event.taskId);
      print('✅ TaskBloc: Đã toggle task completion trong Hive: ${event.taskId}');
      emit(const TaskOperationSuccess());
    } catch (e) {
      print('❌ TaskBloc: Lỗi khi toggle task completion: $e');
      emit(TaskError(e.toString()));
    }
  }
}

