import '../models/task.dart';

abstract class TaskRepository {
  Future<void> saveTask(Task task);
  Future<void> deleteTask(String taskId);
  List<Task> getAllTasks();
}

class HiveTaskRepository implements TaskRepository {
  final dynamic hiveService;
  HiveTaskRepository(this.hiveService);

  @override
  Future<void> saveTask(Task task) => hiveService.saveTask(task);

  @override
  Future<void> deleteTask(String taskId) => hiveService.deleteTask(taskId);

  @override
  List<Task> getAllTasks() => hiveService.getAllTasks();
}


