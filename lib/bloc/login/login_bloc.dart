import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/firebase/firebase_auth_service.dart';
import '../../data/firebase/firebase_database_service.dart';
import '../../data/local/local_auth_service.dart';
import '../../action/act_auth.dart';
import 'login_event.dart';
import 'login_state.dart';

/// LoginBloc - Quản lý login state và operations
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  // UI State cho LoginScreen
  LoginUIState _loginUIState = const LoginUIState();
  
  bool _autoLoginAttempted = false;

  LoginBloc() : super(const LoginInitial()) {
    // Initialization
    on<LoginLoadSavedCredentials>(_onLoadSavedCredentials);

    // login
    on<SubmitLoginEvent>(_onLogin);

    // UI
    on<EmailLoginEvent>(_onUpdateEmail);
    on<PasswordLoginEvent>(_onUpdatePassword);
    on<ShowPasswordLoginEvent>(_onTogglePasswordVisibility);
    on<RememberMeLogin>(_onToggleRememberMe);

    _initialize();
  }

  /// Initialize và load saved credentials
  Future<void> _initialize() async {
    add(const LoginLoadSavedCredentials());
  }

  Future<void> _onLoadSavedCredentials(
    LoginLoadSavedCredentials event,
    Emitter<LoginState> emit,
  ) async {
    emit(const LoginLoadingSavedCredentials());
    
    try {
      // Chờ một chút để đảm bảo LocalAuthService đã được init
      await Future.delayed(const Duration(milliseconds: 100));
      
      final credentials = LocalAuthService.getSavedCredentials();
      
      if (credentials != null && credentials['email'] != null && credentials['password'] != null) {
        final email = credentials['email'] as String;
        final password = credentials['password'] as String;
        
        _loginUIState = _loginUIState.copyWith(
          email: email,
          password: password,
          rememberMe: true,
        );
        emit(LoginCredentialsLoaded(
          email: email,
          password: password,
          hasCredentials: true,
        ));
      } else {
        emit(const LoginCredentialsLoaded(
          email: null,
          password: null,
          hasCredentials: false,
        ));
      }
    } catch (e) {
      emit(LoginError('Lỗi khi load saved credentials: ${e.toString()}'));
    }
  }

  Future<void> _onLogin(
    SubmitLoginEvent event,
    Emitter<LoginState> emit,
  ) async {
    final email = _loginUIState.email.trim();
    final password = _loginUIState.password;
    final rememberMe = _loginUIState.rememberMe;

    if (!ActAuth.validateLoginForm(email, password)) {
      emit(const LoginError('Vui lòng nhập đầy đủ thông tin'));
      return;
    }

    emit(const LoginLoading());

    try {
      await FirebaseAuthService.signInWithEmail(
        email: email,
        password: password,
      );
      await FirebaseDatabaseService.reloadForUser();

      if (rememberMe) {
        await LocalAuthService.saveCredentials(email, password);
      } else {
        await LocalAuthService.clearCredentials();
      }
      emit(const LoginSuccess());
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }

  void _onUpdateEmail(
    EmailLoginEvent event,
    Emitter<LoginState> emit,
  ) {
    _loginUIState = _loginUIState.copyWith(
      email: event.email,
      isFormValid: ActAuth.validateLoginForm(event.email, _loginUIState.password),
    );
    emit(_loginUIState);
  }

  void _onUpdatePassword(
    PasswordLoginEvent event,
    Emitter<LoginState> emit,
  ) {
    _loginUIState = _loginUIState.copyWith(
      password: event.password,
      isFormValid: ActAuth.validateLoginForm(_loginUIState.email, event.password),
    );
    emit(_loginUIState);
  }

  void _onTogglePasswordVisibility(
    ShowPasswordLoginEvent event,
    Emitter<LoginState> emit,
  ) {
    _loginUIState = _loginUIState.copyWith(
      obscurePassword: !_loginUIState.obscurePassword,
    );
    emit(_loginUIState);
  }

  void _onToggleRememberMe(
    RememberMeLogin event,
    Emitter<LoginState> emit,
  ) {
    _loginUIState = _loginUIState.copyWith(
      rememberMe: !_loginUIState.rememberMe,
    );
    emit(_loginUIState);
  }

  // ============ GETTERS ============

  String? validateLoginEmail(String? value) => ActAuth.validateLoginEmail(value);
  String? validateLoginPassword(String? value) => ActAuth.validateLoginPassword(value);
  LoginUIState get loginUIState => _loginUIState;
  bool get autoLoginAttempted => _autoLoginAttempted;
  bool get hasSavedCredentials => LocalAuthService.hasSavedCredentials();
}

