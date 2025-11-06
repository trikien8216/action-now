import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/home/home_state.dart';
import '../../bloc/profile/profile_event.dart';
import '../../config/app_router.dart';
import '../../data/firebase/firebase_auth_service.dart';
import '../../bloc/list_task/list_task_bloc.dart';
import '../../bloc/list_task/list_task_event.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_event.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/profile/profile_state.dart';
import '../widgets/snackbars/app_snackbars.dart';
import '../widgets/dialogs/app_dialogs.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listener: (context, homeState) {
            if (homeState is HomeLogoutSuccess) {
              // Clear ListTaskBloc data
              context.read<ListTaskBloc>().add(
                const ListTaskClearAfterLogoutEvent(),
              );
              // Show success message
              AppSnackbars.showLogoutSuccess(context);
              // Navigate về Home
              if (context.mounted) {
                AppRouter.pop(context);
              }
            } else if (homeState is HomeLogoutError) {
              AppSnackbars.showError(context, homeState.message);
            }
          },
        ),
        BlocListener<ProfileBloc, ProfileState>(
          listener: (context, profileState) {
            if (profileState is ProfileUpdateSuccess) {
              AppSnackbars.showSuccess(context, profileState.message);
            } else if (profileState is ProfileError) {
              AppSnackbars.showError(context, profileState.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: () => AppRouter.pop(context),
          ),
          title: const Text(
            'Thông tin cá nhân',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: colorScheme.primary.withValues(
                        alpha: 0.8,
                      ),
                      child: Text(
                        _getDisplayNameInitial(context),
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Thông tin cá nhân
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Tên
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, profileState) {
                        final displayName = profileState is ProfileLoaded
                            ? profileState.displayName
                            : (FirebaseAuthService.isLoggedIn
                                  ? FirebaseAuthService.getDisplayName()
                                  : 'Khách');
                        return _buildInfoCard(
                          context: context,
                          icon: Icons.person_outline,
                          title: 'Họ và tên',
                          value: displayName ?? 'Chưa có',
                          onTap: FirebaseAuthService.isLoggedIn
                              ? () {
                                  AppDialogs.showEditDisplayNameDialog(
                                    context,
                                    displayName,
                                    onNameUpdated: () {
                                      context.read<ProfileBloc>().add(
                                        const ProfileLoadEvent(),
                                      );
                                      context.read<HomeBloc>().add(
                                        const HomeRefreshEvent(),
                                      );
                                    },
                                  );
                                }
                              : () {},
                          isEdit: true,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, profileState) {
                        final email = profileState is ProfileLoaded
                            ? profileState.email
                            : _getEmail();
                        return _buildInfoCard(
                          context: context,
                          icon: Icons.email_outlined,
                          title: 'Email',
                          value: email ?? 'Chưa có email',
                          onTap: () {},
                          isEdit: false,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Số điện thoại
                    BlocBuilder<ProfileBloc, ProfileState>(
                      builder: (context, profileState) {
                        final phoneNumber = profileState is ProfileLoaded
                            ? profileState.phoneNumber
                            : _getPhoneNumber();
                        return _buildInfoCard(
                          context: context,
                          icon: Icons.phone_outlined,
                          title: 'Số điện thoại',
                          value: phoneNumber ?? 'Chưa có',
                          onTap: FirebaseAuthService.isLoggedIn
                              ? () {
                                  AppDialogs.showEditPhoneNumberDialog(
                                    context,
                                    phoneNumber,
                                    onPhoneUpdated: () {
                                      context.read<ProfileBloc>().add(
                                        const ProfileLoadEvent(),
                                      );
                                    },
                                  );
                                }
                              : () {},
                          isEdit: false,
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Mật khẩu
                    if (FirebaseAuthService.isLoggedIn)
                      _buildInfoCard(
                        context: context,
                        icon: Icons.lock_outline,
                        title: 'Mật khẩu',
                        value: '••••••••',
                        onTap: () {
                          AppDialogs.showEditPasswordDialog(
                            context,
                            onPasswordUpdated: () {
                              context.read<ProfileBloc>().add(
                                const ProfileLoadEvent(),
                              );
                            },
                          );
                        },
                        isEdit: true,
                      ),
                    if (FirebaseAuthService.isLoggedIn)
                      const SizedBox(height: 16),
                    const SizedBox(height: 24),

                    // Button: Đăng nhập hoặc Đăng xuất
                    if (FirebaseAuthService.isLoggedIn)
                      // Đăng xuất button (khi đã đăng nhập)
                      BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, homeState) {
                          final isLoading = homeState is HomeLogoutLoading;
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            child: ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => _handleLogout(context),
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.logout),
                              label: Text(
                                isLoading ? 'Đang đăng xuất...' : 'Đăng xuất',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.onError,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      // Đăng nhập button (khi chưa đăng nhập)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 0),
                        child: ElevatedButton.icon(
                          onPressed: () => _handleLogin(context),
                          icon: const Icon(Icons.login),
                          label: const Text('Đăng nhập'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xử lý đăng nhập
  Future<void> _handleLogin(BuildContext context) async {
    // Navigate đến màn hình đăng nhập
    AppRouter.toLogin(context);
  }

  /// Xử lý đăng xuất
  Future<void> _handleLogout(BuildContext context) async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    // Sử dụng HomeBloc để xử lý logout
    if (context.mounted) {
      context.read<HomeBloc>().add(const SubmitLogoutEvent());
    }
  }

  /// Lấy chữ cái đầu của tên để hiển thị trong avatar
  String _getDisplayNameInitial(BuildContext context) {
    final name = context.read<HomeBloc>().getDisplayName();
    if (name.isNotEmpty && name != 'Khách') {
      return name[0].toUpperCase();
    }
    return 'K'; // K cho Khách
  }

  /// Lấy email từ Firebase Auth
  String _getEmail() {
    if (FirebaseAuthService.isLoggedIn) {
      final user = FirebaseAuthService.currentUser;
      return user?.email ?? 'Chưa có email';
    }
    return 'Chưa có email';
  }

  /// Lấy số điện thoại từ Firebase Auth
  String _getPhoneNumber() {
    if (FirebaseAuthService.isLoggedIn) {
      final user = FirebaseAuthService.currentUser;
      return user?.phoneNumber ?? 'Chưa có';
    }
    return 'Chưa có';
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    required bool isEdit,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return InkWell(
      onTap: isEdit ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isEdit ? colorScheme.surface : Colors.black12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
