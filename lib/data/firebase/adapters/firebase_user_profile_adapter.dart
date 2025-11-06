import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart' as app_user;
import 'firebase_auth_adapter.dart';

/// Adapter cho User Profile operations với Firebase Auth
/// Xử lý: cập nhật thông tin user, email verification, xóa tài khoản
class FirebaseUserProfileAdapter {
  final FirebaseAuthAdapter _authAdapter;

  FirebaseUserProfileAdapter(this._authAdapter);

  /// Lấy User hiện tại
  /// 
  /// Returns: User nếu có người dùng đăng nhập, null nếu không
  User? get currentUser => _authAdapter.currentUser;

  /// Lấy thông tin user dưới dạng AppUser model
  /// 
  /// Returns: AppUser nếu có người dùng đăng nhập, null nếu không
  app_user.User? getAppUser() {
    final user = currentUser;
    if (user == null) return null;

    return app_user.User(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      createdAt: user.metadata.creationTime,
      lastSignIn: user.metadata.lastSignInTime,
    );
  }

  /// Reload thông tin user từ server
  /// 
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  Future<void> reload() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      await user.reload();
    } catch (e) {
      throw Exception('Lỗi khi reload thông tin user: $e');
    }
  }

  /// Gửi email xác thực
  /// 
  /// Throws: Exception nếu có lỗi hoặc email đã được xác thực
  Future<void> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      if (user.emailVerified) {
        throw Exception('Email đã được xác thực');
      }
      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Lỗi khi gửi email xác thực: $e');
    }
  }

  /// Cập nhật mật khẩu
  /// 
  /// [newPassword]: Mật khẩu mới
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  Future<void> updatePassword(String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật mật khẩu: $e');
    }
  }

  /// Cập nhật email (gửi email xác thực trước)
  /// 
  /// [newEmail]: Email mới
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  Future<void> updateEmail(String newEmail) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      // Sử dụng verifyBeforeUpdateEmail thay vì updateEmail (deprecated)
      await user.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi khi cập nhật email: $e');
    }
  }

  /// Cập nhật tên hiển thị
  /// 
  /// [displayName]: Tên hiển thị mới
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  Future<void> updateDisplayName(String displayName) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      await user.updateProfile(displayName: displayName);
      await user.reload();
    } catch (e) {
      throw Exception('Lỗi khi cập nhật tên hiển thị: $e');
    }
  }

  /// Cập nhật photo URL
  /// 
  /// [photoUrl]: URL ảnh đại diện mới
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  Future<void> updatePhotoURL(String photoUrl) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      await user.updateProfile(photoURL: photoUrl);
      await user.reload();
    } catch (e) {
      throw Exception('Lỗi khi cập nhật ảnh đại diện: $e');
    }
  }

  /// Cập nhật nhiều thông tin cùng lúc
  /// 
  /// [displayName]: Tên hiển thị mới (tùy chọn)
  /// [photoUrl]: URL ảnh đại diện mới (tùy chọn)
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      await user.updateProfile(
        displayName: displayName,
        photoURL: photoUrl,
      );
      await user.reload();
    } catch (e) {
      throw Exception('Lỗi khi cập nhật thông tin: $e');
    }
  }

  /// Xóa tài khoản
  /// 
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi khi xóa tài khoản: $e');
    }
  }

  /// Kiểm tra email đã được xác thực chưa
  /// 
  /// Returns: true nếu email đã xác thực, false nếu chưa hoặc user chưa đăng nhập
  bool isEmailVerified() {
    return currentUser?.emailVerified ?? false;
  }

  /// Lấy email hiện tại
  /// 
  /// Returns: Email của user hoặc null nếu chưa đăng nhập
  String? getEmail() {
    return currentUser?.email;
  }

  /// Lấy tên hiển thị hiện tại
  /// 
  /// Returns: Tên hiển thị của user hoặc null
  String? getDisplayName() {
    return currentUser?.displayName;
  }

  /// Lấy photo URL hiện tại
  /// 
  /// Returns: Photo URL của user hoặc null
  String? getPhotoURL() {
    return currentUser?.photoURL;
  }

  /// Lấy user ID
  /// 
  /// Returns: User ID hoặc null nếu chưa đăng nhập
  String? getUserId() {
    return currentUser?.uid;
  }

  /// Xử lý FirebaseAuthException và trả về thông báo lỗi tiếng Việt
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'requires-recent-login':
        return Exception('Vui lòng đăng nhập lại để thực hiện thao tác này.');
      case 'weak-password':
        return Exception('Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.');
      case 'email-already-in-use':
        return Exception('Email này đã được sử dụng. Vui lòng chọn email khác.');
      case 'invalid-email':
        return Exception('Email không hợp lệ. Vui lòng kiểm tra lại.');
      case 'user-not-found':
        return Exception('Không tìm thấy người dùng.');
      case 'too-many-requests':
        return Exception('Quá nhiều yêu cầu. Vui lòng thử lại sau.');
      default:
        return Exception('Lỗi xác thực: ${e.message}');
    }
  }
}




