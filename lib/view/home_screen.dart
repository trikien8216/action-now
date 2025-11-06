import 'package:ActionNow/view/widgets/drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/list_task/list_task_event.dart';
import '../config/config_list.dart';
import '../config/app_router.dart';
import '../data/models/task.dart';
import '../bloc/home/home_bloc.dart';
import '../bloc/home/home_event.dart';
import '../bloc/home/home_state.dart';
import '../bloc/list_task/list_task_bloc.dart';
import '../bloc/list_task/list_task_state.dart';
import 'widgets/dialogs/app_dialogs.dart';
import 'widgets/list_category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Load data từ HomeBloc
    context.read<HomeBloc>().add(const HomeLoadEvent());
  }


  void _showAddTaskListDialog(BuildContext context) {
    AppDialogs.showAddTaskListDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: theme.scaffoldBackgroundColor,
      endDrawer: DrawerWidget(),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Greeting text - Sử dụng HomeBloc để lấy displayName
                        BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, homeState) {
                            final displayName = context.read<HomeBloc>().getDisplayName();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hi, $displayName 👋',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Wish the bestie today',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            );
                          },
                        ),

                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 24),
                    tooltip: 'Làm mới danh sách',
                    onPressed: () {
                      context.read<ListTaskBloc>().add(const ListTaskRefreshEvent());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, size: 28),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Grid Lists - Item đầu tiên là Full task, sau đó là các TaskList từ Hive
            Expanded(
              child: BlocBuilder<ListTaskBloc, ListTaskState>(
                builder: (context, state) {
                  if (state is ListTaskLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (state is ListTaskError) {
                    return Center(child: Text('Error: ${state.message}'));
                  }
                  
                  // Đọc từ ListTaskCubit state
                  final allTaskLists = state is ListTaskLoaded 
                      ? state.taskLists 
                      : <TaskList>[];
                  
                  // Tính tổng số task từ tất cả TaskList
                  final totalTasksCount = allTaskLists.fold<int>(
                    0, (sum, list) => sum + list.tasks.length
                  );

                  // itemCount = 1 (Full task) + allTaskLists.length + 1 (Add button)
                  final itemCount = 1 + allTaskLists.length + 1;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: itemCount,
                      itemBuilder: (context, index) {
                        // Index 0: Full task (không thuộc Hive)
                        if (index == 0) {
                          return ListCategoryCard(
                            title: 'Full task',
                            itemCount: totalTasksCount,
                            icon: Icons.assignment,
                            color: theme.colorScheme.primary,
                            onTap: () {
                              AppRouter.toListDetail(
                                context,
                                title: 'Full task',
                                taskListId: null, // null = tất cả task
                              );
                            },
                          );
                        }

                        // Add button ở cuối
                        if (index == itemCount - 1) {
                          return ListCategoryCard(
                            title: '',
                            itemCount: 0,
                            icon: Icons.add,
                            color: theme.colorScheme.primary,
                            isAddButton: true,
                            onTap: () => _showAddTaskListDialog(context),
                          );
                        }

                        // Hiển thị TaskList từ Hive (index - 1 vì có Full task ở đầu)
                        final taskListIndex = index - 1;
                        final taskList = allTaskLists[taskListIndex];
                        return ListCategoryCard(
                          title: taskList.title,
                          itemCount: taskList.tasks.length,
                          icon: ConfigList().getIconForTaskList(taskList.title),
                          color: ConfigList().getColorForTaskList(taskList.title),
                          taskList: taskList, // Pass taskList để có thể xóa
                          onTap: () {
                            AppRouter.toListDetail(
                              context,
                              title: taskList.title,
                              taskListId: taskList.id,
                            );
                          },
                        );
                      },
                    ),
                  );
                  },
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            _showAddTaskListDialog(context);
          },
          backgroundColor: colorScheme.primary,
          shape: const CircleBorder(),
          child: Icon(Icons.add, color: colorScheme.onPrimary),
        ),
      ),
    );
  }
}

