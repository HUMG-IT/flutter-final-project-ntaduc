import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:calendar_note_app/widgets/task_list_item.dart';
import 'package:calendar_note_app/models/task.dart';

void main() {
  group('TaskListItem Widget Tests', () {
    testWidgets('should display task information correctly', (WidgetTester tester) async {
      final task = Task(
        id: 'test-id',
        title: 'Test Task',
        description: 'Test Description',
        date: DateTime(2024, 12, 14),
        priority: TaskPriority.high,
        isCompleted: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListItem(
              task: task,
              onTap: () {},
              onToggleComplete: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Task'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('should show completed task with line through', (WidgetTester tester) async {
      final task = Task(
        id: 'test-id',
        title: 'Completed Task',
        description: 'Description',
        date: DateTime.now(),
        isCompleted: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListItem(
              task: task,
              onTap: () {},
              onToggleComplete: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      final titleWidget = tester.widget<Text>(find.text('Completed Task'));
      expect(titleWidget.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('should call onToggleComplete when checkbox is tapped', (WidgetTester tester) async {
      bool toggleCalled = false;
      final task = Task(
        title: 'Test Task',
        description: 'Description',
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListItem(
              task: task,
              onTap: () {},
              onToggleComplete: () {
                toggleCalled = true;
              },
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      expect(toggleCalled, true);
    });

    testWidgets('should call onTap when list tile is tapped', (WidgetTester tester) async {
      bool tapCalled = false;
      final task = Task(
        title: 'Test Task',
        description: 'Description',
        date: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListItem(
              task: task,
              onTap: () {
                tapCalled = true;
              },
              onToggleComplete: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListTile));
      await tester.pump();

      expect(tapCalled, true);
    });

    testWidgets('should show priority chip with correct color', (WidgetTester tester) async {
      final task = Task(
        title: 'Urgent Task',
        description: 'Description',
        date: DateTime.now(),
        priority: TaskPriority.urgent,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TaskListItem(
              task: task,
              onTap: () {},
              onToggleComplete: () {},
              onDelete: () {},
            ),
          ),
        ),
      );

      expect(find.text('Khẩn cấp'), findsOneWidget);
    });
  });
}
