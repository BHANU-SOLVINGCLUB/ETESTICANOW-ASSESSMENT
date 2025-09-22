import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../models/task_sort_option.dart';
import '../services/hive_service.dart';
import '../services/task_repository.dart';

class SimpleTaskProvider with ChangeNotifier {
  final TaskRepository _repository;
  SimpleTaskProvider({TaskRepository? repository}) : _repository = repository ?? HiveTaskRepository(HiveService);
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<Task> get tasks => _tasks;
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Grouping
  bool _groupByCategory = false;
  bool get groupByCategory => _groupByCategory;
  void toggleGroupByCategory() {
    _groupByCategory = !_groupByCategory;
    notifyListeners();
  }

  Map<String, List<Task>> get tasksGroupedByCategory {
    final Map<String, List<Task>> grouped = {};
    for (final task in _tasks) {
      final key = (task.category == null || task.category!.isEmpty) ? 'Uncategorized' : task.category!;
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(task);
    }
    final sortedKeys = grouped.keys.toList()..sort();
    return { for (final k in sortedKeys) k : grouped[k]! };
  }

  // Statistics
  int get totalTasks => _tasks.length;
  int get completedTasksCount => completedTasks.length;
  int get pendingTasksCount => pendingTasks.length;
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return (completedTasksCount / totalTasks) * 100;
  }

  // Categories
  List<String> get categories {
    final categorySet = _tasks
        .where((task) => task.category != null && task.category!.isNotEmpty)
        .map((task) => task.category!)
        .toSet();
    return categorySet.toList()..sort();
  }

  // Initialize
  Future<void> initialize() async {
    await loadTasks();
  }

  // Load tasks
  Future<void> loadTasks() async {
    _setLoading(true);
    try {
      _tasks = _repository.getAllTasks();
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load tasks: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add task
  Future<void> addTask(Task task) async {
    try {
      await _repository.saveTask(task);
      _tasks.add(task);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to add task: $e');
    }
  }

  // Update task
  Future<void> updateTask(Task task) async {
    try {
      await _repository.saveTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
        _clearError();
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update task: $e');
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      await _repository.deleteTask(taskId);
      _tasks.removeWhere((task) => task.id == taskId);
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete task: $e');
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await updateTask(updatedTask);
    } catch (e) {
      _setError('Failed to toggle task: $e');
    }
  }

  // Get tasks for filter
  List<Task> getTasksForFilter(TaskFilterType filterType) {
    switch (filterType) {
      case TaskFilterType.pending:
        return pendingTasks;
      case TaskFilterType.completed:
        return completedTasks;
      case TaskFilterType.all:
        return _tasks;
    }
  }

  // Search tasks
  List<Task> searchTasks(String query) {
    if (query.isEmpty) return _tasks;
    
    return _tasks.where((task) {
      return task.title.toLowerCase().contains(query.toLowerCase()) ||
             task.description.toLowerCase().contains(query.toLowerCase()) ||
             (task.category?.toLowerCase().contains(query.toLowerCase()) ?? false);
    }).toList();
  }

  // Advanced search with multiple filters
  List<Task> advancedSearch({
    String query = '',
    String? category,
    TaskPriority? priority,
    bool? isCompleted,
    bool? isOverdue,
    TaskSortOption sortOption = TaskSortOption.createdDate,
  }) {
    List<Task> results = List.from(_tasks);

    // Apply search query
    if (query.isNotEmpty) {
      results = results.where((task) {
        return task.title.toLowerCase().contains(query.toLowerCase()) ||
               task.description.toLowerCase().contains(query.toLowerCase()) ||
               (task.category?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    }

    // Apply category filter
    if (category != null) {
      results = results.where((task) => task.category == category).toList();
    }

    // Apply priority filter
    if (priority != null) {
      results = results.where((task) => task.priority == priority).toList();
    }

    // Apply completion filter
    if (isCompleted != null) {
      results = results.where((task) => task.isCompleted == isCompleted).toList();
    }

    // Apply overdue filter
    if (isOverdue == true) {
      final now = DateTime.now();
      results = results.where((task) {
        return task.dueDate != null && 
               task.dueDate!.isBefore(now) && 
               !task.isCompleted;
      }).toList();
    }

    // Apply sorting
    switch (sortOption) {
      case TaskSortOption.createdDate:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortOption.dueDate:
        results.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSortOption.priority:
        results.sort((a, b) => b.priority.value.compareTo(a.priority.value));
        break;
      case TaskSortOption.title:
        results.sort((a, b) => a.title.compareTo(b.title));
        break;
      case TaskSortOption.category:
        results.sort((a, b) {
          final aCategory = a.category ?? '';
          final bCategory = b.category ?? '';
          return aCategory.compareTo(bCategory);
        });
        break;
    }

    return results;
  }

  // Filter by category
  List<Task> filterByCategory(String category) {
    return _tasks.where((task) => task.category == category).toList();
  }

  // Clear filters
  void clearFilters() {
    // Filters are now handled locally in widgets
    notifyListeners();
  }

  // Sort tasks
  void sortTasks(TaskSortOption sortOption) {
    switch (sortOption) {
      case TaskSortOption.createdDate:
        _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortOption.dueDate:
        _tasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSortOption.priority:
        _tasks.sort((a, b) => b.priority.value.compareTo(a.priority.value));
        break;
      case TaskSortOption.title:
        _tasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case TaskSortOption.category:
        _tasks.sort((a, b) {
          final aCategory = a.category ?? '';
          final bCategory = b.category ?? '';
          return aCategory.compareTo(bCategory);
        });
        break;
    }
    notifyListeners();
  }

  // Show completed tasks
  bool get showCompleted => _showCompleted;
  bool _showCompleted = true;

  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    notifyListeners();
  }

  // Clear error
  void _clearError() {
    _errorMessage = null;
  }

  // Set error
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Set loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}

enum TaskFilterType {
  all,
  pending,
  completed,
}
