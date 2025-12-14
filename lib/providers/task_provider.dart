import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/firebase_task_service.dart';

/// Provider để quản lý state của tasks
/// Sử dụng ChangeNotifier để notify UI khi có thay đổi
class TaskProvider with ChangeNotifier {
  FirebaseTaskService? _taskService;
  List<Task> _tasks = [];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  String? _currentUsername;

  /// Cập nhật username và reload tasks
  Future<void> setUsername(String? username) async {
    if (_currentUsername != username) {
      _currentUsername = username;
      if (username != null) {
        _taskService = FirebaseTaskService(username: username);
        await loadTasks();
      } else {
        _taskService = null;
        _tasks = [];
        notifyListeners();
      }
    }
  }

  List<Task> get tasks => _tasks;
  DateTime get selectedDate => _selectedDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lấy tasks của ngày đã chọn
  List<Task> get tasksForSelectedDate {
    return _tasks.where((task) {
      final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
      final selectedDateOnly = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      return taskDate.isAtSameMomentAs(selectedDateOnly);
    }).toList();
  }

  /// Lấy số lượng tasks chưa hoàn thành theo ngày
  int getTaskCountForDate(DateTime date) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    return _tasks.where((task) {
      final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
      return taskDate.isAtSameMomentAs(dateOnly) && !task.isCompleted;
    }).length;
  }

  /// Set ngày được chọn
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Load tất cả tasks
  Future<void> loadTasks() async {
    if (_taskService == null) {
      _tasks = [];
      return;
    }
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tasks = await _taskService!.getAllTasks();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tạo task mới
  Future<void> createTask(Task task) async {
    if (_taskService == null) return;
    
    try {
      final newTask = await _taskService!.createTask(task);
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Cập nhật task
  Future<void> updateTask(Task task) async {
    if (_taskService == null) return;
    
    try {
      final updatedTask = await _taskService!.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Xóa task
  Future<void> deleteTask(String id) async {
    if (_taskService == null) return;
    
    try {
      await _taskService!.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Toggle trạng thái hoàn thành
  Future<void> toggleTaskComplete(String id) async {
    if (_taskService == null) return;
    
    try {
      final updatedTask = await _taskService!.toggleTaskComplete(id);
      final index = _tasks.indexWhere((t) => t.id == id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Tìm kiếm tasks
  Future<List<Task>> searchTasks(String query) async {
    if (_taskService == null) return [];
    
    try {
      return await _taskService!.searchTasks(query);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
