import 'package:flutter/foundation.dart';
import '../core/logger/app_logger.dart';
import '../core/services/task_service.dart';
import '../core/error/failures.dart';
import '../models/enhanced_task.dart';

class EnhancedTaskProvider with ChangeNotifier {
  final TaskService _taskService;
  
  List<EnhancedTask> _allTasks = [];
  List<EnhancedTask> _filteredTasks = [];
  String _searchQuery = '';
  String? _selectedCategory;
  TaskPriority? _selectedPriority;
  TaskFilterType _filterType = TaskFilterType.all;
  TaskSortOption _sortOption = TaskSortOption.createdDate;
  bool _showArchived = false;
  bool _isLoading = false;
  String? _errorMessage;

  EnhancedTaskProvider(this._taskService);

  // Getters
  List<EnhancedTask> get allTasks => _allTasks;
  List<EnhancedTask> get filteredTasks => _filteredTasks;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;
  TaskPriority? get selectedPriority => _selectedPriority;
  TaskFilterType get filterType => _filterType;
  TaskSortOption get sortOption => _sortOption;
  bool get showArchived => _showArchived;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Statistics
  Map<String, dynamic> get statistics => _calculateStatistics();
  int get totalTasks => _allTasks.length;
  int get completedTasksCount => _allTasks.where((task) => task.isCompleted).length;
  int get pendingTasksCount => _allTasks.where((task) => !task.isCompleted).length;
  int get overdueTasksCount => _allTasks.where((task) => task.isOverdue).length;
  int get todayTasksCount => _allTasks.where((task) => task.isDueToday).length;
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
    _setLoading(true);
    _clearError();

