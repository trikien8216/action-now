import 'package:flutter/material.dart';

/// File tổng hợp tất cả các SnackBar trong ứng dụng
class AppSnackbars {
  // ==================== Success SnackBars ====================

  /// Hiển thị SnackBar thành công
  /// 
  /// [context]: BuildContext
  /// [message]: Nội dung thông báo
  /// [duration]: Thời gian hiển thị (mặc định: 3 giây)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4CAF50), // Green for success
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hiển thị SnackBar đăng nhập thành công
  static void showLoginSuccess(BuildContext context) {
    showSuccess(context, 'Đăng nhập thành công!');
  }

  /// Hiển thị SnackBar đăng ký thành công
  static void showRegisterSuccess(BuildContext context) {
    showSuccess(context, 'Đăng ký thành công!');
  }

  /// Hiển thị SnackBar đăng xuất thành công
  static void showLogoutSuccess(BuildContext context) {
    showSuccess(context, 'Đã đăng xuất thành công!');
  }

  /// Hiển thị SnackBar lưu thành công
  static void showSaveSuccess(BuildContext context) {
    showSuccess(context, 'Đã lưu thành công!');
  }

  /// Hiển thị SnackBar xóa thành công
  static void showDeleteSuccess(BuildContext context) {
    showSuccess(context, 'Đã xóa thành công!');
  }

  /// Hiển thị SnackBar cập nhật thành công
  static void showUpdateSuccess(BuildContext context) {
    showSuccess(context, 'Đã cập nhật thành công!');
  }

  // ==================== Error SnackBars ====================

  /// Hiển thị SnackBar lỗi
  /// 
  /// [context]: BuildContext
  /// [message]: Nội dung thông báo lỗi
  /// [duration]: Thời gian hiển thị (mặc định: 4 giây)
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.replaceAll('Exception: ', ''),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.error,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hiển thị SnackBar lỗi đăng nhập
  static void showLoginError(BuildContext context, String error) {
    showError(context, error);
  }

  /// Hiển thị SnackBar lỗi đăng ký
  static void showRegisterError(BuildContext context, String error) {
    showError(context, error);
  }

  /// Hiển thị SnackBar lỗi kết nối
  static void showConnectionError(BuildContext context) {
    showError(context, 'Không thể kết nối. Vui lòng thử lại sau.');
  }

  /// Hiển thị SnackBar lỗi không tìm thấy
  static void showNotFoundError(BuildContext context, String item) {
    showError(context, 'Không tìm thấy $item');
  }

  // ==================== Warning SnackBars ====================

  /// Hiển thị SnackBar cảnh báo
  /// 
  /// [context]: BuildContext
  /// [message]: Nội dung thông báo cảnh báo
  /// [duration]: Thời gian hiển thị (mặc định: 3 giây)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onSecondary),
        ),
        backgroundColor: theme.colorScheme.secondary, // Yellow from theme
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hiển thị SnackBar chỉ lưu local (không sync Firebase)
  static void showLocalOnlyWarning(BuildContext context) {
    showWarning(context, 'Đã lưu (chỉ lưu local, chưa sync lên server)');
  }

  /// Hiển thị SnackBar đồng ý điều khoản
  static void showAgreeTermsWarning(BuildContext context) {
    showWarning(context, 'Vui lòng đồng ý với điều khoản và chính sách');
  }

  // ==================== Info SnackBars ====================

  /// Hiển thị SnackBar thông tin
  /// 
  /// [context]: BuildContext
  /// [message]: Nội dung thông báo
  /// [duration]: Thời gian hiển thị (mặc định: 3 giây)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9), // Coral red from theme
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Hiển thị SnackBar đang xử lý
  static void showProcessing(BuildContext context) {
    showInfo(context, 'Đang xử lý...');
  }

  // ==================== Custom SnackBars ====================

  /// Hiển thị SnackBar tùy chỉnh
  /// 
  /// [context]: BuildContext
  /// [message]: Nội dung thông báo
  /// [backgroundColor]: Màu nền
  /// [textColor]: Màu chữ
  /// [duration]: Thời gian hiển thị
  /// [action]: Action button (tùy chọn)
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: textColor != null ? TextStyle(color: textColor) : null,
        ),
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }

  /// Ẩn SnackBar hiện tại
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Xóa tất cả SnackBar
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}

