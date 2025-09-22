import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class HiveService {
  static const String _tasksBoxName = 'tasks';
  static const String _settingsBoxName = 'settings';
  
  static late Box<Task> _tasksBox;
  static late Box<dynamic> _settingsBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    Hive.registerAdapter(TaskAdapter());
    Hive.registerAdapter(TaskPriorityAdapter());
    
    // Open boxes
    _tasksBox = await Hive.openBox<Task>(_tasksBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
  }

  // Task operations
  static Future<void> saveTask(Task task) async {
    await _tasksBox.put(task.id, task);
  }

  static Future<void> deleteTask(String taskId) async {
    await _tasksBox.delete(taskId);
  }

  static List<Task> getAllTasks() {
    return _tasksBox.values.toList();
  }

  static List<Task> getPendingTasks() {
    return _tasksBox.values.where((task) => !task.isCompleted).toList();
  }

  static List<Task> getCompletedTasks() {
    return _tasksBox.values.where((task) => task.isCompleted).toList();
  }

  static List<Task> searchTasks(String query) {
    final lowerQuery = query.toLowerCase();
    return _tasksBox.values.where((task) {
      return task.title.toLowerCase().contains(lowerQuery) ||
             task.description.toLowerCase().contains(lowerQuery) ||
             (task.category?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  static List<Task> getTasksByCategory(String category) {
    return _tasksBox.values.where((task) => task.category == category).toList();
  }

  static List<String> getAllCategories() {
    final categories = _tasksBox.values
        .map((task) => task.category)
        .where((category) => category != null && category.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await _settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key) {
    return _settingsBox.get(key) as T?;
  }

  static Future<void> clearAllData() async {
    await _tasksBox.clear();
    await _settingsBox.clear();
  }

  static Future<void> close() async {
    await _tasksBox.close();
    await _settingsBox.close();
  }
}
