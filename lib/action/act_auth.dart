/// File chứa các void cơ bản (helper functions) cho Auth
class ActAuth {
  // ============ LOGIN VALIDATION ============

  /// Validate login form
  static bool validateLoginForm(String email, String password) {
    return email.isNotEmpty && 
           email.contains('@') && 
           password.length >= 6;
  }

  /// Validate email field cho login
  static String? validateLoginEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.contains('@')) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Validate password field cho login
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  // ============ REGISTER VALIDATION ============

  /// Validate register form
  static bool validateRegisterForm(
    String name,
    String email,
    String password,
    String confirmPassword,
  ) {
    return name.isNotEmpty &&
           email.isNotEmpty &&
           email.contains('@') &&
           password.length >= 6 &&
           confirmPassword == password;
  }

  /// Validate name field cho register
  static String? validateRegisterName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    return null;
  }

  /// Validate email field cho register
  static String? validateRegisterEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!value.contains('@')) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  /// Validate password field cho register
  static String? validateRegisterPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    return null;
  }

  /// Validate confirm password field cho register
  static String? validateRegisterConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }
}