    try {
      AppLogger.logTaskOperation('load_tasks', 'all');
      _allTasks = await _taskService.getAllTasks();
      _applyFilters();
      AppLogger.info('Tasks loaded successfully: ${_allTasks.length} tasks');
    } catch (e) {
      _setError('Failed to load tasks: ${e.toString()}');
      AppLogger.error('Failed to load tasks', e);
    } finally {
      _setLoading(false);
    }
  }

  // Add new task
  Future<void> addTask(EnhancedTask task) async {
    _setLoading(true);
    _clearError();

    try {
      AppLogger.logTaskOperation('create', task.id);
      await _taskService.createTask(task);
      _allTasks.add(task);
      _applyFilters();
      notifyListeners();
      AppLogger.info('Task created successfully: ${task.id}');
    } catch (e) {
      _setError('Failed to create task: ${e.toString()}');
      AppLogger.error('Failed to create task: ${task.id}', e);
    } finally {
      _setLoading(false);
    }
  }

  // Update task
  Future<void> updateTask(EnhancedTask task) async {
    _setLoading(true);
    _clearError();

    try {
      AppLogger.logTaskOperation('update', task.id);
      await _taskService.updateTask(task);
      final index = _allTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _allTasks[index] = task;
      }
      _applyFilters();
      notifyListeners();
      AppLogger.info('Task updated successfully: ${task.id}');
    } catch (e) {
      _setError('Failed to update task: ${e.toString()}');
      AppLogger.error('Failed to update task: ${task.id}', e);
    } finally {
      _setLoading(false);
    }
  }

  // Toggle task completion
  Future<void> toggleTaskCompletion(String taskId) async {
    _setLoading(true);
    _clearError();

    try {
      AppLogger.logTaskOperation('toggle_completion', taskId);
      await _taskService.toggleTaskCompletion(taskId);
      await loadTasks(); // Reload to get updated data
      AppLogger.info('Task completion toggled: $taskId');
    } catch (e) {
      _setError('Failed to toggle task completion: ${e.toString()}');
      AppLogger.error('Failed to toggle task completion: $taskId', e);
    } finally {
      _setLoading(false);
    }
  }

  // Delete task
  Future<void> deleteTask(String taskId) async {
    _setLoading(true);
    _clearError();

    try {
      AppLogger.logTaskOperation('delete', taskId);
      await _taskService.deleteTask(taskId);
      _allTasks.removeWhere((task) => task.id == taskId);
      _applyFilters();
      notifyListeners();
      AppLogger.info('Task deleted successfully: $taskId');
    } catch (e) {
      _setError('Failed to delete task: ${e.toString()}');
      AppLogger.error('Failed to delete task: $taskId', e);
    } finally {
      _setLoading(false);
    }
  }

  // Archive task
  Future<void> archiveTask(String taskId) async {
    _setLoading(true);
    _clearError();

    try {
      AppLogger.logTaskOperation('archive', taskId);
      await _taskService.archiveTask(taskId);
      await loadTasks(); // Reload to get updated data
      AppLogger.info('Task archived: $taskId');
    } catch (e) {
      _setError('Failed to archive task: ${e.toString()}');
      AppLogger.error('Failed to archive task: $taskId', e);
    } finally {
      _setLoading(false);
    }
  }

  // Unarchive task
  Future<void> unarchiveTask(String taskId) async {
    _setLoading(true);
    _clearError();

    try {
      AppLogger.logTaskOperation('unarchive', taskId);
      await _taskService.unarchiveTask(taskId);
      await loadTasks(); // Reload to get updated data
      AppLogger.info('Task unarchived: $taskId');
    } catch (e) {
      _setError('Failed to unarchive task: ${e.toString()}');
      AppLogger.error('Failed to unarchive task: $taskId', e);
    } finally {
      _setLoading(false);
    }
  }

  // Search tasks
  void searchTasks(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
    AppLogger.logUserAction('search_tasks', parameters: {'query': query});
  }

  // Filter by category
  void filterByCategory(String? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
    AppLogger.logUserAction('filter_by_category', parameters: {'category': category});
  }

  // Filter by priority
  void filterByPriority(TaskPriority? priority) {
    _selectedPriority = priority;
    _applyFilters();
    notifyListeners();
    AppLogger.logUserAction('filter_by_priority', parameters: {'priority': priority?.displayName});
  }

  // Set filter type
  void setFilterType(TaskFilterType filterType) {
    _filterType = filterType;
    _applyFilters();
    notifyListeners();
    AppLogger.logUserAction('set_filter_type', parameters: {'filterType': filterType.name});
  }

  // Sort tasks
  void sortTasks(TaskSortOption sortOption) {
    _sortOption = sortOption;
    _applyFilters();
    notifyListeners();
    AppLogger.logUserAction('sort_tasks', parameters: {'sortOption': sortOption.name});
  }

  // Toggle show archived
  void toggleShowArchived() {
    _showArchived = !_showArchived;
    _applyFilters();
    notifyListeners();
    AppLogger.logUserAction('toggle_show_archived', parameters: {'showArchived': _showArchived});
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    _applyFilters();
    notifyListeners();
    AppLogger.logUserAction('clear_search');
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _selectedPriority = null;
    _filterType = TaskFilterType.all;
    _sortOption = TaskSortOption.createdDate;
    _showArchived = false;
    _applyFilters();
    notifyListeners();
    AppLogger.logUserAction('clear_filters');
  }

  // Get tasks for specific filter
  List<EnhancedTask> getTasksForFilter(TaskFilterType filterType) {
    List<EnhancedTask> tasks = List.from(_allTasks);

    // Apply filter type
    switch (filterType) {
      case TaskFilterType.all:
        break;
      case TaskFilterType.pending:
        tasks = tasks.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilterType.completed:
        tasks = tasks.where((task) => task.isCompleted).toList();
        break;
      case TaskFilterType.overdue:
        tasks = tasks.where((task) => task.isOverdue).toList();
        break;
      case TaskFilterType.today:
        tasks = tasks.where((task) => task.isDueToday).toList();
        break;
      case TaskFilterType.archived:
        tasks = tasks.where((task) => task.isArchived).toList();
        break;
    }

    return tasks;
  }

  // Apply all filters and sorting
  void _applyFilters() {
    List<EnhancedTask> tasks = getTasksForFilter(_filterType);

    // Filter by archived status
    if (!_showArchived) {
      tasks = tasks.where((task) => !task.isArchived).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      tasks = tasks.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
               task.description.toLowerCase().contains(lowerQuery) ||
               (task.category?.toLowerCase().contains(lowerQuery) ?? false) ||
               task.tags.any((tag) => tag.toLowerCase().contains(lowerQuery)) ||
               (task.notes?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != null) {
      tasks = tasks.where((task) => task.category == _selectedCategory).toList();
    }

    // Filter by priority
    if (_selectedPriority != null) {
      tasks = tasks.where((task) => task.priority == _selectedPriority).toList();
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
        case TaskSortOption.updatedDate:
          final aUpdated = a.updatedAt ?? a.createdAt;
          final bUpdated = b.updatedAt ?? b.createdAt;
          return bUpdated.compareTo(aUpdated);
      }
    });

    _filteredTasks = tasks;
  }

  // Calculate statistics
  Map<String, dynamic> _calculateStatistics() {
    final completedTasks = _allTasks.where((task) => task.isCompleted).length;
    final pendingTasks = _allTasks.where((task) => !task.isCompleted).length;
    final overdueTasks = _allTasks.where((task) => task.isOverdue).length;
    final todayTasks = _allTasks.where((task) => task.isDueToday).length;
    final totalEstimatedMinutes = _allTasks.fold(0, (sum, task) => sum + task.estimatedMinutes);
    final totalActualMinutes = _allTasks.fold(0, (sum, task) => sum + task.actualMinutes);

    return {
      'totalTasks': _allTasks.length,
      'completedTasks': completedTasks,
      'pendingTasks': pendingTasks,
      'overdueTasks': overdueTasks,
      'todayTasks': todayTasks,
      'completionRate': _allTasks.isEmpty ? 0.0 : (completedTasks / _allTasks.length) * 100,
      'totalEstimatedMinutes': totalEstimatedMinutes,
      'totalActualMinutes': totalActualMinutes,
      'efficiency': totalEstimatedMinutes == 0 ? 0.0 : (totalActualMinutes / totalEstimatedMinutes) * 100,
    };
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

enum TaskFilterType {
  all,
  pending,
  completed,
  overdue,
  today,
  archived,
}

enum TaskSortOption {
  createdDate,
  dueDate,
  priority,
  title,
  completionStatus,
  updatedDate,
}

extension TaskFilterTypeExtension on TaskFilterType {
  String get displayName {
    switch (this) {
      case TaskFilterType.all:
        return 'All Tasks';
      case TaskFilterType.pending:
        return 'Pending';
      case TaskFilterType.completed:
        return 'Completed';
      case TaskFilterType.overdue:
        return 'Overdue';
      case TaskFilterType.today:
        return 'Due Today';
      case TaskFilterType.archived:
        return 'Archived';
    }
  }
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
      case TaskSortOption.updatedDate:
        return 'Updated Date';
    }
  }
}
