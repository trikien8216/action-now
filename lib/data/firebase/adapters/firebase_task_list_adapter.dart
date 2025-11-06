import 'package:firebase_database/firebase_database.dart';
import '../../models/task.dart';

/// Adapter cho CRUD operations của TaskList với Firebase Realtime Database
class FirebaseTaskListAdapter {
  final DatabaseReference _taskListsRef;

  FirebaseTaskListAdapter(this._taskListsRef);

  /// Lấy tất cả TaskList từ Firebase
  /// 
  /// Returns: Danh sách tất cả TaskList
  /// Throws: Exception nếu có lỗi khi đọc dữ liệu
  Future<List<TaskList>> getAll() async {
    try {
      print('📥 Firebase: Đang lấy dữ liệu từ path: ${_taskListsRef.path}');
      final snapshot = await _taskListsRef.get();
      
      print('📥 Firebase: Snapshot exists: ${snapshot.exists}');
      if (!snapshot.exists) {
        print('📥 Firebase: Không có TaskList nào tại path: ${_taskListsRef.path}');
        return [];
      }

      final data = snapshot.value;
      print('📥 Firebase: Data type: ${data.runtimeType}');
      
      if (data == null) {
        print('📥 Firebase: Data null');
        return [];
      }

      if (data is! Map) {
        print('⚠️ Firebase: Data không phải Map, type: ${data.runtimeType}');
        print('⚠️ Firebase: Data value: $data');
        return [];
      }

      final taskLists = <TaskList>[];

      // Convert Map<dynamic, dynamic> thành Map<String, dynamic>
      final dataMap = _convertToMapStringDynamic(data as Map);
      
      print('📥 Firebase: Đang parse ${dataMap.length} TaskList entries...');
      print('📥 Firebase: DataMap keys: ${dataMap.keys.toList()}');
      
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
            print('⚠️ Firebase: TaskList entry "$entryKey" không phải Map, type: ${json.runtimeType}');
            continue;
          }
          
          final taskList = TaskList.fromJson(taskListJson);
          taskLists.add(taskList);
          print('✅ Firebase: Đã parse TaskList "$entryKey": ${taskList.title} (${taskList.tasks.length} tasks)');
        } catch (e, stackTrace) {
          print('❌ Firebase: Lỗi khi parse TaskList ${entry.key}: $e');
          print('❌ Stack trace: $stackTrace');
          // Bỏ qua TaskList lỗi, tiếp tục với các TaskList khác
          continue;
        }
      }

      print('📥 Firebase: Đã đọc ${taskLists.length} TaskList thành công');
      return taskLists;
    } catch (e) {
      print('❌ Firebase: Lỗi khi lấy danh sách TaskList: $e');
      throw Exception('Lỗi khi lấy danh sách TaskList từ Firebase: $e');
    }
  }

  /// Lấy TaskList theo ID
  /// 
  /// [id]: ID của TaskList cần lấy
  /// Returns: TaskList nếu tồn tại, null nếu không tìm thấy
  /// Throws: Exception nếu có lỗi khi đọc dữ liệu
  Future<TaskList?> getById(String id) async {
    try {
      final snapshot = await _taskListsRef.child(id).get();
      if (!snapshot.exists) {
        print('📥 Firebase: TaskList $id không tồn tại');
        return null;
      }

      final value = snapshot.value;
      if (value == null) {
        print('📥 Firebase: TaskList $id có giá trị null');
        return null;
      }

      // Convert Map<dynamic, dynamic> thành Map<String, dynamic> nếu cần
      Map<String, dynamic>? taskListJson;
      if (value is Map<String, dynamic>) {
        taskListJson = value;
      } else if (value is Map) {
        taskListJson = _convertToMapStringDynamic(value);
      } else {
        print('⚠️ Firebase: TaskList $id không phải Map, type: ${value.runtimeType}');
        return null;
      }

      try {
        final taskList = TaskList.fromJson(taskListJson);
        print('📥 Firebase: Đã đọc TaskList $id thành công (${taskList.tasks.length} tasks)');
        return taskList;
      } catch (e) {
        print('❌ Firebase: Lỗi khi parse TaskList $id: $e');
        throw Exception('Lỗi khi parse TaskList từ Firebase: $e');
      }
    } catch (e) {
      print('❌ Firebase: Lỗi khi lấy TaskList $id: $e');
      throw Exception('Lỗi khi lấy TaskList từ Firebase: $e');
    }
  }

  /// Tạo TaskList mới
  /// 
  /// [taskList]: TaskList cần tạo
  /// Returns: TaskList đã được tạo
  /// Throws: Exception nếu có lỗi khi ghi dữ liệu
  Future<TaskList> create(TaskList taskList) async {
    try {
      // Validation
      if (taskList.id.isEmpty) {
        throw Exception('TaskList ID không được để trống');
      }
      if (taskList.title.isEmpty) {
        throw Exception('TaskList title không được để trống');
      }

      // Kiểm tra TaskList đã tồn tại chưa (optional - có thể overwrite)
      final exists = await this.exists(taskList.id);
      if (exists) {
        print('⚠️ Firebase: TaskList ${taskList.id} đã tồn tại, sẽ overwrite');
      }

      // Convert to JSON
      final json = taskList.toJson();
      print('📝 Firebase: Đang tạo TaskList ${taskList.id} với ${taskList.tasks.length} tasks');

      // Write to Firebase
      await _taskListsRef.child(taskList.id).set(json);
      
      print('✅ Firebase: Đã tạo TaskList ${taskList.id} thành công');
      return taskList;
    } catch (e) {
      print('❌ Firebase: Lỗi khi tạo TaskList ${taskList.id}: $e');
      throw Exception('Lỗi khi tạo TaskList trong Firebase: $e');
    }
  }

  /// Cập nhật TaskList
  /// 
  /// [taskList]: TaskList đã được cập nhật
  /// Returns: TaskList đã được cập nhật
  /// Throws: Exception nếu có lỗi khi cập nhật dữ liệu
  Future<TaskList> update(TaskList taskList) async {
    try {
      await _taskListsRef.child(taskList.id).update(taskList.toJson());
      return taskList;
    } catch (e) {
      throw Exception('Lỗi khi cập nhật TaskList trong Firebase: $e');
    }
  }

  /// Xóa TaskList
  /// 
  /// [id]: ID của TaskList cần xóa
  /// Throws: Exception nếu có lỗi khi xóa dữ liệu
  Future<void> delete(String id) async {
    try {
      await _taskListsRef.child(id).remove();
    } catch (e) {
      throw Exception('Lỗi khi xóa TaskList từ Firebase: $e');
    }
  }

  /// Kiểm tra TaskList có tồn tại không
  /// 
  /// [id]: ID của TaskList cần kiểm tra
  /// Returns: true nếu tồn tại, false nếu không
  Future<bool> exists(String id) async {
    try {
      final snapshot = await _taskListsRef.child(id).get();
      return snapshot.exists;
    } catch (e) {
      throw Exception('Lỗi khi kiểm tra TaskList trong Firebase: $e');
    }
  }

  /// Lấy số lượng TaskList
  /// 
  /// Returns: Số lượng TaskList hiện có
  Future<int> count() async {
    try {
      final snapshot = await _taskListsRef.get();
      if (!snapshot.exists) {
        return 0;
      }
      final data = snapshot.value as Map;
      return data.length;
    } catch (e) {
      throw Exception('Lỗi khi đếm TaskList trong Firebase: $e');
    }
  }

  /// Xóa tất cả TaskList
  /// 
  /// Throws: Exception nếu có lỗi khi xóa
  Future<void> deleteAll() async {
    try {
      await _taskListsRef.remove();
    } catch (e) {
      throw Exception('Lỗi khi xóa tất cả TaskList từ Firebase: $e');
    }
  }

  /// Cập nhật nhiều TaskList cùng lúc (batch update)
  /// 
  /// [taskLists]: Danh sách TaskList cần cập nhật
  /// Throws: Exception nếu có lỗi khi cập nhật
  Future<void> updateBatch(List<TaskList> taskLists) async {
    try {
      final Map<String, dynamic> updates = {};
      for (var taskList in taskLists) {
        updates[taskList.id] = taskList.toJson();
      }
      if (updates.isNotEmpty) {
        await _taskListsRef.update(updates);
      }
    } catch (e) {
      throw Exception('Lỗi khi cập nhật batch TaskList trong Firebase: $e');
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

