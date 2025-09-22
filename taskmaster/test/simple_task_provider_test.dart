import 'package:flutter_test/flutter_test.dart';
import 'package:taskmaster/models/task.dart';
import 'package:taskmaster/providers/simple_task_provider.dart';
import 'package:taskmaster/services/task_repository.dart';

class InMemoryRepo implements TaskRepository {
  final Map<String, Task> _store = {};
  @override
  Future<void> saveTask(Task task) async {
    _store[task.id] = task;
  }

  @override
  Future<void> deleteTask(String taskId) async {
    _store.remove(taskId);
  }

  @override
  List<Task> getAllTasks() => _store.values.toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SimpleTaskProvider', () {
    late SimpleTaskProvider provider;

    setUp(() async {
      provider = SimpleTaskProvider(repository: InMemoryRepo());
      await provider.loadTasks();
    });

    test('add, update, toggle, delete flow', () async {
      final task = Task(
        id: '1',
        title: 'Test',
        createdAt: DateTime.now(),
      );

      await provider.addTask(task);
      expect(provider.tasks.length, 1);
      expect(provider.pendingTasks.length, 1);

      await provider.toggleTaskCompletion('1');
      expect(provider.completedTasks.length, 1);

      await provider.updateTask(task.copyWith(title: 'Updated'));
      expect(provider.tasks.first.title, 'Updated');

      await provider.deleteTask('1');
      expect(provider.tasks.isEmpty, true);
    });

    test('search finds title and description', () async {
      final t1 = Task(id: '1', title: 'Buy milk', description: 'Grocery', createdAt: DateTime.now());
      final t2 = Task(id: '2', title: 'Read book', description: 'Novel', createdAt: DateTime.now());
      await provider.addTask(t1);
      await provider.addTask(t2);

      final res1 = provider.searchTasks('milk');
      final res2 = provider.searchTasks('novel');
      expect(res1.length, 1);
      expect(res1.first.id, '1');
      expect(res2.length, 1);
      expect(res2.first.id, '2');
    });
  });
}


