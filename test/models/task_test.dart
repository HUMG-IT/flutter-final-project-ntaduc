import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_note_app/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('Task should be created with all properties', () {
      final date = DateTime(2024, 12, 14);
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        date: date,
        priority: TaskPriority.high,
        isCompleted: false,
      );

      expect(task.id, 'test-id');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.date, date);
      expect(task.priority, TaskPriority.high);
      expect(task.isCompleted, false);
    });

    test('Task should generate UUID if id is not provided', () {
      final task = Task(
        title: 'Test Task',
        description: 'Test Description',
        date: DateTime.now(),
      );

      expect(task.id, isNotEmpty);
      expect(task.id.length, 36); // UUID length
    });

    test('Task should convert to JSON correctly', () {
      final date = DateTime(2024, 12, 14);
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        date: date,
        priority: TaskPriority.medium,
        isCompleted: true,
      );

      final json = task.toJson();

      expect(json['id'], 'test-id');
      expect(json['title'], 'Test Task');
      expect(json['description'], 'Test Description');
      expect(json['date'], date.toIso8601String());
      expect(json['priority'], 'medium');
      expect(json['isCompleted'], true);
    });

    test('Task should be created from JSON correctly', () {
      final date = DateTime(2024, 12, 14);
      final json = {
        'id': 'test-id',
        'title': 'Test Task',
        'description': 'Test Description',
        'date': date.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
        'priority': 'high',
        'isCompleted': false,
      };

      final task = Task.fromJson(json);

      expect(task.id, 'test-id');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.priority, TaskPriority.high);
      expect(task.isCompleted, false);
    });

    test('Task copyWith should create a new instance with updated properties', () {
      final task = Task(
        id: 'test-id',
        title: 'Original Title',
        description: 'Original Description',
        date: DateTime.now(),
      );

      final updatedTask = task.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(updatedTask.id, task.id);
      expect(updatedTask.title, 'Updated Title');
      expect(updatedTask.description, 'Original Description');
      expect(updatedTask.isCompleted, true);
    });

    test('Tasks with same id should be equal', () {
      final task1 = Task(
        id: 'same-id',
        title: 'Task 1',
        description: 'Description 1',
        date: DateTime.now(),
      );

      final task2 = Task(
        id: 'same-id',
        title: 'Task 2',
        description: 'Description 2',
        date: DateTime.now(),
      );

      expect(task1, equals(task2));
      expect(task1.hashCode, task2.hashCode);
    });

    test('TaskPriority should have correct display names', () {
      expect(TaskPriority.low.displayName, 'Thấp');
      expect(TaskPriority.medium.displayName, 'Trung bình');
      expect(TaskPriority.high.displayName, 'Cao');
      expect(TaskPriority.urgent.displayName, 'Khẩn cấp');
    });
  });
}
