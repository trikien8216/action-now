import '../data/models/task.dart';

/// File chứa các void cơ bản (helper functions) cho Task
class ActTask {
  /// Process tasks: group by date và sort by time
  /// Trả về Map với keys: 'todayTasks', 'tomorrowTasks', 'otherTasks', 'allTasks'
  static Map<String, dynamic> processTasks(List<Task> allTasks) {
    // Group tasks by date
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final todayTasks = <Task>[];
    final tomorrowTasks = <Task>[];
    final otherTasks = <String, List<Task>>{};

    for (final task in allTasks) {
      final taskDate = task.completedAt ?? task.createdAt;
      final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);

      if (taskDay == today) {
        todayTasks.add(task);
      } else if (taskDay == tomorrow) {
        tomorrowTasks.add(task);
      } else {
        final dayKey = getDayName(taskDay);
        if (!otherTasks.containsKey(dayKey)) {
          otherTasks[dayKey] = [];
        }
        otherTasks[dayKey]!.add(task);
      }
    }

    // Sort tasks by time
    void sortTasks(List<Task> tasks) {
      tasks.sort((a, b) {
        final timeA = (a.completedAt ?? a.createdAt).hour * 60 + 
                     (a.completedAt ?? a.createdAt).minute;
        final timeB = (b.completedAt ?? b.createdAt).hour * 60 + 
                     (b.completedAt ?? b.createdAt).minute;
        return timeA.compareTo(timeB);
      });
    }
    
    sortTasks(todayTasks);
    sortTasks(tomorrowTasks);
    for (final tasks in otherTasks.values) {
      sortTasks(tasks);
    }

    return {
      'todayTasks': todayTasks,
      'tomorrowTasks': tomorrowTasks,
      'otherTasks': otherTasks,
      'allTasks': allTasks,
    };
  }

  /// Get day name từ DateTime
  static String getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateDay = DateTime(date.year, date.month, date.day);
    
    final difference = dateDay.difference(today).inDays;
    
    if (difference == 0) return 'TODAY';
    if (difference == 1) return 'TOMORROW';
    
    const days = ['MONDAY', 'TUESDAY', 'WEDNESDAY', 'THURSDAY', 'FRIDAY', 'SATURDAY', 'SUNDAY'];
    return days[date.weekday - 1];
  }

  /// Tính start time và end time từ task
  /// Trả về Map với keys: 'startTime', 'endTime', 'startTimeStr', 'endTimeStr'
  static Map<String, dynamic> calculateTaskTime(Task task) {
    final taskTime = task.completedAt ?? task.createdAt;
    final startTimeStr = '${taskTime.hour.toString().padLeft(2, '0')}:${taskTime.minute.toString().padLeft(2, '0')}';
    
    // Tính end time từ task, nếu có deadline thì dùng, không thì +2h
    DateTime endTime;
    if (task.delayCompletion != null) {
      endTime = task.delayCompletion!;
    } else {
      endTime = taskTime.add(const Duration(hours: 2));
    }
    final endTimeStr = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';

    return {
      'startTime': taskTime,
      'endTime': endTime,
      'startTimeStr': startTimeStr,
      'endTimeStr': endTimeStr,
    };
  }
}



