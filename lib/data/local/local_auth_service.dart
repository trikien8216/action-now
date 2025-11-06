import 'package:hive_flutter/hive_flutter.dart';

/// Service quản lý thông tin đăng nhập local (Remember Me)
/// Lưu email và password vào Hive để tự động đăng nhập
class LocalAuthService {
  static const String _boxName = 'localAuth';
  static Box? _box;

  /// Khởi tạo service
  static Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Lưu thông tin đăng nhập
  /// 
  /// [email]: Email của user
  /// [password]: Password của user
  static Future<void> saveCredentials(String email, String password) async {
    if (_box == null) await init();
    await _box!.put('email', email);
    await _box!.put('password', password);
    await _box!.put('savedAt', DateTime.now().millisecondsSinceEpoch);
    await _box!.flush();
  }

  /// Lấy email đã lưu
  /// 
  /// Returns: Email nếu có, null nếu không
  static String? getSavedEmail() {
    if (_box == null) return null;
    return _box!.get('email') as String?;
  }

  /// Lấy password đã lưu
  /// 
  /// Returns: Password nếu có, null nếu không
  static String? getSavedPassword() {
    if (_box == null) return null;
    return _box!.get('password') as String?;
  }

  /// Kiểm tra có thông tin đăng nhập đã lưu không
  /// 
  /// Returns: true nếu có, false nếu không
  static bool hasSavedCredentials() {
    if (_box == null) return false;
    final email = _box!.get('email');
    final password = _box!.get('password');
    return email != null && password != null;
  }

  /// Lấy thông tin đăng nhập đã lưu
  /// 
  /// Returns: Map với 'email' và 'password', hoặc null nếu không có
  static Map<String, String>? getSavedCredentials() {
    if (_box == null) return null;
    final email = getSavedEmail();
    final password = getSavedPassword();
    
    if (email == null || password == null) return null;
    
    return {
      'email': email,
      'password': password,
    };
  }

  /// Xóa thông tin đăng nhập đã lưu
  static Future<void> clearCredentials() async {
    if (_box == null) await init();
    await _box!.delete('email');
    await _box!.delete('password');
    await _box!.delete('savedAt');
    await _box!.flush();
  }

  /// Xóa tất cả dữ liệu (khi logout)
  static Future<void> clearAll() async {
    if (_box == null) await init();
    await _box!.clear();
    await _box!.flush();
  }
}




