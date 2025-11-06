import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task.dart';
import '../../data/hive/hive_service.dart';
import '../../data/local/local_auth_service.dart';
import '../../data/firebase/firebase_auth_service.dart';
import '../../data/firebase/firebase_database_service.dart';
import 'list_task_event.dart';
import 'list_task_state.dart';

class ListTaskBloc extends Bloc<ListTaskEvent, ListTaskState> {
  ListTaskBloc() : super(const ListTaskInitial()) {
    on<ListTaskLoadEvent>(_onLoadTaskLists);
    on<ListTaskAddEvent>(_onAddTaskList);
    on<ListTaskUpdateEvent>(_onUpdateTaskList);
    on<ListTaskDeleteEvent>(_onDeleteTaskList);
    on<ListTaskRefreshEvent>(_onRefresh);
    on<ListTaskReloadAfterLoginEvent>(_onReloadAfterLogin);
    on<ListTaskClearAfterLogoutEvent>(_onClearAfterLogout);

    _initialize();
  }

  bool _isSyncing = false;

  /// Initialize and load data
  Future<void> _initialize() async {
    try {
      add(const ListTaskLoadEvent());
      _listenToHiveChanges();
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi initialize: $e');
      add(const ListTaskLoadEvent());
      _listenToHiveChanges();
    }
  }

  Future<void> _onLoadTaskLists(
    ListTaskLoadEvent event,
    Emitter<ListTaskState> emit,
  ) async {
    await _loadTaskLists(emit);
  }

  /// Load initial data
  /// - Nếu đã đăng nhập: Load từ Firebase (không lưu vào Hive)
  /// - Nếu chưa đăng nhập: Load từ Hive
  Future<void> _loadTaskLists(Emitter<ListTaskState> emit) async {
    emit(const ListTaskLoading());
    try {
      // Nếu đã đăng nhập, load từ Firebase
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          final firebaseTaskLists = await FirebaseDatabaseService.syncFromFirebase();
          emit(ListTaskLoaded(firebaseTaskLists));
          print('✅ ListTaskBloc: Đã load ${firebaseTaskLists.length} TaskList từ Firebase (không lưu vào Hive)');
          return;
        } catch (e) {
          print('⚠️ ListTaskBloc: Không thể load từ Firebase: $e');
          // Fallback: load từ Hive nếu Firebase lỗi
        }
      }
      
