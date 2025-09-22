import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('should create a task with required fields', () {
      final task = Task(
        id: '1',
        title: 'Test Task',
        createdAt: DateTime.now(),
      );

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, '');
      expect(task.isCompleted, false);
      expect(task.priority, TaskPriority.medium);
    });

    test('should create a task with all fields', () {
      final now = DateTime.now();
      final dueDate = now.add(const Duration(days: 1));
      
      final task = Task(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        isCompleted: true,
        createdAt: now,
        dueDate: dueDate,
        priority: TaskPriority.high,
        category: 'Work',
      );

      expect(task.id, '1');
      expect(task.title, 'Test Task');
      expect(task.description, 'Test Description');
      expect(task.isCompleted, true);
      expect(task.priority, TaskPriority.high);
      expect(task.category, 'Work');
      expect(task.dueDate, dueDate);
    });

    test('should copy task with new values', () {
      final originalTask = Task(
        id: '1',
        title: 'Original Task',
        createdAt: DateTime.now(),
      );

      final copiedTask = originalTask.copyWith(
        title: 'Updated Task',
        isCompleted: true,
      );

      expect(copiedTask.id, '1');
      expect(copiedTask.title, 'Updated Task');
      expect(copiedTask.isCompleted, true);
      expect(copiedTask.description, '');
    });

    test('should test task equality', () {
      final task1 = Task(
        id: '1',
        title: 'Test Task',
        createdAt: DateTime.now(),
      );

      final task2 = Task(
        id: '1',
        title: 'Different Title',
        createdAt: DateTime.now(),
      );

      final task3 = Task(
        id: '2',
        title: 'Test Task',
        createdAt: DateTime.now(),
      );

      expect(task1 == task2, true); // Same ID
      expect(task1 == task3, false); // Different ID
    });

    test('should test task priority values', () {
      expect(TaskPriority.low.value, 1);
      expect(TaskPriority.medium.value, 2);
      expect(TaskPriority.high.value, 3);
    });

    test('should test task priority display names', () {
      expect(TaskPriority.low.displayName, 'Low');
      expect(TaskPriority.medium.displayName, 'Medium');
      expect(TaskPriority.high.displayName, 'High');
    });
  });
}
