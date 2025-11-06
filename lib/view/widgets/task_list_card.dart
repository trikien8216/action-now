import 'package:flutter/material.dart';
import '../../data/models/task.dart';

class TaskListCard extends StatelessWidget {
  final TaskList taskList;
  final VoidCallback onTap;

  const TaskListCard({
    super.key,
    required this.taskList,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = colorScheme.surface;
    final textColor = colorScheme.onSurface;
    final addButtonColor = colorScheme.primary;
    final checkBoxColor = colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  taskList.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: addButtonColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.add,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...taskList.tasks.take(4).map((task) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: task.isCompleted
                              ? colorScheme.secondary
                              : checkBoxColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: task.isCompleted ? colorScheme.secondary : Colors.transparent,
                      ),
                      child: task.isCompleted
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: colorScheme.onSecondary,
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: task.isCompleted
                              ? textColor.withValues(alpha: 0.5)
                              : textColor,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

