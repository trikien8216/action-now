import 'package:flutter/material.dart';
import '../../data/models/task.dart';
import 'dialogs/app_dialogs.dart';

class ListCategoryCard extends StatelessWidget {
  final String title;
  final int itemCount;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isAddButton;
  final TaskList? taskList; // TaskList để xóa (nếu có)

  const ListCategoryCard({
    super.key,
    required this.title,
    required this.itemCount,
    required this.icon,
    required this.color,
    this.onTap,
    this.isAddButton = false,
    this.taskList, // Optional: chỉ có khi không phải Add button
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (isAddButton) {
      return GestureDetector(
        onTap: onTap,
        child: Card(
          child: Center(
            child: Icon(
              Icons.add,
              size: 32,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      onLongPress: taskList != null
          ? () {
              // Hiển thị menu khi long press
              showModalBottomSheet(
                context: context,
                builder: (context) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.delete_outline),
                        title: const Text('Xóa danh sách'),
                        onTap: () {
                          Navigator.pop(context);
                          if (taskList != null) {
                            AppDialogs.showDeleteTaskListDialog(
                              context,
                              taskList!,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }
          : null,
      child: Card(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: color,
                  size: 40,
                ),
              ),
            ),
            // Popup menu button ở góc trên bên phải (chỉ hiện khi có taskList)
            if (taskList != null)
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 18,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 18,
                  onSelected: (value) {
                    if (value == 'edit') {
                      // Hiển thị dialog chỉnh sửa task list
                      AppDialogs.showEditTaskListDialog(
                        context,
                        taskList!,
                      );
                    } else if (value == 'delete') {
                      // Hiển thị dialog xác nhận xóa task list
                      AppDialogs.showDeleteTaskListDialog(
                        context,
                        taskList!,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
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
                            size: 18,
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
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 36,
                padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$itemCount ITEMS',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



