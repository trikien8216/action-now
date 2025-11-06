import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/firebase/firebase_database_service.dart';
import '../../data/local/local_auth_service.dart';
import '../../data/firebase/firebase_auth_service.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<HomeLoadEvent>(_onLoad);
    on<HomeRefreshEvent>(_onRefresh);

    // logout
    on<SubmitLogoutEvent>(_onLogout);
    
    _initialize();
    _listenToAuthChanges();
  }

  /// Initialize và load user preferences
  Future<void> _initialize() async {
    add(const HomeLoadEvent());
  }

  Future<void> _onLoad(
    HomeLoadEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadUserData(emit);
  }
  //
  /// Load user data từ Firebase Auth
  Future<void> _loadUserData(Emitter<HomeState> emit) async {
    emit(const HomeLoading());
    try {
      final isLoggedIn = FirebaseAuthService.isLoggedIn;
      String displayName;

      if (isLoggedIn) {
        final user = FirebaseAuthService.currentUser;
        if (user?.displayName != null && user!.displayName!.isNotEmpty) {
          displayName = user.displayName!;
        } else if (user?.email != null) {
          final email = user!.email!;
          displayName = email.split('@').first;
        } else {
          displayName = 'Bạn';
        }
      } else {
        displayName = 'Khách';
      }

      emit(HomeLoaded(
        displayName: displayName,
        isLoggedIn: isLoggedIn,
      ));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> _onLogout(
    SubmitLogoutEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLogoutLoading());

    try {
      // 1. Đăng xuất khỏi Firebase Auth
      await FirebaseAuthService.signOut();

      // 2. Stop Firebase Database listener
      FirebaseDatabaseService.stopListening();

      // 3. Clear local credentials (remember me)
      await LocalAuthService.clearCredentials();

      // 4. Reload user data sau khi logout
      await _loadUserData(emit);
      
      emit(const HomeLogoutSuccess());
    } catch (e) {
      emit(HomeLogoutError('Lỗi khi đăng xuất: ${e.toString()}'));
    }
  }


  /// Lắng nghe thay đổi auth state
  void _listenToAuthChanges() {
    FirebaseAuthService.authStateChanges.listen((user) {
      add(const HomeLoadEvent());
    });
  }


  Future<void> _onRefresh(
    HomeRefreshEvent event,
    Emitter<HomeState> emit,
  ) async {
    await _loadUserData(emit);
  }

  /// Get current display name (from state)
  String getDisplayName() {
    if (state is HomeLoaded) {
      return (state as HomeLoaded).displayName;
    }
    return 'Khách';
  }

  /// Check if logged in (from state)
  bool isLoggedIn() {
    if (state is HomeLoaded) {
      return (state as HomeLoaded).isLoggedIn;
    }
    return false;
  }
}

