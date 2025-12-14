import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get tasks collection for a user
  CollectionReference _getUserTasksCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Get all tasks for a user
  Future<List<Task>> getAllTasks(String userId) async {
    try {
      final snapshot = await _getUserTasksCollection(userId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromJson(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get tasks by date
  Future<List<Task>> getTasksByDate(String userId, DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final snapshot = await _getUserTasksCollection(userId)
          .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
          .where('date', isLessThan: endOfDay.toIso8601String())
          .orderBy('date')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromJson(data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Create task
  Future<void> createTask(String userId, Task task) async {
    try {
      await _getUserTasksCollection(userId).doc(task.id).set(task.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Update task
  Future<void> updateTask(String userId, Task task) async {
    try {
      await _getUserTasksCollection(userId).doc(task.id).update(task.toJson());
    } catch (e) {
      rethrow;
    }
  }

  // Delete task
  Future<void> deleteTask(String userId, String taskId) async {
    try {
      await _getUserTasksCollection(userId).doc(taskId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Toggle task complete
  Future<void> toggleTaskComplete(String userId, String taskId, bool isCompleted) async {
    try {
      await _getUserTasksCollection(userId).doc(taskId).update({
        'isCompleted': isCompleted,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      rethrow;
    }
  }

  // Search tasks
  Future<List<Task>> searchTasks(String userId, String query) async {
    try {
      final snapshot = await _getUserTasksCollection(userId).get();
      
      final tasks = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromJson(data);
      }).toList();

      // Filter tasks by query (case-insensitive)
      final lowerQuery = query.toLowerCase();
      return tasks.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
               (task.description.toLowerCase().contains(lowerQuery));
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get incomplete task count
  Future<int> getIncompleteTaskCount(String userId) async {
    try {
      final snapshot = await _getUserTasksCollection(userId)
          .where('isCompleted', isEqualTo: false)
          .get();
      
      return snapshot.docs.length;
    } catch (e) {
      rethrow;
    }
  }

  // Stream tasks for real-time updates
  Stream<List<Task>> streamTasks(String userId) {
    return _getUserTasksCollection(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromJson(data);
      }).toList();
    });
  }

  // Stream tasks by date for real-time updates
  Stream<List<Task>> streamTasksByDate(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _getUserTasksCollection(userId)
        .where('date', isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('date', isLessThan: endOfDay.toIso8601String())
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Task.fromJson(data);
      }).toList();
    });
  }
}
