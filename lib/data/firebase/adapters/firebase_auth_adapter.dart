import 'package:firebase_auth/firebase_auth.dart';

/// Adapter cho Authentication operations với Firebase Auth
/// Xử lý: đăng ký, đăng nhập, đăng xuất, reset password
class FirebaseAuthAdapter {
  final FirebaseAuth _auth;

  FirebaseAuthAdapter(this._auth);

  /// Lấy User hiện tại
  /// 
  /// Returns: User nếu có người dùng đăng nhập, null nếu không
  User? get currentUser => _auth.currentUser;

  /// Stream theo dõi trạng thái đăng nhập
  /// 
  /// Returns: Stream<User?> - emit user khi có thay đổi trạng thái đăng nhập
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Kiểm tra người dùng đã đăng nhập chưa
  /// 
  /// Returns: true nếu có user đăng nhập, false nếu không
  bool get isLoggedIn => currentUser != null;

  /// Đăng ký với email và password
  /// 
  /// [email]: Email người dùng
  /// [password]: Mật khẩu (ít nhất 6 ký tự)
  /// Returns: UserCredential sau khi đăng ký thành công
  /// Throws: FirebaseAuthException nếu có lỗi
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi không xác định khi đăng ký: $e');
    }
  }

  /// Đăng nhập với email và password
  /// 
  /// [email]: Email người dùng
  /// [password]: Mật khẩu
  /// Returns: UserCredential sau khi đăng nhập thành công
  /// Throws: FirebaseAuthException nếu có lỗi
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi không xác định khi đăng nhập: $e');
    }
  }

  /// Đăng nhập với Google
  /// 
  /// Note: Cần cấu hình Google Sign-In trong Firebase Console
  /// Cần thêm google_sign_in package và cấu hình
  /// Returns: UserCredential sau khi đăng nhập thành công
  /// Throws: Exception nếu có lỗi
  Future<UserCredential> signInWithGoogle() async {
    try {
      // TODO: Implement Google Sign-In
      // Cần thêm google_sign_in package và cấu hình
      throw Exception('Google Sign-In chưa được cấu hình');
    } catch (e) {
      throw Exception('Lỗi khi đăng nhập với Google: $e');
    }
  }

  /// Đăng xuất
  /// 
  /// Throws: Exception nếu có lỗi
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Lỗi khi đăng xuất: $e');
    }
  }

  /// Gửi email đặt lại mật khẩu
  /// 
  /// [email]: Email cần đặt lại mật khẩu
  /// Throws: FirebaseAuthException nếu có lỗi
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi khi gửi email đặt lại mật khẩu: $e');
    }
  }

  /// Xác thực lại với credential (cho các thao tác nhạy cảm)
  /// 
  /// [credential]: AuthCredential (EmailAuthCredential, PhoneAuthCredential, etc.)
  /// Returns: UserCredential sau khi xác thực thành công
  /// Throws: FirebaseAuthException nếu có lỗi
  Future<UserCredential> reauthenticateWithCredential(
      AuthCredential credential) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      return await user.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Lỗi khi xác thực lại: $e');
    }
  }

  /// Xác thực lại với email và password
  /// 
  /// [email]: Email người dùng
  /// [password]: Mật khẩu hiện tại
  /// Returns: UserCredential sau khi xác thực thành công
  /// Throws: FirebaseAuthException nếu có lỗi
  Future<UserCredential> reauthenticateWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      return await reauthenticateWithCredential(credential);
    } catch (e) {
      throw Exception('Lỗi khi xác thực lại với email: $e');
    }
  }

  /// Xử lý FirebaseAuthException và trả về thông báo lỗi tiếng Việt
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return Exception('Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.');
      case 'email-already-in-use':
        return Exception('Email này đã được sử dụng. Vui lòng chọn email khác.');
      case 'user-not-found':
        return Exception('Không tìm thấy người dùng với email này.');
      case 'wrong-password':
        return Exception('Mật khẩu không đúng. Vui lòng thử lại.');
      case 'invalid-email':
        return Exception('Email không hợp lệ. Vui lòng kiểm tra lại.');
      case 'user-disabled':
        return Exception('Tài khoản này đã bị vô hiệu hóa.');
      case 'too-many-requests':
        return Exception('Quá nhiều yêu cầu. Vui lòng thử lại sau.');
      case 'operation-not-allowed':
        return Exception('Thao tác này không được phép.');
      case 'requires-recent-login':
        return Exception('Vui lòng đăng nhập lại để thực hiện thao tác này.');
      case 'invalid-credential':
        return Exception('Thông tin đăng nhập không hợp lệ.');
      case 'account-exists-with-different-credential':
        return Exception('Tài khoản đã tồn tại với phương thức đăng nhập khác.');
      default:
        return Exception('Lỗi xác thực: ${e.message}');
    }
  }
}




