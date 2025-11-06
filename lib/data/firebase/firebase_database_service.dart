import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/task.dart';
import 'adapters/firebase_task_list_adapter.dart';
import 'adapters/firebase_task_adapter.dart';
import 'firebase_auth_service.dart';

/// Service quản lý Firebase Realtime Database cho Task và TaskList
/// Dữ liệu được lưu riêng cho từng user: users/{userId}/taskLists
/// Database URL: https://action-now-2600c-default-rtdb.asia-southeast1.firebasedatabase.app
/// Sử dụng các adapters để thực hiện CRUD operations
class FirebaseDatabaseService {
  // Firebase Realtime Database URL
  // URL của Firebase Realtime Database
  static const String _databaseUrl = 'https://action-now-2600c-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  // Cache FirebaseDatabase instance
  static FirebaseDatabase? _firebaseDatabase;
  static DatabaseReference get _database {
    _firebaseDatabase ??= FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: _databaseUrl,
    );
    return _firebaseDatabase!.ref();
  }
  
  static DatabaseReference? _taskListsRef;
  static bool _isListening = false;
  static StreamSubscription<DatabaseEvent>? _listenerSubscription;
  static String? _currentUserId;

  // Adapters
  static FirebaseTaskListAdapter? _taskListAdapter;
  static FirebaseTaskAdapter? _taskAdapter;

  /// Khởi tạo Firebase service cho user hiện tại
  /// Sẽ tự động lấy userId từ FirebaseAuthService
  static Future<void> init() async {
    await _initializeForUser();
  }

  /// Khởi tạo lại service cho user mới (khi đăng nhập/đăng xuất)
  /// 
  /// [userId]: ID của user (nếu null sẽ lấy từ currentUser)
  static Future<void> reloadForUser([String? userId]) async {
    // Dừng listener cũ
    stopListening();
    
    // Xóa adapters cũ
    _taskListAdapter = null;
    _taskAdapter = null;
    
    // Khởi tạo lại với user mới
    _currentUserId = userId ?? FirebaseAuthService.currentUser?.uid;
    await _initializeForUser();
  }

  /// Khởi tạo service cho user cụ thể
  static Future<void> _initializeForUser() async {
    final userId = FirebaseAuthService.currentUser?.uid;
    
    if (userId == null) {
      throw Exception('Không có user đăng nhập. Vui lòng đăng nhập trước.');
    }

    _currentUserId = userId;
    
    // Path: users/{userId}/taskLists
    final userTaskListsPath = 'users/$userId/taskLists';
    _taskListsRef = _database.child(userTaskListsPath);
    
    _taskListAdapter = FirebaseTaskListAdapter(_taskListsRef!);
    _taskAdapter = FirebaseTaskAdapter(_taskListAdapter!);
  }

  /// Kiểm tra service đã được khởi tạo chưa
  static bool get isInitialized => _taskListsRef != null && _taskListAdapter != null;

  /// Lấy userId hiện tại
  static String? get currentUserId => _currentUserId;

  /// Kiểm tra có user đăng nhập không
  static bool get hasUser => FirebaseAuthService.isLoggedIn;

  // ==================== TaskList Operations ====================

  /// Lấy tất cả TaskList từ Firebase của user hiện tại
  /// 
  /// Returns: Danh sách tất cả TaskList của user
  /// Throws: Exception nếu có lỗi khi đọc dữ liệu
  static Future<List<TaskList>> getAllTaskLists() async {
    _ensureInitialized();
    try {
      print('📥 FirebaseDatabaseService: Đang lấy tất cả TaskList...');
      final taskLists = await _taskListAdapter!.getAll();
      print('📥 FirebaseDatabaseService: Đã lấy ${taskLists.length} TaskList');
      return taskLists;
    } catch (e) {
      print('❌ FirebaseDatabaseService: Lỗi khi lấy tất cả TaskList: $e');
      rethrow;
    }
  }

  /// Lấy TaskList theo ID
  /// 
  /// [id]: ID của TaskList cần lấy
  /// Returns: TaskList nếu tồn tại, null nếu không tìm thấy
  /// Throws: Exception nếu có lỗi khi đọc dữ liệu
  static Future<TaskList?> getTaskListById(String id) async {
    _ensureInitialized();
    try {
      print('📥 FirebaseDatabaseService: Đang lấy TaskList $id...');
      final taskList = await _taskListAdapter!.getById(id);
      if (taskList != null) {
        print('📥 FirebaseDatabaseService: Đã lấy TaskList $id thành công');
      } else {
        print('📥 FirebaseDatabaseService: TaskList $id không tồn tại');
      }
      return taskList;
    } catch (e) {
      print('❌ FirebaseDatabaseService: Lỗi khi lấy TaskList $id: $e');
      rethrow;
    }
  }

  /// Tạo TaskList mới
  /// 
  /// [taskList]: TaskList cần tạo
  /// Throws: Exception nếu có lỗi
  static Future<void> addTaskList(TaskList taskList) async {
    _ensureInitialized();
    try {
      print('📝 FirebaseDatabaseService: Đang tạo TaskList ${taskList.id}');
      await _taskListAdapter!.create(taskList);
      print('✅ FirebaseDatabaseService: Đã tạo TaskList ${taskList.id} thành công');
    } catch (e) {
      print('❌ FirebaseDatabaseService: Lỗi khi tạo TaskList ${taskList.id}: $e');
      rethrow;
    }
  }

  /// Cập nhật TaskList
  static Future<void> updateTaskList(TaskList taskList) async {
    _ensureInitialized();
    await _taskListAdapter!.update(taskList);
  }

  /// Xóa TaskList
  static Future<void> deleteTaskList(String id) async {
    _ensureInitialized();
    await _taskListAdapter!.delete(id);
  }

  // ==================== Task Operations ====================

  /// Lấy tất cả Task trong một TaskList
  static Future<List<Task>> getAllTasksByTaskListId(String taskListId) async {
    _ensureInitialized();
    return await _taskAdapter!.getAllByTaskListId(taskListId);
  }

  /// Lấy Task theo ID
  static Future<Task?> getTaskById(String taskListId, String taskId) async {
    _ensureInitialized();
    return await _taskAdapter!.getById(taskListId, taskId);
  }

  /// Thêm Task vào TaskList
  static Future<void> addTaskToTaskList(String taskListId, Task task) async {
    _ensureInitialized();
    await _taskAdapter!.create(taskListId, task);
  }

  /// Cập nhật Task trong TaskList
  static Future<void> updateTaskInTaskList(
      String taskListId, String taskId, Task updatedTask) async {
    _ensureInitialized();
    await _taskAdapter!.update(taskListId, taskId, updatedTask);
  }

  /// Xóa Task khỏi TaskList
  static Future<void> deleteTaskFromTaskList(
      String taskListId, String taskId) async {
    _ensureInitialized();
    await _taskAdapter!.delete(taskListId, taskId);
  }

  /// Toggle trạng thái hoàn thành của Task
  static Future<void> toggleTaskCompletion(
      String taskListId, String taskId) async {
    _ensureInitialized();
    await _taskAdapter!.toggleCompletion(taskListId, taskId);
  }

  // ==================== Sync Operations ====================

  /// Đồng bộ tất cả dữ liệu từ Firebase (cho initial sync)
  /// 
  /// Returns: Danh sách tất cả TaskList từ Firebase
  /// Throws: Exception nếu có lỗi khi sync
  static Future<List<TaskList>> syncFromFirebase() async {
    _ensureInitialized();
    try {
      print('🔄 FirebaseDatabaseService: Bắt đầu sync từ Firebase...');
      final taskLists = await _taskListAdapter!.getAll();
      print('🔄 FirebaseDatabaseService: Đã sync ${taskLists.length} TaskList từ Firebase');
      return taskLists;
    } catch (e) {
      print('❌ FirebaseDatabaseService: Lỗi khi sync từ Firebase: $e');
      throw Exception('Lỗi khi sync từ Firebase: $e');
    }
  }

  /// Đồng bộ tất cả dữ liệu lên Firebase (cho full sync)
  static Future<void> syncToFirebase(List<TaskList> taskLists) async {
    _ensureInitialized();
    try {
      await _taskListAdapter!.updateBatch(taskLists);
    } catch (e) {
      throw Exception('Lỗi khi sync lên Firebase: $e');
    }
  }

  // ==================== Realtime Listeners ====================

  /// Lắng nghe thay đổi từ Firebase Realtime Database của user hiện tại
  /// 
  /// [onDataChanged]: Callback được gọi khi có thay đổi
  static void listenToChanges(Function(List<TaskList>) onDataChanged) {
    _ensureInitialized();
    if (_isListening) return;
    _isListening = true;

    _listenerSubscription = _taskListsRef!.onValue.listen((event) {
      try {
        print('📥 Firebase Listener: Nhận event từ path: ${event.snapshot.ref.path}');
        print('📥 Firebase Listener: Snapshot exists: ${event.snapshot.exists}');
        
        if (!event.snapshot.exists) {
          print('📥 Firebase Listener: Không có data tại path: ${event.snapshot.ref.path}');
          onDataChanged([]);
          return;
        }

        final data = event.snapshot.value;
        print('📥 Firebase Listener: Data type: ${data.runtimeType}');
        
        if (data == null) {
          print('📥 Firebase Listener: Data null');
          onDataChanged([]);
          return;
        }

        if (data is! Map) {
          print('⚠️ Firebase Listener: Data không phải Map, type: ${data.runtimeType}');
          print('⚠️ Firebase Listener: Data value: $data');
          onDataChanged([]);
          return;
        }

        final taskLists = <TaskList>[];

        // Convert Map<dynamic, dynamic> thành Map<String, dynamic>
        final dataMap = _convertToMapStringDynamic(data as Map);
        
        print('📥 Firebase Listener: Đang parse ${dataMap.length} TaskList entries...');
        print('📥 Firebase Listener: DataMap keys: ${dataMap.keys.toList()}');
        
        for (var entry in dataMap.entries) {
          try {
            final entryKey = entry.key.toString();
            final json = entry.value;
            
            // Convert entry.value thành Map<String, dynamic>
            Map<String, dynamic> taskListJson;
            if (json is Map<String, dynamic>) {
              taskListJson = json;
            } else if (json is Map) {
              taskListJson = _convertToMapStringDynamic(json);
            } else {
              print('⚠️ Firebase Listener: Entry "$entryKey" không phải Map, type: ${json.runtimeType}');
              continue;
            }
            
            final taskList = TaskList.fromJson(taskListJson);
            taskLists.add(taskList);
            print('✅ Firebase Listener: Đã parse TaskList "$entryKey": ${taskList.title} (${taskList.tasks.length} tasks)');
          } catch (e, stackTrace) {
            print('❌ Firebase Listener: Lỗi khi parse TaskList ${entry.key}: $e');
            print('❌ Stack trace: $stackTrace');
            // Bỏ qua TaskList lỗi, tiếp tục với các TaskList khác
            continue;
          }
        }

        print('📥 Firebase Listener: Đã nhận ${taskLists.length} TaskList');
        onDataChanged(taskLists);
      } catch (e) {
        print('❌ Firebase Listener: Lỗi khi lắng nghe thay đổi: $e');
        print('❌ Stack trace: ${e.toString()}');
        // Emit empty list để tránh crash
        onDataChanged([]);
      }
    });
  }

  /// Dừng lắng nghe thay đổi từ Firebase
  static void stopListening() {
    if (!_isListening) return;
    _listenerSubscription?.cancel();
    _listenerSubscription = null;
    _isListening = false;
  }

  // ==================== Utility Methods ====================

  /// Kiểm tra TaskList có tồn tại không
  static Future<bool> taskListExists(String id) async {
    _ensureInitialized();
    return await _taskListAdapter!.exists(id);
  }

  /// Đếm số lượng TaskList
  static Future<int> getTaskListCount() async {
    _ensureInitialized();
    return await _taskListAdapter!.count();
  }

  /// Kiểm tra Task có tồn tại không
  static Future<bool> taskExists(String taskListId, String taskId) async {
    _ensureInitialized();
    return await _taskAdapter!.exists(taskListId, taskId);
  }

  /// Đếm số lượng Task trong TaskList
  static Future<int> getTaskCount(String taskListId) async {
    _ensureInitialized();
    return await _taskAdapter!.countByTaskListId(taskListId);
  }

  /// Lấy reference trực tiếp (cho các use case đặc biệt)
  static DatabaseReference? get taskListsRef => _taskListsRef;

  /// Lấy TaskList adapter (cho các use case đặc biệt)
  static FirebaseTaskListAdapter? get taskListAdapter => _taskListAdapter;

  /// Lấy Task adapter (cho các use case đặc biệt)
  static FirebaseTaskAdapter? get taskAdapter => _taskAdapter;

  /// Đảm bảo service đã được khởi tạo
  static void _ensureInitialized() {
    if (!isInitialized) {
      throw Exception(
        'FirebaseDatabaseService chưa được khởi tạo. '
        'Vui lòng gọi init() hoặc đảm bảo user đã đăng nhập.'
      );
    }
  }

  /// Xóa tất cả dữ liệu của user hiện tại (chỉ dùng cho testing)
  static Future<void> clearAllDataForCurrentUser() async {
    _ensureInitialized();
    if (_taskListsRef != null) {
      await _taskListsRef!.remove();
    }
  }

  /// Helper method để convert Map<dynamic, dynamic> thành Map<String, dynamic>
  /// Firebase Realtime Database trả về Map<dynamic, dynamic>, cần convert
  static Map<String, dynamic> _convertToMapStringDynamic(Map map) {
    final result = <String, dynamic>{};
    for (var entry in map.entries) {
      final key = entry.key.toString();
      final value = entry.value;
      
      if (value is Map) {
        // Recursively convert nested Maps
        result[key] = _convertToMapStringDynamic(value);
      } else if (value is List) {
        // Convert List items
        result[key] = value.map((item) {
          if (item is Map) {
            return _convertToMapStringDynamic(item);
          }
          return item;
        }).toList();
      } else {
        result[key] = value;
      }
    }
    return result;
  }
}
