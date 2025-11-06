import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/firebase/firebase_auth_service.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileInitial()) {
    on<ProfileLoadEvent>(_onLoad);
    on<ProfileUpdateDisplayNameEvent>(_onUpdateDisplayName);
    on<ProfileUpdatePasswordEvent>(_onUpdatePassword);
    on<ProfileUpdatePhoneNumberEvent>(_onUpdatePhoneNumber);

    add(const ProfileLoadEvent());
  }

  Future<void> _onLoad(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      if (!FirebaseAuthService.isLoggedIn) {
        emit(const ProfileLoaded(
          displayName: null,
          email: null,
          phoneNumber: null,
        ));
        return;
      }

      final user = FirebaseAuthService.currentUser;
      emit(ProfileLoaded(
        displayName: user?.displayName,
        email: user?.email,
        phoneNumber: user?.phoneNumber,
      ));
    } catch (e) {
      emit(ProfileError('Lỗi khi load thông tin: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateDisplayName(
    ProfileUpdateDisplayNameEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      await FirebaseAuthService.updateDisplayName(event.displayName);
      await FirebaseAuthService.reloadUser();
      
      // Reload profile data
      final user = FirebaseAuthService.currentUser;
      emit(ProfileLoaded(
        displayName: user?.displayName,
        email: user?.email,
        phoneNumber: user?.phoneNumber,
      ));
      emit(ProfileUpdateSuccess('Đã cập nhật tên thành công'));
    } catch (e) {
      emit(ProfileError('Lỗi khi cập nhật tên: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePassword(
    ProfileUpdatePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // Xác thực lại với mật khẩu hiện tại
      final email = FirebaseAuthService.getEmail();
      if (email == null) {
        throw Exception('Không tìm thấy email');
      }

      await FirebaseAuthService.reauthenticateWithEmailAndPassword(
        email: email,
        password: event.currentPassword,
      );

      // Cập nhật mật khẩu mới
      await FirebaseAuthService.updatePassword(event.newPassword);
      
      emit(ProfileUpdateSuccess('Đã cập nhật mật khẩu thành công'));
      
      // Reload profile
      add(const ProfileLoadEvent());
    } catch (e) {
      emit(ProfileError('Lỗi khi cập nhật mật khẩu: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePhoneNumber(
    ProfileUpdatePhoneNumberEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // Firebase Auth không có method trực tiếp để update phone number
      // Cần sử dụng PhoneAuthProvider và verify OTP
      // Tạm thời chỉ thông báo là tính năng này cần verify OTP
      emit(ProfileError('Cập nhật số điện thoại cần xác thực OTP. Tính năng này sẽ được thêm sau.'));
    } catch (e) {
      emit(ProfileError('Lỗi khi cập nhật số điện thoại: ${e.toString()}'));
    }
  }
}

