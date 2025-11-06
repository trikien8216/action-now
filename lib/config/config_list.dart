import 'package:flutter/material.dart';

class ConfigList {
  // Helper function để lấy icon và color dựa vào tên TaskList
  IconData getIconForTaskList(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('work')) return Icons.work_outline;
    if (lowerTitle.contains('personal')) return Icons.person;
    if (lowerTitle.contains('idea')) return Icons.lightbulb_outline;
    if (lowerTitle.contains('favorite') || lowerTitle.contains('favourite')) {
      return Icons.star_outline;
    }
    return Icons.list; // Default icon
  }

  Color getColorForTaskList(String title) {
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('work')) return Colors.blue;
    if (lowerTitle.contains('personal')) return Colors.blue;
    if (lowerTitle.contains('idea')) return Colors.green;
    if (lowerTitle.contains('favorite') || lowerTitle.contains('favourite')) {
      return Colors.green;
    }
    return Colors.orange; // Default color
  }
}
