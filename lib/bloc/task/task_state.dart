import 'package:equatable/equatable.dart';
import '../../data/models/task.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {
  const TaskInitial();
}

class TaskLoading extends TaskState {
  const TaskLoading();
}

class TaskLoaded extends TaskState {
  final List<TaskList> taskLists;

  const TaskLoaded(this.taskLists);

  @override
  List<Object?> get props => [taskLists];
}

class TaskError extends TaskState {
  final String message;

  const TaskError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskOperationSuccess extends TaskState {
  const TaskOperationSuccess();
}



