import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/firebase/firebase_auth_service.dart';
import '../../data/firebase/firebase_database_service.dart';
import '../../action/act_auth.dart';
import 'register_event.dart';
import 'register_state.dart';

/// RegisterBloc - Quản lý register state và operations
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  // UI State cho RegisterScreen
  RegisterUIState _registerUIState = const RegisterUIState();

  RegisterBloc() : super(const RegisterInitial()) {
    // register
    on<SubmitRegisterEvent>(_onRegister);
    
    // UI updates
    on<NameRegisterEvent>(_onUpdateName);
    on<EmailRegisterEvent>(_onUpdateEmail);
    on<PasswordRegisterEvent>(_onUpdatePassword);
    on<ConfirmPasswordRegisterEvent>(_onUpdateConfirmPassword);
    on<ShowPasswordRegisterEvent>(_onTogglePasswordVisibility);
    on<ShowConfirmPasswordRegisterEvent>(_onToggleConfirmPasswordVisibility);
    on<AgreeToTermsRegisterEvent>(_onToggleAgreeToTerms);
  }

  Future<void> _onRegister(
    SubmitRegisterEvent event,
    Emitter<RegisterState> emit,
  ) async {
    final name = _registerUIState.name.trim();
    final email = _registerUIState.email.trim();
    final password = _registerUIState.password;
    final confirmPassword = _registerUIState.confirmPassword;

    if (!ActAuth.validateRegisterForm(name, email, password, confirmPassword)) {
      emit(const RegisterError('Vui lòng nhập đầy đủ và đúng thông tin'));
      return;
    }

    if (!_registerUIState.agreeToTerms) {
      emit(const RegisterError('Vui lòng đồng ý với Điều khoản và Chính sách bảo mật'));
      return;
    }

    emit(const RegisterLoading());

    try {
      await FirebaseAuthService.signUpWithEmail(
        email: email,
        password: password,
        displayName: name.isNotEmpty ? name : null,
      );
      await FirebaseDatabaseService.reloadForUser();
      emit(const RegisterSuccess());
    } catch (e) {
      emit(RegisterError(e.toString()));
    }
  }

  void _onUpdateName(
    NameRegisterEvent event,
    Emitter<RegisterState> emit,
  ) {
    _registerUIState = _registerUIState.copyWith(
      name: event.name,
      isFormValid: ActAuth.validateRegisterForm(
        event.name,
        _registerUIState.email,
        _registerUIState.password,
        _registerUIState.confirmPassword,
      ),
    );
    emit(_registerUIState);
  }

  void _onUpdateEmail(
    EmailRegisterEvent event,
    Emitter<RegisterState> emit,
  ) {
    _registerUIState = _registerUIState.copyWith(
      email: event.email,
      isFormValid: ActAuth.validateRegisterForm(
        _registerUIState.name,
        event.email,
        _registerUIState.password,
        _registerUIState.confirmPassword,
      ),
    );
    emit(_registerUIState);
  }

  void _onUpdatePassword(
    PasswordRegisterEvent event,
    Emitter<RegisterState> emit,
  ) {
    _registerUIState = _registerUIState.copyWith(
      password: event.password,
      isFormValid: ActAuth.validateRegisterForm(
        _registerUIState.name,
        _registerUIState.email,
        event.password,
        _registerUIState.confirmPassword,
      ),
    );
    emit(_registerUIState);
  }

  void _onUpdateConfirmPassword(
    ConfirmPasswordRegisterEvent event,
    Emitter<RegisterState> emit,
  ) {
    _registerUIState = _registerUIState.copyWith(
      confirmPassword: event.confirmPassword,
      isFormValid: ActAuth.validateRegisterForm(
        _registerUIState.name,
        _registerUIState.email,
        _registerUIState.password,
        event.confirmPassword,
      ),
    );
    emit(_registerUIState);
  }

  void _onTogglePasswordVisibility(
    ShowPasswordRegisterEvent event,
    Emitter<RegisterState> emit,
  ) {
    _registerUIState = _registerUIState.copyWith(
      obscurePassword: !_registerUIState.obscurePassword,
    );
    emit(_registerUIState);
  }

  void _onToggleConfirmPasswordVisibility(
    ShowConfirmPasswordRegisterEvent event,
    Emitter<RegisterState> emit,
  ) {
    _registerUIState = _registerUIState.copyWith(
      obscureConfirmPassword: !_registerUIState.obscureConfirmPassword,
    );
    emit(_registerUIState);
  }

  void _onToggleAgreeToTerms(
    AgreeToTermsRegisterEvent event,
    Emitter<RegisterState> emit,
  ) {
    _registerUIState = _registerUIState.copyWith(
      agreeToTerms: !_registerUIState.agreeToTerms,
    );
    emit(_registerUIState);
  }

  // ============ GETTERS ============

  String? validateRegisterName(String? value) => ActAuth.validateRegisterName(value);
  String? validateRegisterEmail(String? value) => ActAuth.validateRegisterEmail(value);
  String? validateRegisterPassword(String? value) => ActAuth.validateRegisterPassword(value);
  String? validateRegisterConfirmPassword(String? value) => 
      ActAuth.validateRegisterConfirmPassword(value, _registerUIState.password);
  RegisterUIState get registerUIState => _registerUIState;
}



