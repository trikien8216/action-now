import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../bloc/task/task_bloc.dart';
import '../../../bloc/task/task_event.dart';
import '../../../bloc/list_task/list_task_bloc.dart';
import '../../../bloc/list_task/list_task_event.dart';
import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/profile/profile_event.dart';
import '../../../config/app_router.dart';
import '../../../data/hive/hive_service.dart';
import '../../../data/models/task.dart';
import '../snackbars/app_snackbars.dart';

/// File tổng hợp tất cả các Dialog trong ứng dụng
class AppDialogs {
  // ==================== Task List Dialogs ====================

  /// Dialog thêm TaskList mới
  /// 
  /// [context]: BuildContext
  /// [onTaskListAdded]: Callback khi TaskList được thêm thành công
  static void showAddTaskListDialog(
    BuildContext context, {
    VoidCallback? onTaskListAdded,
  }) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm danh sách mới'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Tên danh sách',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final newTaskList = TaskList(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  tasks: [],
                );
                
                // Dùng ListTaskBloc cho TaskList operations
                context.read<ListTaskBloc>().add(ListTaskAddEvent(newTaskList));
                
                AppRouter.pop(context);
                onTaskListAdded?.call();
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  /// Dialog chỉnh sửa TaskList
  /// 
  /// [context]: BuildContext
  /// [taskList]: TaskList cần chỉnh sửa
  /// [onTaskListUpdated]: Callback khi TaskList được cập nhật thành công
  static void showEditTaskListDialog(
    BuildContext context,
    TaskList taskList, {
    VoidCallback? onTaskListUpdated,
  }) {
    final titleController = TextEditingController(text: taskList.title);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa danh sách'),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(
            labelText: 'Tên danh sách',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                final updatedTaskList = taskList.copyWith(
                  title: titleController.text.trim(),
                );
                
                // Dùng ListTaskBloc cho TaskList operations
                context.read<ListTaskBloc>().add(ListTaskUpdateEvent(updatedTaskList));
                
                AppRouter.pop(context);
                onTaskListUpdated?.call();
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// Dialog xác nhận xóa TaskList
  /// 
  /// [context]: BuildContext
  /// [taskList]: TaskList cần xóa
  /// [onTaskListDeleted]: Callback khi TaskList được xóa thành công
  static void showDeleteTaskListDialog(
    BuildContext context,
    TaskList taskList, {
    VoidCallback? onTaskListDeleted,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa danh sách'),
        content: Text(
          'Bạn có chắc chắn muốn xóa danh sách "${taskList.title}"? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Dùng ListTaskBloc cho TaskList operations
              context.read<ListTaskBloc>().add(ListTaskDeleteEvent(taskList.id));
              
              if (context.mounted) {
                AppRouter.pop(context);
                onTaskListDeleted?.call();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // ==================== Task Dialogs ====================

  /// Dialog thêm Task mới
  /// 
  /// [context]: BuildContext
  /// [taskListId]: ID của TaskList sẽ chứa Task
  /// [onTaskAdded]: Callback khi Task được thêm thành công
  static void showAddTaskDialog(
    BuildContext context,
    String taskListId, {
    VoidCallback? onTaskAdded,
  }) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm nhiệm vụ mới'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                final newTask = Task(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );
                
                // Chỉ dùng TaskBloc (đã dùng Hive bên trong)
                context.read<TaskBloc>().add(TaskAddEvent(
                  taskListId: taskListId,
                  task: newTask,
                ));
                
                if (context.mounted) {
                  AppRouter.pop(context);
                  onTaskAdded?.call();
                }
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  /// Dialog chỉnh sửa Task
  /// 
  /// [context]: BuildContext
  /// [taskListId]: ID của TaskList chứa Task
  /// [task]: Task cần chỉnh sửa
  /// [onTaskUpdated]: Callback khi Task được cập nhật thành công
  static void showEditTaskDialog(
    BuildContext context,
    String taskListId,
    Task task, {
    VoidCallback? onTaskUpdated,
  }) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa nhiệm vụ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Mô tả (tùy chọn)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                final updatedTask = task.copyWith(
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                );
                
                // Chỉ dùng TaskBloc (đã dùng Hive bên trong)
                context.read<TaskBloc>().add(TaskUpdateEvent(
                  taskListId: taskListId,
                  taskId: task.id,
                  updatedTask: updatedTask,
                ));
                
                if (context.mounted) {
                  AppRouter.pop(context);
                  onTaskUpdated?.call();
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// Dialog xác nhận xóa Task
  /// 
  /// [context]: BuildContext
  /// [taskListId]: ID của TaskList chứa Task
  /// [task]: Task cần xóa
  /// [onTaskDeleted]: Callback khi Task được xóa thành công
  static void showDeleteTaskDialog(
    BuildContext context,
    String taskListId,
    Task task, {
    VoidCallback? onTaskDeleted,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa nhiệm vụ'),
        content: Text(
          'Bạn có chắc chắn muốn xóa nhiệm vụ "${task.title}"? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Chỉ dùng TaskBloc (đã dùng Hive bên trong)
              context.read<TaskBloc>().add(TaskDeleteEvent(
                taskListId: taskListId,
                taskId: task.id,
              ));
              
              if (context.mounted) {
                AppRouter.pop(context);
                onTaskDeleted?.call();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // ==================== Settings Dialogs ====================

  /// Dialog cài đặt thông báo
  /// 
  /// [context]: BuildContext
  static void showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cài đặt thông báo'),
        content: const Text('Tính năng cài đặt thông báo sẽ được thêm sau.'),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Dialog cài đặt ngôn ngữ
  /// 
  /// [context]: BuildContext
  static void showLanguageSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ngôn ngữ'),
        content: const Text('Tính năng chọn ngôn ngữ sẽ được thêm sau.'),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Dialog thông tin nhà phát triển
  /// 
  /// [context]: BuildContext
  static void showDeveloperInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông tin nhà phát triển'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ActionNow',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Ứng dụng quản lý công việc'),
            const SizedBox(height: 16),
            Text(
              'Phiên bản: 1.0.0',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  /// Dialog xác nhận xóa tất cả dữ liệu
  /// 
  /// [context]: BuildContext
  /// [onDataCleared]: Callback khi dữ liệu được xóa thành công
  static void showClearDataDialog(
    BuildContext context, {
    VoidCallback? onDataCleared,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả dữ liệu'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tất cả dữ liệu? '
          'Hành động này không thể hoàn tác.',
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await HiveService.clearAll();
              
              // Xóa cả Firebase nếu có user đăng nhập
              try {
                // TODO: Xóa dữ liệu Firebase khi đã có implementation
              } catch (e) {
                // Ignore Firebase errors
              }
              
              if (context.mounted) {
                AppRouter.pop(context);
              AppSnackbars.showDeleteSuccess(context);
                onDataCleared?.call();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  // ==================== Generic Dialogs ====================

  /// Dialog xác nhận chung
  /// 
  /// [context]: BuildContext
  /// [title]: Tiêu đề dialog
  /// [message]: Nội dung thông báo
  /// [confirmText]: Text của nút xác nhận (mặc định: 'Xác nhận')
  /// [cancelText]: Text của nút hủy (mặc định: 'Hủy')
  /// [onConfirm]: Callback khi xác nhận
  /// [onCancel]: Callback khi hủy
  /// [isDestructive]: Nếu true, nút xác nhận sẽ có màu đỏ (mặc định: false)
  static void showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Xác nhận',
    String cancelText = 'Hủy',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool isDestructive = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onCancel?.call();
            },
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            style: isDestructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Dialog thông báo đơn giản
  /// 
  /// [context]: BuildContext
  /// [title]: Tiêu đề dialog
  /// [message]: Nội dung thông báo
  /// [buttonText]: Text của nút đóng (mặc định: 'Đóng')
  static void showInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'Đóng',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Dialog lỗi
  /// 
  /// [context]: BuildContext
  /// [title]: Tiêu đề dialog (mặc định: 'Lỗi')
  /// [message]: Nội dung thông báo lỗi
  /// [buttonText]: Text của nút đóng (mặc định: 'Đóng')
  static void showErrorDialog(
    BuildContext context, {
    String title = 'Lỗi',
    required String message,
    String buttonText = 'Đóng',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        icon: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 48,
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Dialog loading
  /// 
  /// [context]: BuildContext
  /// [message]: Thông báo đang xử lý (mặc định: 'Đang xử lý...')
  static void showLoadingDialog(
    BuildContext context, {
    String message = 'Đang xử lý...',
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  // ==================== Profile Dialogs ====================

  /// Dialog sửa tên hiển thị
  /// 
  /// [context]: BuildContext
  /// [currentName]: Tên hiện tại
  /// [onNameUpdated]: Callback khi tên được cập nhật thành công
  static void showEditDisplayNameDialog(
    BuildContext context,
    String? currentName, {
    VoidCallback? onNameUpdated,
  }) {
    final nameController = TextEditingController(text: currentName ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa tên'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Họ và tên',
            hintText: 'Nhập tên của bạn',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                context.read<ProfileBloc>().add(
                  ProfileUpdateDisplayNameEvent(nameController.text.trim()),
                );
                if (context.mounted) {
                  AppRouter.pop(context);
                  onNameUpdated?.call();
                }
              } else {
                AppSnackbars.showError(context, 'Vui lòng nhập tên');
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  /// Dialog sửa mật khẩu
  /// 
  /// [context]: BuildContext
  /// [onPasswordUpdated]: Callback khi mật khẩu được cập nhật thành công
  static void showEditPasswordDialog(
    BuildContext context, {
    VoidCallback? onPasswordUpdated,
  }) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrentPassword = true;
    bool obscureNewPassword = true;
    bool obscureConfirmPassword = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Đổi mật khẩu'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrentPassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrentPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureCurrentPassword = !obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNewPassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu mới',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNewPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureNewPassword = !obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Xác nhận mật khẩu mới',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => AppRouter.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final currentPassword = currentPasswordController.text;
                final newPassword = newPasswordController.text;
                final confirmPassword = confirmPasswordController.text;

                if (currentPassword.isEmpty) {
                  AppSnackbars.showError(context, 'Vui lòng nhập mật khẩu hiện tại');
                  return;
                }

                if (newPassword.isEmpty) {
                  AppSnackbars.showError(context, 'Vui lòng nhập mật khẩu mới');
                  return;
                }

                if (newPassword.length < 6) {
                  AppSnackbars.showError(context, 'Mật khẩu phải có ít nhất 6 ký tự');
                  return;
                }

                if (newPassword != confirmPassword) {
                  AppSnackbars.showError(context, 'Mật khẩu xác nhận không khớp');
                  return;
                }

                context.read<ProfileBloc>().add(
                  ProfileUpdatePasswordEvent(
                    currentPassword: currentPassword,
                    newPassword: newPassword,
                  ),
                );

                if (context.mounted) {
                  AppRouter.pop(context);
                  onPasswordUpdated?.call();
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog sửa số điện thoại
  /// 
  /// [context]: BuildContext
  /// [currentPhone]: Số điện thoại hiện tại
  /// [onPhoneUpdated]: Callback khi số điện thoại được cập nhật thành công
  static void showEditPhoneNumberDialog(
    BuildContext context,
    String? currentPhone, {
    VoidCallback? onPhoneUpdated,
  }) {
    final phoneController = TextEditingController(text: currentPhone ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sửa số điện thoại'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Số điện thoại',
                hintText: 'Nhập số điện thoại',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            const Text(
              'Lưu ý: Cập nhật số điện thoại cần xác thực OTP. Tính năng này sẽ được thêm sau.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => AppRouter.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              if (phoneController.text.trim().isNotEmpty) {
                context.read<ProfileBloc>().add(
                  ProfileUpdatePhoneNumberEvent(phoneController.text.trim()),
                );
                if (context.mounted) {
                  AppRouter.pop(context);
                  onPhoneUpdated?.call();
                }
              } else {
                AppSnackbars.showError(context, 'Vui lòng nhập số điện thoại');
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}

