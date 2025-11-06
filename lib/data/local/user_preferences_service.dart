import 'package:hive_flutter/hive_flutter.dart';

/// Service quản lý user preferences
/// (Có thể mở rộng cho các preferences khác trong tương lai)
class UserPreferencesService {
  static const String _preferencesBoxName = 'userPreferences';
  static Box? _preferencesBox;

  /// Khởi tạo service
  static Future<void> init() async {
    _preferencesBox = await Hive.openBox(_preferencesBoxName);
  }

  /// Đóng box (cleanup)
  static Future<void> close() async {
    await _preferencesBox?.close();
  }
}




