import 'package:ActionNow/view/widgets/dialogs/app_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/list_task/list_task_event.dart';
import '../data/models/task.dart';
import '../action/act_task.dart';
import '../action/act_task_list.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../bloc/list_task/list_task_bloc.dart';
import '../bloc/list_task/list_task_state.dart';
import '../config/app_router.dart';

// Helper class để quản lý items trong ListView.builder
class _ListItem {
  final bool isHeader;
  final bool isSpacer;
  final String? headerTitle;
  final Task? task;

  _ListItem({
    this.isHeader = false,
    this.isSpacer = false,
    this.headerTitle,
    this.task,
  });
}

class TaskScreen extends StatelessWidget {
  final String title;
  final String? taskListId; // ID của TaskList cụ thể (null = tất cả)
  final bool showFavoritesOnly;

  const TaskScreen({
    super.key,
    required this.title,
    this.taskListId,
    this.showFavoritesOnly = false,
  });

  /// Hiển thị dialog thêm task
  /// Logic đã được chuyển vào TaskCubit và AppDialogs
  void _showAddTaskDialog(BuildContext context) {
    if (taskListId != null) {
      // Nếu có taskListId cụ thể, thêm task trực tiếp vào TaskList đó
      AppDialogs.showAddTaskDialog(
        context,
        taskListId!,
        onTaskAdded: () {
          // Task đã được thêm thành công
        },
      );
    } else {
      // Nếu taskListId == null (Full task), cần cho user chọn TaskList
      final allTaskLists = context.read<ListTaskBloc>().getTaskLists();

      if (allTaskLists.isEmpty) {
        // Nếu chưa có TaskList nào, hiển thị thông báo
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng tạo danh sách task trước khi thêm task'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Hiển thị dialog cho user chọn TaskList
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chọn danh sách'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: allTaskLists.map((taskList) {
                return ListTile(
                  title: Text(taskList.title),
                  onTap: () {
                    AppRouter.pop(context);
                    // Hiển thị dialog add task cho TaskList đã chọn
                    AppDialogs.showAddTaskDialog(
                      context,
                      taskList.id,
                      onTaskAdded: () {
                        // Task đã được thêm thành công
                      },
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => AppRouter.pop(context),
              child: const Text('Hủy'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => AppRouter.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            tooltip: 'Làm mới danh sách',
            onPressed: () {
              context.read<ListTaskBloc>().add(const ListTaskRefreshEvent());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Task List
          Expanded(
            child: Container(
              child: BlocBuilder<ListTaskBloc, ListTaskState>(
                builder: (context, state) {
                  if (state is ListTaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ListTaskError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }

                  // Đọc từ ListTaskBloc state
                  final allTaskLists = state is ListTaskLoaded
                      ? state.taskLists
                      : <TaskList>[];

                  // Sử dụng ActTaskList để lấy tasks
                  final allTasks = ActTaskList.getAllTasks(
                    allTaskLists,
                    taskListId: taskListId,
                    showFavoritesOnly: showFavoritesOnly,
                  );

                  // Process tasks (group by date, sort by time) từ ActTask
                  final processed = ActTask.processTasks(allTasks);
                  final todayTasks = processed['todayTasks'] as List<Task>;
                  final tomorrowTasks =
                      processed['tomorrowTasks'] as List<Task>;
                  final otherTasks =
                      processed['otherTasks'] as Map<String, List<Task>>;
                  final allTasksList = processed['allTasks'] as List<Task>;

                  // Tạo danh sách items để hiển thị (section headers + tasks)
                  final items = <_ListItem>[];

                  // TODAY section
                  if (todayTasks.isNotEmpty) {
                    items.add(_ListItem(isHeader: true, headerTitle: 'TODAY'));
                    for (final task in todayTasks) {
                      items.add(_ListItem(isHeader: false, task: task));
                    }
                    items.add(_ListItem(isSpacer: true));
                  }

                  // TOMORROW section
                  if (tomorrowTasks.isNotEmpty) {
                    items.add(
                      _ListItem(isHeader: true, headerTitle: 'TOMORROW'),
                    );
                    for (final task in tomorrowTasks) {
                      items.add(_ListItem(isHeader: false, task: task));
                    }
                    items.add(_ListItem(isSpacer: true));
                  }

                  // Other days sections
                  for (final entry in otherTasks.entries) {
                    items.add(
                      _ListItem(isHeader: true, headerTitle: entry.key),
                    );
                    for (final task in entry.value) {
                      items.add(_ListItem(isHeader: false, task: task));
                    }
                    items.add(_ListItem(isSpacer: true));
                  }

                  if (allTasksList.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Chưa có task nào',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(fontSize: 16),
                        ),
                      ),
                    );
                  }

                  // Sử dụng ListView.builder để hiển thị dữ liệu
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      if (item.isSpacer) {
                        return const SizedBox(height: 16);
                      }

                      if (item.isHeader) {
                        return _buildSectionHeader(context, item.headerTitle!);
                      }

                      // Build task card
                      return _buildTaskCard(context, item.task!, allTaskLists);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            _showAddTaskDialog(context);
          },
          backgroundColor: colorScheme.primary,
          shape: const CircleBorder(),
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    List<TaskList> allTaskLists,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sử dụng ActTask để tính toán time
    final timeData = ActTask.calculateTaskTime(task);
    final startTime = timeData['startTimeStr'] as String;
    final endTime = timeData['endTimeStr'] as String;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shadowColor: colorScheme.onSurface.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: colorScheme.surface,
      child: GestureDetector(
        onTap: () {
          // Find the task list containing this task từ Bloc
          final taskList = allTaskLists.firstWhere(
                (tl) => tl.tasks.any((t) => t.id == task.id),
            orElse: () => allTaskLists.first,
          );
          context.read<TaskBloc>().add(TaskToggleCompletionEvent(
            taskListId: taskList.id,
            taskId: task.id,
          ));
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: task.isCompleted
                    ? colorScheme.secondary
                    : colorScheme.primary,
                width: 2,
              ),
              color: task.isCompleted
                  ? colorScheme.secondary
                  : Colors.transparent,
            ),
            child: task.isCompleted
                ? Icon(Icons.check, size: 16, color: colorScheme.onSecondary)
                : null,
          ),
          title: Text(
            task.title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              '$startTime - $endTime',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          trailing: PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
            onSelected: (value) {
              // Find the task list containing this task
              final taskList = allTaskLists.firstWhere(
                (tl) => tl.tasks.any((t) => t.id == task.id),
                orElse: () => allTaskLists.first,
              );
              
              if (value == 'edit') {
                // Hiển thị dialog chỉnh sửa task
                AppDialogs.showEditTaskDialog(
                  context,
                  taskList.id,
                  task,
                );
              } else if (value == 'delete') {
                // Hiển thị dialog xác nhận xóa task
                AppDialogs.showDeleteTaskDialog(
                  context,
                  taskList.id,
                  task,
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20),
                    const SizedBox(width: 8),
                    const Text('Sửa'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Xóa',
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
