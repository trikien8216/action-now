import 'package:flutter/material.dart';
import '../view/home_screen.dart';
import '../view/auth/login_screen.dart';
import '../view/auth/register_screen.dart';
import '../view/screens/profile_screen.dart';
import '../view/screens/loading_screen.dart';
import '../view/task_screen.dart';

/// Router quản lý tất cả navigation trong ứng dụng
/// Cung cấp các method để navigate giữa các màn hình
class AppRouter {
  // Route names constants
  static const String loading = '/loading';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String listDetail = '/list-detail';
  static const String taskListDetail = '/task-list-detail';

  /// Routes map cho MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        loading: (context) => const LoadingScreen(),
        home: (context) => const HomeScreen(),
        login: (context) => const LoginScreen(),
        register: (context) => const RegisterScreen(),
        profile: (context) => const ProfileScreen(),
      };

  // ==================== Navigation Methods ====================

  /// Navigate đến màn hình mới (push)
  /// 
  /// [context]: BuildContext
  /// [route]: Route name hoặc Widget
  /// [arguments]: Arguments để truyền vào route
  static Future<T?>? push<T extends Object?>(
    BuildContext context,
    dynamic route, {
    Object? arguments,
  }) {
    if (route is String) {
      return Navigator.pushNamed<T>(
        context,
        route,
        arguments: arguments,
      );
    } else if (route is Widget) {
      return Navigator.push<T>(
        context,
        MaterialPageRoute<T>(builder: (context) => route),
      );
    }
    return null;
  }

  /// Navigate và thay thế màn hình hiện tại (pushReplacement)
  /// 
  /// [context]: BuildContext
  /// [route]: Route name hoặc Widget
  /// [arguments]: Arguments để truyền vào route
  static Future<T?>? pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    dynamic route, {
    Object? arguments,
    TO? result,
  }) {
    if (route is String) {
      return Navigator.pushReplacementNamed<T, TO>(
        context,
        route,
        arguments: arguments,
        result: result,
      );
    } else if (route is Widget) {
      return Navigator.pushReplacement<T, TO>(
        context,
        MaterialPageRoute<T>(builder: (context) => route),
        result: result,
      );
    }
    return null;
  }

  /// Navigate và xóa tất cả route cũ (pushAndRemoveUntil)
  /// 
  /// [context]: BuildContext
  /// [route]: Route name hoặc Widget
  /// [arguments]: Arguments để truyền vào route
  static Future<T?>? pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    dynamic route, {
    Object? arguments,
    bool Function(Route<dynamic>)? predicate,
  }) {
    predicate ??= (route) => false; // Xóa tất cả routes cũ

    if (route is String) {
      return Navigator.pushNamedAndRemoveUntil<T>(
        context,
        route,
        predicate,
        arguments: arguments,
      );
    } else if (route is Widget) {
      return Navigator.pushAndRemoveUntil<T>(
        context,
        MaterialPageRoute<T>(builder: (context) => route),
        predicate,
      );
    }
    return null;
  }

  /// Quay lại màn hình trước (pop)
  /// 
  /// [context]: BuildContext
  /// [result]: Kết quả trả về cho màn hình trước
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }

  /// Quay lại về màn hình đầu tiên và xóa stack
  /// 
  /// [context]: BuildContext
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Pop và push màn hình mới (popAndPushNamed)
  /// 
  /// [context]: BuildContext
  /// [route]: Route name
  /// [arguments]: Arguments để truyền vào route
  static Future<T?>? popAndPush<T extends Object?, TO extends Object?>(
    BuildContext context,
    String route, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.popAndPushNamed<T, TO>(
      context,
      route,
      arguments: arguments,
      result: result,
    );
  }

  // ==================== Specific Route Methods ====================

  /// Navigate đến LoadingScreen
  static Future<Object?>? toLoading(BuildContext context) {
    return pushReplacement(context, loading);
  }

  /// Navigate đến HomeScreen
  static Future<Object?>? toHome(BuildContext context) {
    return pushReplacement(context, home);
  }

  /// Navigate đến LoginScreen
  static Future<Object?>? toLogin(BuildContext context) {
    return pushReplacement(context, login);
  }

  /// Navigate đến RegisterScreen
  static Future<Object?>? toRegister(BuildContext context) {
    return push(context, register);
  }

  /// Navigate đến ProfileScreen
  static Future<Object?>? toProfile(BuildContext context) {
    return push(context, profile);
  }

  /// Navigate đến ListDetailScreen
  /// 
  /// [title]: Tiêu đề của danh sách
  /// [taskListId]: ID của TaskList (null = tất cả task)
  /// [showFavoritesOnly]: Chỉ hiển thị task được yêu thích
  static Future<Object?>? toListDetail(
    BuildContext context, {
    required String title,
    String? taskListId,
    bool showFavoritesOnly = false,
  }) {
    return push(
      context,
      TaskScreen(
        title: title,
        taskListId: taskListId,
        showFavoritesOnly: showFavoritesOnly,
      ),
    );
  }

  /// Navigate đến TaskListDetailScreen
  /// 
  /// [taskList]: TaskList cần hiển thị
  // static Future<Object?>? toTaskListDetail(
  //   BuildContext context,
  //   TaskList taskList,
  // ) {
  //   return push(
  //     context,
  //     TaskListDetailScreen(taskList: taskList),
  //   );
  // }

  /// Navigate đến TaskListDetailScreen và thay thế màn hình hiện tại
  /// 
  /// [context]: BuildContext
  /// [taskList]: TaskList cần hiển thị
  // static Future<Object?>? toTaskListDetailReplacement(
  //   BuildContext context,
  //   TaskList taskList,
  // ) {
  //   return pushReplacement(
  //     context,
  //     TaskListDetailScreen(taskList: taskList),
  //   );
  // }

  // ==================== Utility Methods ====================

  /// Kiểm tra có thể pop không
  /// 
  /// [context]: BuildContext
  /// Returns: true nếu có thể pop, false nếu không
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Lấy số lượng routes trong stack
  /// 
  /// [context]: BuildContext
  /// Returns: Số lượng routes
  static int getRouteCount(BuildContext context) {
    return Navigator.of(context).widget.initialRoute != null ? 1 : 0;
  }

  /// Show route với transition animation tùy chỉnh
  /// 
  /// [context]: BuildContext
  /// [page]: Widget destination
  /// [transition]: Loại transition (fade, slide, scale, etc.)
  static Future<T?>? pushWithTransition<T extends Object?>(
    BuildContext context,
    Widget page, {
    String transition = 'slide', // slide, fade, scale, rotation
    Duration duration = const Duration(milliseconds: 300),
  }) {
    PageRoute<T> route;

    switch (transition) {
      case 'fade':
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: duration,
        );
        break;
      case 'scale':
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return ScaleTransition(scale: animation, child: child);
          },
          transitionDuration: duration,
        );
        break;
      case 'rotation':
        route = PageRouteBuilder<T>(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return RotationTransition(turns: animation, child: child);
          },
          transitionDuration: duration,
        );
        break;
      default: // slide (mặc định)
        route = MaterialPageRoute<T>(builder: (context) => page);
    }

    return Navigator.push<T>(context, route);
  }

  /// Build MaterialPageRoute với custom transition
  /// 
  /// [builder]: WidgetBuilder
  /// [settings]: RouteSettings
  static MaterialPageRoute<T> buildRoute<T extends Object?>(
    WidgetBuilder builder, {
    RouteSettings? settings,
  }) {
    return MaterialPageRoute<T>(
      builder: builder,
      settings: settings,
    );
  }
}

