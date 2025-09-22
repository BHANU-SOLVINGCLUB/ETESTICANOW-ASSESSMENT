import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/hive_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  String? _selectedCategory;
  TaskSortOption _sortOption = TaskSortOption.createdDate;
  bool _showCompleted = false;

  // Getters
  List<Task> get allTasks => _allTasks;
  List<Task> get filteredTasks => _filteredTasks;
  List<Task> get pendingTasks => _allTasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _allTasks.where((task) => task.isCompleted).toList();
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  TaskSortOption get sortOption => _sortOption;
  bool get showCompleted => _showCompleted;
  List<String> get categories => HiveService.getAllCategories();

  // Statistics
  int get totalTasks => _allTasks.length;
  int get completedTasksCount => completedTasks.length;
  int get pendingTasksCount => pendingTasks.length;
  double get completionPercentage {
    if (totalTasks == 0) return 0.0;
    return (completedTasksCount / totalTasks) * 100;
  }

  // Initialize
  Future<void> initialize() async {
    await loadTasks();
  }

  // Load tasks from storage
  Future<void> loadTasks() async {
    _allTasks = HiveService.getAllTasks();
    _applyFilters();
    notifyListeners();
  }

  // Add new task
  Future<void> addTask({
    required String title,
    String description = '',
    DateTime? dueDate,
    TaskPriority priority = TaskPriority.medium,
    String? category,
  }) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
      category: category,
    );

    await HiveService.saveTask(task);
    _allTasks.add(task);
    _applyFilters();
    notifyListeners();
  }

  // Update task
  Future<void> updateTask(Task updatedTask) async {
    await HiveService.saveTask(updatedTask);
    final index = _allTasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _allTasks[index] = updatedTask;
    }
    _applyFilters();
    notifyListeners();
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    final task = _allTasks.firstWhere((task) => task.id == taskId);
    final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
    await updateTask(updatedTask);
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    await HiveService.deleteTask(taskId);
    _allTasks.removeWhere((task) => task.id == taskId);
    _applyFilters();
    notifyListeners();
  }

  // Search tasks
  void searchTasks(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Sort tasks
  void sortTasks(TaskSortOption sortOption) {
    _sortOption = sortOption;
    _applyFilters();
    notifyListeners();
  }

  // Toggle show completed tasks
  void toggleShowCompleted() {
    _showCompleted = !_showCompleted;
    _applyFilters();
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _sortOption = TaskSortOption.createdDate;
    _showCompleted = false;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters and sorting
  void _applyFilters() {
    List<Task> tasks = List.from(_allTasks);

    // Filter by completion status
    if (!_showCompleted) {
      tasks = tasks.where((task) => !task.isCompleted).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      tasks = tasks.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
               task.description.toLowerCase().contains(lowerQuery) ||
               (task.category?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      tasks = tasks.where((task) => task.category == _selectedCategory).toList();
    }

    // Sort tasks
    tasks.sort((a, b) {
      switch (_sortOption) {
        case TaskSortOption.createdDate:
          return b.createdAt.compareTo(a.createdAt);
        case TaskSortOption.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case TaskSortOption.priority:
          return b.priority.value.compareTo(a.priority.value);
        case TaskSortOption.title:
          return a.title.compareTo(b.title);
        case TaskSortOption.completionStatus:
          return a.isCompleted.toString().compareTo(b.isCompleted.toString());
      }
    });

    _filteredTasks = tasks;
  }

  // Get tasks for specific tab
  List<Task> getTasksForTab(TaskTab tab) {
    switch (tab) {
      case TaskTab.pending:
        return _filteredTasks.where((task) => !task.isCompleted).toList();
      case TaskTab.completed:
        return _filteredTasks.where((task) => task.isCompleted).toList();
      case TaskTab.all:
        return _filteredTasks;
    }
  }
}

enum TaskSortOption {
  createdDate,
  dueDate,
  priority,
  title,
  completionStatus,
}

enum TaskTab {
  pending,
  completed,
  all,
}

extension TaskSortOptionExtension on TaskSortOption {
  String get displayName {
    switch (this) {
      case TaskSortOption.createdDate:
        return 'Created Date';
      case TaskSortOption.dueDate:
        return 'Due Date';
      case TaskSortOption.priority:
        return 'Priority';
      case TaskSortOption.title:
        return 'Title';
      case TaskSortOption.completionStatus:
        return 'Completion Status';
    }
  }
}
