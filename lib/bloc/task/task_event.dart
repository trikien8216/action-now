import 'package:equatable/equatable.dart';
import '../../../data/models/task.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class TaskAddEvent extends TaskEvent {
  final String taskListId;
  final Task task;

  const TaskAddEvent({
    required this.taskListId,
    required this.task,
  });

  @override
  List<Object?> get props => [taskListId, task];
}

class TaskUpdateEvent extends TaskEvent {
  final String taskListId;
  final String taskId;
  final Task updatedTask;

  const TaskUpdateEvent({
    required this.taskListId,
    required this.taskId,
    required this.updatedTask,
  });

  @override
  List<Object?> get props => [taskListId, taskId, updatedTask];
}

class TaskDeleteEvent extends TaskEvent {
  final String taskListId;
  final String taskId;

  const TaskDeleteEvent({
    required this.taskListId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [taskListId, taskId];
}

class TaskToggleCompletionEvent extends TaskEvent {
  final String taskListId;
  final String taskId;

  const TaskToggleCompletionEvent({
    required this.taskListId,
    required this.taskId,
  });

  @override
  List<Object?> get props => [taskListId, taskId];
}



