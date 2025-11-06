import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart' as app_user;
import 'adapters/firebase_auth_adapter.dart';
import 'adapters/firebase_user_profile_adapter.dart';

/// Service quản lý Firebase Authentication
/// Sử dụng các adapters để thực hiện authentication và user profile operations
class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Adapters
  static FirebaseAuthAdapter? _authAdapter;
  static FirebaseUserProfileAdapter? _userProfileAdapter;

  /// Khởi tạo adapters (nếu chưa được khởi tạo)
  static void _ensureAdapters() {
    _authAdapter ??= FirebaseAuthAdapter(_auth);
    _userProfileAdapter ??= FirebaseUserProfileAdapter(_authAdapter!);
  }

  // ==================== Authentication Operations ====================

  /// Lấy User hiện tại
  static User? get currentUser {
    _ensureAdapters();
    return _authAdapter!.currentUser;
  }

  /// Stream theo dõi trạng thái đăng nhập
  static Stream<User?> get authStateChanges {
    _ensureAdapters();
    return _authAdapter!.authStateChanges;
  }

  /// Kiểm tra người dùng đã đăng nhập chưa
  static bool get isLoggedIn {
    _ensureAdapters();
    return _authAdapter!.isLoggedIn;
  }

  /// Đăng ký với email và password
  /// 
  /// [email]: Email người dùng
  /// [password]: Mật khẩu (ít nhất 6 ký tự)
  /// [displayName]: Tên hiển thị (tùy chọn) - sẽ được cập nhật sau khi đăng ký
  /// Returns: UserCredential sau khi đăng ký thành công
  /// Throws: FirebaseAuthException nếu có lỗi
  static Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _ensureAdapters();
    
    try {
      // Đăng ký với email và password
      final userCredential = await _authAdapter!.signUp(
        email: email,
        password: password,
      );

      // Cập nhật display name nếu có
      if (displayName != null && userCredential.user != null) {
        await _userProfileAdapter!.updateDisplayName(displayName);
      }

      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  /// Đăng nhập với email và password
  /// 
  /// [email]: Email người dùng
  /// [password]: Mật khẩu
  /// Returns: UserCredential sau khi đăng nhập thành công
  /// Throws: FirebaseAuthException nếu có lỗi
  static Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _ensureAdapters();
    return await _authAdapter!.signIn(
      email: email,
      password: password,
    );
  }

  /// Đăng nhập với Google
  /// 
  /// Note: Cần cấu hình Google Sign-In trong Firebase Console
  /// Returns: UserCredential sau khi đăng nhập thành công
  /// Throws: Exception nếu có lỗi
  static Future<UserCredential> signInWithGoogle() async {
    _ensureAdapters();
    return await _authAdapter!.signInWithGoogle();
  }

  /// Đăng xuất
  /// 
  /// Throws: Exception nếu có lỗi
  static Future<void> signOut() async {
    _ensureAdapters();
    return await _authAdapter!.signOut();
  }

  /// Gửi email đặt lại mật khẩu
  /// 
  /// [email]: Email cần đặt lại mật khẩu
  /// Throws: FirebaseAuthException nếu có lỗi
  static Future<void> sendPasswordResetEmail(String email) async {
    _ensureAdapters();
    return await _authAdapter!.sendPasswordResetEmail(email);
  }

  /// Xác thực lại với email và password (cho các thao tác nhạy cảm)
  /// 
  /// [email]: Email người dùng
  /// [password]: Mật khẩu hiện tại
  /// Returns: UserCredential sau khi xác thực thành công
  /// Throws: FirebaseAuthException nếu có lỗi
  static Future<UserCredential> reauthenticateWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _ensureAdapters();
    return await _authAdapter!.reauthenticateWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ==================== User Profile Operations ====================

  /// Lấy thông tin user dưới dạng AppUser model
  /// 
  /// Returns: AppUser nếu có người dùng đăng nhập, null nếu không
  static app_user.User? getAppUser() {
    _ensureAdapters();
    return _userProfileAdapter!.getAppUser();
  }

  /// Reload thông tin user từ server
  static Future<void> reloadUser() async {
    _ensureAdapters();
    return await _userProfileAdapter!.reload();
  }

  /// Gửi email xác thực
  /// 
  /// Throws: Exception nếu có lỗi hoặc email đã được xác thực
  static Future<void> sendEmailVerification() async {
    _ensureAdapters();
    return await _userProfileAdapter!.sendEmailVerification();
  }

  /// Cập nhật mật khẩu
  /// 
  /// [newPassword]: Mật khẩu mới
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  static Future<void> updatePassword(String newPassword) async {
    _ensureAdapters();
    return await _userProfileAdapter!.updatePassword(newPassword);
  }

  /// Cập nhật email (gửi email xác thực trước)
  /// 
  /// [newEmail]: Email mới
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  static Future<void> updateEmail(String newEmail) async {
    _ensureAdapters();
    return await _userProfileAdapter!.updateEmail(newEmail);
  }

  /// Cập nhật tên hiển thị
  /// 
  /// [displayName]: Tên hiển thị mới
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  static Future<void> updateDisplayName(String displayName) async {
    _ensureAdapters();
    return await _userProfileAdapter!.updateDisplayName(displayName);
  }

  /// Cập nhật photo URL
  /// 
  /// [photoUrl]: URL ảnh đại diện mới
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  static Future<void> updatePhotoURL(String photoUrl) async {
    _ensureAdapters();
    return await _userProfileAdapter!.updatePhotoURL(photoUrl);
  }

  /// Cập nhật nhiều thông tin cùng lúc
  /// 
  /// [displayName]: Tên hiển thị mới (tùy chọn)
  /// [photoUrl]: URL ảnh đại diện mới (tùy chọn)
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  static Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    _ensureAdapters();
    return await _userProfileAdapter!.updateProfile(
      displayName: displayName,
      photoUrl: photoUrl,
    );
  }

  /// Xóa tài khoản
  /// 
  /// Throws: Exception nếu có lỗi hoặc user chưa đăng nhập
  static Future<void> deleteAccount() async {
    _ensureAdapters();
    return await _userProfileAdapter!.deleteAccount();
  }

  // ==================== Utility Methods ====================

  /// Kiểm tra email đã được xác thực chưa
  /// 
  /// Returns: true nếu email đã xác thực, false nếu chưa hoặc user chưa đăng nhập
  static bool isEmailVerified() {
    _ensureAdapters();
    return _userProfileAdapter!.isEmailVerified();
  }

  /// Lấy email hiện tại
  /// 
  /// Returns: Email của user hoặc null nếu chưa đăng nhập
  static String? getEmail() {
    _ensureAdapters();
    return _userProfileAdapter!.getEmail();
  }

  /// Lấy tên hiển thị hiện tại
  /// 
  /// Returns: Tên hiển thị của user hoặc null
  static String? getDisplayName() {
    _ensureAdapters();
    return _userProfileAdapter!.getDisplayName();
  }

  /// Lấy photo URL hiện tại
  /// 
  /// Returns: Photo URL của user hoặc null
  static String? getPhotoURL() {
    _ensureAdapters();
    return _userProfileAdapter!.getPhotoURL();
  }

  /// Lấy user ID
  /// 
  /// Returns: User ID hoặc null nếu chưa đăng nhập
  static String? getUserId() {
    _ensureAdapters();
    return _userProfileAdapter!.getUserId();
  }

  /// Lấy Auth adapter (cho các use case đặc biệt)
  static FirebaseAuthAdapter? get authAdapter => _authAdapter;

  /// Lấy User Profile adapter (cho các use case đặc biệt)
  static FirebaseUserProfileAdapter? get userProfileAdapter => _userProfileAdapter;
}
