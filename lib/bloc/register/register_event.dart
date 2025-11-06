import 'package:equatable/equatable.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

// ============ REGISTER EVENTS ============

class SubmitRegisterEvent extends RegisterEvent {
  const SubmitRegisterEvent();
}

// ============ UI UPDATE EVENTS ============

class NameRegisterEvent extends RegisterEvent {
  final String name;

  const NameRegisterEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class EmailRegisterEvent extends RegisterEvent {
  final String email;

  const EmailRegisterEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class PasswordRegisterEvent extends RegisterEvent {
  final String password;

  const PasswordRegisterEvent(this.password);

  @override
  List<Object?> get props => [password];
}

class ConfirmPasswordRegisterEvent extends RegisterEvent {
  final String confirmPassword;

  const ConfirmPasswordRegisterEvent(this.confirmPassword);

  @override
  List<Object?> get props => [confirmPassword];
}

class ShowPasswordRegisterEvent extends RegisterEvent {
  const ShowPasswordRegisterEvent();
}

class ShowConfirmPasswordRegisterEvent extends RegisterEvent {
  const ShowConfirmPasswordRegisterEvent();
}

class AgreeToTermsRegisterEvent extends RegisterEvent {
  const AgreeToTermsRegisterEvent();
}



