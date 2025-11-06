import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/hive/hive_service.dart';
// TEMPORARY: Firebase Realtime Database disabled
// import 'data/firebase/firebase_auth_service.dart';
// import 'data/firebase/firebase_database_service.dart';
import 'data/local/local_auth_service.dart';
import 'data/local/user_preferences_service.dart';
import 'config/app_router.dart';
import 'config/app_theme.dart';
import 'data/firebase/firebase_options.dart';
import 'bloc/task/task_bloc.dart';
import 'bloc/list_task/list_task_bloc.dart';
import 'bloc/home/home_bloc.dart';
import 'bloc/login/login_bloc.dart';
import 'bloc/register/register_bloc.dart';
import 'bloc/profile/profile_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive (local database)
  await HiveService.init();
  
  // Initialize LocalAuthService (for remember me)
  await LocalAuthService.init();
  
  // Initialize UserPreferencesService (for user name, etc.)
  await UserPreferencesService.init();
  
  // Initialize Firebase (có xử lý lỗi)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TEMPORARY: Firebase Realtime Database disabled
  // // Initialize Firebase services
  // // Note: FirebaseAuthService không cần init vì sử dụng FirebaseAuth.instance trực tiếp
  // // FirebaseDatabaseService sẽ được khởi tạo sau khi user đăng nhập
  // // Hoặc nếu có user đã đăng nhập sẵn (ví dụ: remember me)
  // try {
  //   if (FirebaseAuthService.isLoggedIn) {
  //     await FirebaseDatabaseService.init();
  //   }
  // } catch (e) {
  //   print('Không thể khởi tạo FirebaseDatabaseService: $e');
  //   // Continue - sẽ init sau khi user đăng nhập
  // }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => HomeBloc()),
        BlocProvider(create: (_) => LoginBloc()),
        BlocProvider(create: (_) => RegisterBloc()),
        BlocProvider(create: (_) => ListTaskBloc()),
        BlocProvider(create: (_) => TaskBloc()),
        BlocProvider(create: (_) => ProfileBloc()),
      ],
      child: MaterialApp(
        title: 'Action Now',
        debugShowCheckedModeBanner: false,
        theme: vibrantTheme,
        routes: AppRouter.routes,
        initialRoute: AppRouter.loading, // Start with loading screen
      ),
    );
  }
}