      // Chưa đăng nhập hoặc Firebase lỗi: load từ Hive
      final localTaskLists = HiveService.getAllTaskLists();
      emit(ListTaskLoaded(localTaskLists));
      print('✅ ListTaskBloc: Đã load ${localTaskLists.length} TaskList từ Hive');
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi load data: $e');
      emit(ListTaskError(e.toString()));
    }
  }

  /// Listen to Hive box changes
  void _listenToHiveChanges() {
    HiveService.taskListBox?.listenable().addListener(() {
      if (state is ListTaskLoaded && !_isSyncing) {
        add(const ListTaskLoadEvent()); // Trigger reload
      } else if (state is! ListTaskLoaded) {
        add(const ListTaskLoadEvent()); // Trigger reload
      }
    });
  }

  /// Listen to Firebase changes (khi đã đăng nhập)
  /// Chỉ cập nhật state, không lưu vào Hive
  void _listenToFirebaseChanges() {
    if (!FirebaseAuthService.isLoggedIn || !FirebaseDatabaseService.isInitialized) {
      return;
    }

    try {
      FirebaseDatabaseService.listenToChanges((firebaseTaskLists) {
        if (_isSyncing) return; // Tránh sync loop
        
        _isSyncing = true;
        print('📥 ListTaskBloc: Nhận thay đổi từ Firebase (${firebaseTaskLists.length} TaskList)');
        
        // Chỉ cập nhật state, không lưu vào Hive
        // Sử dụng add() để trigger reload event
        add(const ListTaskLoadEvent());
        print('✅ ListTaskBloc: Đã trigger reload từ Firebase (không lưu vào Hive)');
        
        _isSyncing = false;
      });
      print('✅ ListTaskBloc: Đã bắt đầu listen Firebase changes');
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi listen Firebase changes: $e');
    }
  }

  Future<void> _onAddTaskList(
    ListTaskAddEvent event,
    Emitter<ListTaskState> emit,
  ) async {
    try {
      // Nếu đã đăng nhập: Chỉ lưu vào Firebase, không lưu vào Hive
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          await FirebaseDatabaseService.addTaskList(event.taskList);
          print('✅ ListTaskBloc: Đã thêm TaskList vào Firebase: ${event.taskList.id}');
          
          // Reload từ Firebase để cập nhật state
          final firebaseTaskLists = await FirebaseDatabaseService.syncFromFirebase();
          emit(ListTaskLoaded(firebaseTaskLists));
          return;
        } catch (e) {
          print('❌ ListTaskBloc: Lỗi khi thêm TaskList vào Firebase: $e');
          emit(ListTaskError('Lỗi khi thêm TaskList: ${e.toString()}'));
          return;
        }
      }
      
      // Chưa đăng nhập: Lưu vào Hive
      await HiveService.addTaskList(event.taskList);
      final taskLists = HiveService.getAllTaskLists();
      emit(ListTaskLoaded(taskLists));
      print('✅ ListTaskBloc: Đã thêm TaskList vào Hive: ${event.taskList.id}');
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi thêm TaskList: $e');
      emit(ListTaskError(e.toString()));
    }
  }

  Future<void> _onUpdateTaskList(
    ListTaskUpdateEvent event,
    Emitter<ListTaskState> emit,
  ) async {
    try {
      // Nếu đã đăng nhập: Chỉ cập nhật Firebase, không cập nhật Hive
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          await FirebaseDatabaseService.updateTaskList(event.taskList);
          print('✅ ListTaskBloc: Đã cập nhật TaskList trong Firebase: ${event.taskList.id}');
          
          // Reload từ Firebase để cập nhật state
          final firebaseTaskLists = await FirebaseDatabaseService.syncFromFirebase();
          emit(ListTaskLoaded(firebaseTaskLists));
          return;
        } catch (e) {
          print('❌ ListTaskBloc: Lỗi khi cập nhật TaskList trong Firebase: $e');
          emit(ListTaskError('Lỗi khi cập nhật TaskList: ${e.toString()}'));
          return;
        }
      }
      
      // Chưa đăng nhập: Cập nhật trong Hive
      await HiveService.updateTaskList(event.taskList);
      final taskLists = HiveService.getAllTaskLists();
      emit(ListTaskLoaded(taskLists));
      print('✅ ListTaskBloc: Đã cập nhật TaskList trong Hive: ${event.taskList.id}');
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi cập nhật TaskList: $e');
      emit(ListTaskError(e.toString()));
    }
  }

  Future<void> _onDeleteTaskList(
    ListTaskDeleteEvent event,
    Emitter<ListTaskState> emit,
  ) async {
    try {
      // Nếu đã đăng nhập: Chỉ xóa trong Firebase, không xóa trong Hive
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          await FirebaseDatabaseService.deleteTaskList(event.id);
          print('✅ ListTaskBloc: Đã xóa TaskList khỏi Firebase: ${event.id}');
          
          // Reload từ Firebase để cập nhật state
          final firebaseTaskLists = await FirebaseDatabaseService.syncFromFirebase();
          emit(ListTaskLoaded(firebaseTaskLists));
          return;
        } catch (e) {
          print('❌ ListTaskBloc: Lỗi khi xóa TaskList khỏi Firebase: $e');
          emit(ListTaskError('Lỗi khi xóa TaskList: ${e.toString()}'));
          return;
        }
      }
      
      // Chưa đăng nhập: Xóa khỏi Hive
      await HiveService.deleteTaskList(event.id);
      final taskLists = HiveService.getAllTaskLists();
      emit(ListTaskLoaded(taskLists));
      print('✅ ListTaskBloc: Đã xóa TaskList khỏi Hive: ${event.id}');
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi xóa TaskList: $e');
      emit(ListTaskError(e.toString()));
    }
  }

  Future<void> _onRefresh(
    ListTaskRefreshEvent event,
    Emitter<ListTaskState> emit,
  ) async {
    try {
      emit(const ListTaskLoading());
      
      // Nếu đã đăng nhập, reload từ Firebase (không lưu vào Hive)
      if (FirebaseAuthService.isLoggedIn && FirebaseDatabaseService.isInitialized) {
        try {
          print('🔄 ListTaskBloc: Đang refresh từ Firebase...');
          final firebaseTaskLists = await FirebaseDatabaseService.syncFromFirebase();
          print('🔄 ListTaskBloc: Đã load ${firebaseTaskLists.length} TaskList từ Firebase (không lưu vào Hive)');
          
          emit(ListTaskLoaded(firebaseTaskLists));
          return;
        } catch (e) {
          print('⚠️ ListTaskBloc: Không thể refresh từ Firebase: $e');
          emit(ListTaskError('Lỗi khi refresh: ${e.toString()}'));
          return;
        }
      }
      
      // Chưa đăng nhập: Load từ Hive
      await _loadTaskLists(emit);
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi refresh: $e');
      emit(ListTaskError(e.toString()));
    }
  }

  Future<void> _onReloadAfterLogin(
    ListTaskReloadAfterLoginEvent event,
    Emitter<ListTaskState> emit,
  ) async {
    try {
      emit(const ListTaskLoading());
      
      // Kiểm tra user đã đăng nhập chưa
      if (!FirebaseAuthService.isLoggedIn) {
        print('⚠️ ListTaskBloc: User chưa đăng nhập, chỉ load từ Hive');
        await _loadTaskLists(emit);
        _listenToHiveChanges();
        return;
      }

      // 1. Init Firebase Database Service
      if (!FirebaseDatabaseService.isInitialized) {
        await FirebaseDatabaseService.init();
      }

      // 2. Chỉ load từ Firebase (không check Hive)
      print('📥 ListTaskBloc: Đang load dữ liệu từ Firebase...');
      final firebaseTaskLists = await FirebaseDatabaseService.syncFromFirebase();
      print('📥 ListTaskBloc: Đã load ${firebaseTaskLists.length} TaskList từ Firebase');

      // 3. Listen to Firebase changes
      _listenToFirebaseChanges();

      // 4. Emit state với dữ liệu từ Firebase
      emit(ListTaskLoaded(firebaseTaskLists));
      
      print('✅ ListTaskBloc: Đã reload sau khi đăng nhập thành công');
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi reload sau đăng nhập: $e');
      emit(ListTaskError('Lỗi khi reload: ${e.toString()}'));
    }
  }

  Future<void> _onClearAfterLogout(
    ListTaskClearAfterLogoutEvent event,
    Emitter<ListTaskState> emit,
  ) async {
    try {
      // Stop Firebase listener
      FirebaseDatabaseService.stopListening();
      
      // Clear credentials
      await LocalAuthService.clearCredentials();
      
      // Load data từ Hive (local data)
      await _loadTaskLists(emit);
      _listenToHiveChanges();
      print('✅ ListTaskBloc: Đã load data local sau khi đăng xuất');
    } catch (e) {
      print('❌ ListTaskBloc: Lỗi khi load data local sau đăng xuất: $e');
    }
  }

  /// Get all task lists
  List<TaskList> getTaskLists() {
    if (state is ListTaskLoaded) {
      return (state as ListTaskLoaded).taskLists;
    }
    return [];
  }

  /// Get task list by id
  TaskList? getTaskListById(String id) {
    final taskLists = getTaskLists();
    try {
      return taskLists.firstWhere((tl) => tl.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }
}

