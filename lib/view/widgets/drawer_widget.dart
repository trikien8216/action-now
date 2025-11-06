import 'package:ActionNow/config/app_router.dart';
import 'package:ActionNow/data/firebase/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/home/home_state.dart';
import 'dialogs/app_dialogs.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final homeBloc = context.read<HomeBloc>();
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // Thông tin cá nhân - Clickable
            InkWell(
              onTap: () {
                AppRouter.pop(context);
                // Check trạng thái đăng nhập
                if (homeBloc.isLoggedIn()) {
                  // Đã đăng nhập -> vào profile
                  AppRouter.toProfile(context);
                } else {
                  // Chưa đăng nhập -> vào màn hình đăng nhập
                  AppRouter.toLogin(context);
                }
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.05),
                ),
                child: Row(
                  children: [
                    // Avatar
                    BlocBuilder<HomeBloc, HomeState>(
                      builder: (context, homeState) {
                        final displayName = context.read<HomeBloc>().getDisplayName();
                        final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
                        return CircleAvatar(
                          radius: 30,
                          backgroundColor: colorScheme.primary,
                          child: Text(
                            initial,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    // Thông tin
                    Expanded(
                      child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, homeState) {
                          final homeBloc = context.read<HomeBloc>();

                          String displayName = "";
                          String? email = "";
                          if (homeBloc.isLoggedIn()) {
                            displayName = homeBloc.getDisplayName();
                            email = FirebaseAuthService.currentUser!.email!;
                          } else {
                            displayName = "Khách";
                            email = "Vui lòng đăng nhập";
                          }
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                email,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    // Arrow icon
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),

            // Menu Items - Cài đặt
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Cài đặt thông báo
                  ListTile(
                    leading: Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
                    title: const Text(
                      'Cài đặt thông báo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      AppRouter.pop(context);
                      _showNotificationSettings(context);
                    },
                  ),
                  const Divider(height: 1),

                  // Ngôn ngữ
                  ListTile(
                    leading: Icon(Icons.language_outlined, color: colorScheme.onSurface),
                    title: const Text(
                      'Ngôn ngữ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      AppRouter.pop(context);
                      _showLanguageSettings(context);
                    },
                  ),
                  const Divider(height: 1),

                  // Thông tin nhà phát triển
                  ListTile(
                    leading: Icon(Icons.info_outline, color: colorScheme.onSurface),
                    title: const Text(
                      'Thông tin nhà phát triển',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    onTap: () {
                      AppRouter.pop(context);
                      _showDeveloperInfo(context);
                    },
                  ),
                  const Divider(height: 1),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageSettings(BuildContext context) {
    AppDialogs.showLanguageSettingsDialog(context);
  }

  void _showDeveloperInfo(BuildContext context) {
    AppDialogs.showDeveloperInfoDialog(context);
  }

  void _showNotificationSettings(BuildContext context) {
    AppDialogs.showNotificationSettingsDialog(context);
  }

}
