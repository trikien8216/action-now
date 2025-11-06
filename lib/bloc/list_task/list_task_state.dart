import 'package:equatable/equatable.dart';
import '../../data/models/task.dart';

abstract class ListTaskState extends Equatable {
  const ListTaskState();

  @override
  List<Object?> get props => [];
}

class ListTaskInitial extends ListTaskState {
  const ListTaskInitial();
}

class ListTaskLoading extends ListTaskState {
  const ListTaskLoading();
}

class ListTaskLoaded extends ListTaskState {
  final List<TaskList> taskLists;

  const ListTaskLoaded(this.taskLists);

  @override
  List<Object?> get props => [taskLists];
}

class ListTaskError extends ListTaskState {
  final String message;

  const ListTaskError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State yêu cầu user chọn data source khi đăng nhập
class ListTaskNeedMergeDecision extends ListTaskState {
  final List<TaskList> hiveTaskLists;
  final List<TaskList> firebaseTaskLists;

  const ListTaskNeedMergeDecision({
    required this.hiveTaskLists,
    required this.firebaseTaskLists,
  });

  @override
  List<Object?> get props => [hiveTaskLists, firebaseTaskLists];
}



