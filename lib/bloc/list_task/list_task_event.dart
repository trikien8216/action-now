import 'package:equatable/equatable.dart';
import '../../../data/models/task.dart';

abstract class ListTaskEvent extends Equatable {
  const ListTaskEvent();

  @override
  List<Object?> get props => [];
}

class ListTaskLoadEvent extends ListTaskEvent {
  const ListTaskLoadEvent();
}

class ListTaskAddEvent extends ListTaskEvent {
  final TaskList taskList;

  const ListTaskAddEvent(this.taskList);

  @override
  List<Object?> get props => [taskList];
}

class ListTaskUpdateEvent extends ListTaskEvent {
  final TaskList taskList;

  const ListTaskUpdateEvent(this.taskList);

  @override
  List<Object?> get props => [taskList];
}

class ListTaskDeleteEvent extends ListTaskEvent {
  final String id;

  const ListTaskDeleteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ListTaskRefreshEvent extends ListTaskEvent {
  const ListTaskRefreshEvent();
}

class ListTaskReloadAfterLoginEvent extends ListTaskEvent {
  const ListTaskReloadAfterLoginEvent();
}

class ListTaskClearAfterLogoutEvent extends ListTaskEvent {
  const ListTaskClearAfterLogoutEvent();
}

/// Event xử lý merge data sau khi user chọn
class ListTaskMergeDecisionEvent extends ListTaskEvent {
  final bool useHiveData; // true = dùng Hive, false = dùng Firebase

  const ListTaskMergeDecisionEvent(this.useHiveData);

  @override
  List<Object?> get props => [useHiveData];
}



