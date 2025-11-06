import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

// ============ INITIALIZATION EVENTS ============

class LoginLoadSavedCredentials extends LoginEvent {
  const LoginLoadSavedCredentials();
}

// ============ LOGIN EVENTS ============

class SubmitLoginEvent extends LoginEvent {
  const SubmitLoginEvent();
}

// class LoginAutoLoginEvent extends LoginEvent {
//   final String? email;
//   final String? password;
//
//   const LoginAutoLoginEvent({this.email, this.password});
//
//   @override
//   List<Object?> get props => [email, password];
// }
//
// ============ UI UPDATE EVENTS ============

class EmailLoginEvent extends LoginEvent {
  final String email;

  const EmailLoginEvent(this.email);

  @override
  List<Object?> get props => [email];
}

class PasswordLoginEvent extends LoginEvent {
  final String password;

  const PasswordLoginEvent(this.password);

  @override
  List<Object?> get props => [password];
}

class ShowPasswordLoginEvent extends LoginEvent {
  const ShowPasswordLoginEvent();
}

class RememberMeLogin extends LoginEvent {
  const RememberMeLogin();
}

// class LoginResetUI extends LoginEvent {
//   const LoginResetUI();
// }
//
// class LoginMarkAutoLoginAttempted extends LoginEvent {
//   const LoginMarkAutoLoginAttempted();
// }



