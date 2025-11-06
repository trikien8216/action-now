import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/app_router.dart';
import '../../bloc/register/register_bloc.dart';
import '../../bloc/register/register_event.dart';
import '../../bloc/register/register_state.dart';
import '../../bloc/list_task/list_task_bloc.dart';
import '../../bloc/list_task/list_task_event.dart';
import '../widgets/snackbars/app_snackbars.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cập nhật text fields từ UI state nếu có thay đổi
    final registerState = context.watch<RegisterBloc>().state;
    if (registerState is RegisterUIState) {
      if (_nameController.text != registerState.name) {
        _nameController.text = registerState.name;
      }
      if (_emailController.text != registerState.email) {
        _emailController.text = registerState.email;
      }
      if (_passwordController.text != registerState.password) {
        _passwordController.text = registerState.password;
      }
      if (_confirmPasswordController.text != registerState.confirmPassword) {
        _confirmPasswordController.text = registerState.confirmPassword;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      // Đăng ký với RegisterBloc
      context.read<RegisterBloc>().add(const SubmitRegisterEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterError) {
          // Nếu lỗi là về agree to terms, hiển thị warning snackbar
          if (state.message.contains('Điều khoản')) {
            AppSnackbars.showAgreeTermsWarning(context);
          } else {
            AppSnackbars.showRegisterError(context, state.message);
          }
        } else if (state is RegisterSuccess) {
          AppSnackbars.showRegisterSuccess(context);
          if (!mounted) return;
          // Reload task lists từ Firebase (sẽ rỗng vì là tài khoản mới)
          context.read<ListTaskBloc>().add(
            const ListTaskReloadAfterLoginEvent(),
          );
          // Navigate về home thay vì login vì user đã được đăng nhập tự động
          AppRouter.toHome(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () => AppRouter.pop(context),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<RegisterBloc, RegisterState>(
            builder: (context, registerState) {
              final isLoading = registerState is RegisterLoading;
              final registerUIState = context.read<RegisterBloc>().registerUIState;

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        'Tạo tài khoản',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Điền thông tin để đăng ký',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Name field
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Họ và tên',
                          hintText: 'Nhập họ và tên của bạn',
                          prefixIcon: const Icon(Icons.person_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: (value) => context.read<RegisterBloc>().validateRegisterName(value),
                        onChanged: (value) => context.read<RegisterBloc>().add(NameRegisterEvent(value)),
                      ),
                      const SizedBox(height: 20),

                      // Email field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'Nhập email của bạn',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: (value) => context.read<RegisterBloc>().validateRegisterEmail(value),
                        onChanged: (value) => context.read<RegisterBloc>().add(EmailRegisterEvent(value)),
                      ),
                      const SizedBox(height: 20),

                      // Password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: registerUIState.obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          hintText: 'Nhập mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              registerUIState.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => context.read<RegisterBloc>().add(const ShowPasswordRegisterEvent()),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: (value) => context.read<RegisterBloc>().validateRegisterPassword(value),
                        onChanged: (value) => context.read<RegisterBloc>().add(PasswordRegisterEvent(value)),
                      ),
                      const SizedBox(height: 20),

                      // Confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: registerUIState.obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu',
                          hintText: 'Nhập lại mật khẩu',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              registerUIState.obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () => context.read<RegisterBloc>().add(const ShowConfirmPasswordRegisterEvent()),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                        validator: (value) => context.read<RegisterBloc>().validateRegisterConfirmPassword(value),
                        onChanged: (value) => context.read<RegisterBloc>().add(ConfirmPasswordRegisterEvent(value)),
                      ),
                      const SizedBox(height: 20),

                      // Terms and conditions
                      Row(
                        children: [
                          Checkbox(
                            value: registerUIState.agreeToTerms,
                            onChanged: (value) => context.read<RegisterBloc>().add(const AgreeToTermsRegisterEvent()),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => context.read<RegisterBloc>().add(const AgreeToTermsRegisterEvent()),
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(text: 'Tôi đồng ý với '),
                                    TextSpan(
                                      text: 'Điều khoản',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' và '),
                                    TextSpan(
                                      text: 'Chính sách bảo mật',
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Register button
                      ElevatedButton(
                        onPressed: isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : const Text(
                                'Đăng ký',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Đã có tài khoản? ',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              AppRouter.toLogin(context);
                            },
                            child: const Text('Đăng nhập ngay'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
