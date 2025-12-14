import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/task.dart';

/// Service để quản lý tasks trên Firebase Firestore
class FirebaseTaskService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String username;

  FirebaseTaskService({required this.username});

  /// Collection path cho tasks của user
  String get _collectionPath => 'users/${username.toLowerCase()}/tasks';

  /// Lấy tất cả tasks của user
  Future<List<Task>> getAllTasks() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionPath)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all tasks: $e');
      }
      return [];
    }
  }

  /// Lấy tasks theo ngày
  Future<List<Task>> getTasksByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

      final snapshot = await _firestore
          .collection(_collectionPath)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThanOrEqualTo: endOfDay.toIso8601String())
          .orderBy('date')
          .get();

      return snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting tasks by date: $e');
      }
      return [];
    }
  }

  /// Lấy task theo ID
  Future<Task?> getTaskById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();

      if (doc.exists) {
        return Task.fromJson({...doc.data()!, 'id': doc.id});
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting task by ID: $e');
      }
      return null;
    }
  }

  /// Tạo task mới
  Future<Task> createTask(Task task) async {
    try {
      final docRef = _firestore.collection(_collectionPath).doc(task.id);
      
      final taskData = task.toJson();
      taskData['createdAt'] = FieldValue.serverTimestamp();
      taskData['updatedAt'] = FieldValue.serverTimestamp();
      
      await docRef.set(taskData);

      if (kDebugMode) {
        print('Task created: ${task.id}');
      }
      return task;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating task: $e');
      }
      rethrow;
    }
  }

  /// Cập nhật task
  Future<Task> updateTask(Task task) async {
    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      final taskData = updatedTask.toJson();
      taskData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collectionPath)
          .doc(task.id)
          .update(taskData);

      if (kDebugMode) {
        print('Task updated: ${task.id}');
      }
      return updatedTask;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating task: $e');
      }
      rethrow;
    }
  }

  /// Xóa task
  Future<void> deleteTask(String id) async {
    try {
      await _firestore.collection(_collectionPath).doc(id).delete();

      if (kDebugMode) {
        print('Task deleted: $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting task: $e');
      }
      rethrow;
    }
  }

  /// Toggle complete status
  Future<Task> toggleTaskComplete(String id) async {
    try {
      final task = await getTaskById(id);
      if (task == null) {
        throw Exception('Task not found');
      }

      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        updatedAt: DateTime.now(),
      );

      return await updateTask(updatedTask);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling task complete: $e');
      }
      rethrow;
    }
  }

  /// Xóa tất cả tasks
  Future<void> deleteAllTasks() async {
    try {
      final snapshot = await _firestore.collection(_collectionPath).get();
      
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }

      if (kDebugMode) {
        print('All tasks deleted for user: $username');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting all tasks: $e');
      }
      rethrow;
    }
  }

  /// Tìm kiếm tasks
  Future<List<Task>> searchTasks(String query) async {
    try {
      final allTasks = await getAllTasks();
      final lowercaseQuery = query.toLowerCase();

      return allTasks
          .where((task) =>
              task.title.toLowerCase().contains(lowercaseQuery) ||
              task.description.toLowerCase().contains(lowercaseQuery))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error searching tasks: $e');
      }
      return [];
    }
  }

  /// Đếm tasks chưa hoàn thành theo ngày
  Future<int> getIncompleteTaskCount(DateTime date) async {
    try {
      final tasks = await getTasksByDate(date);
      return tasks.where((task) => !task.isCompleted).length;
    } catch (e) {
      if (kDebugMode) {
        print('Error counting incomplete tasks: $e');
      }
      return 0;
    }
  }
}
