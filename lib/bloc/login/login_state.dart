import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginLoadingSavedCredentials extends LoginState {
  const LoginLoadingSavedCredentials();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}

class LoginCredentialsLoaded extends LoginState {
  final String? email;
  final String? password;
  final bool hasCredentials;

  const LoginCredentialsLoaded({
    this.email,
    this.password,
    required this.hasCredentials,
  });

  @override
  List<Object?> get props => [email, password, hasCredentials];
}

/// UI state cho LoginScreen
class LoginUIState extends LoginState {
  final String email;
  final String password;
  final bool obscurePassword;
  final bool rememberMe;
  final bool isFormValid;

  const LoginUIState({
    this.email = '',
    this.password = '',
    this.obscurePassword = true,
    this.rememberMe = false,
    this.isFormValid = false,
  });

  LoginUIState copyWith({
    String? email,
    String? password,
    bool? obscurePassword,
    bool? rememberMe,
    bool? isFormValid,
  }) {
    return LoginUIState(
      email: email ?? this.email,
      password: password ?? this.password,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      rememberMe: rememberMe ?? this.rememberMe,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  @override
  List<Object?> get props => [email, password, obscurePassword, rememberMe, isFormValid];
}



