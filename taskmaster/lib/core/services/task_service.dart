import 'package:hive_flutter/hive_flutter.dart';
import '../error/exceptions.dart';
import '../error/failures.dart';
import '../logger/app_logger.dart';
import '../../models/enhanced_task.dart';

abstract class TaskService {
  Future<List<EnhancedTask>> getAllTasks();
  Future<EnhancedTask?> getTaskById(String id);
  Future<String> createTask(EnhancedTask task);
  Future<void> updateTask(EnhancedTask task);
  Future<void> deleteTask(String id);
  Future<void> toggleTaskCompletion(String id);
  Future<List<EnhancedTask>> searchTasks(String query);
  Future<List<EnhancedTask>> getTasksByCategory(String category);
  Future<List<EnhancedTask>> getTasksByPriority(TaskPriority priority);
  Future<List<EnhancedTask>> getOverdueTasks();
  Future<List<EnhancedTask>> getTasksDueToday();
  Future<List<EnhancedTask>> getCompletedTasks();
  Future<List<EnhancedTask>> getPendingTasks();
  Future<void> archiveTask(String id);
  Future<void> unarchiveTask(String id);
  Future<List<String>> getAllCategories();
  Future<List<String>> getAllTags();
  Future<void> clearCompletedTasks();
  Future<void> clearArchivedTasks();
  Future<Map<String, dynamic>> getTaskStatistics();
}

class TaskServiceImpl implements TaskService {
  static const String _tasksBoxName = 'enhanced_tasks';
  static late Box<EnhancedTask> _tasksBox;

  static Future<void> init() async {
    try {
      _tasksBox = await Hive.openBox<EnhancedTask>(_tasksBoxName);
      AppLogger.info('Task service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize task service', e);
      throw DatabaseException(
        message: 'Failed to initialize task database',
        details: e,
      );
    }
  }

  @override
  Future<List<EnhancedTask>> getAllTasks() async {
    try {
      final tasks = _tasksBox.values.toList();
      AppLogger.debug('Retrieved ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      AppLogger.error('Failed to get all tasks', e);
      throw DatabaseException(
        message: 'Failed to retrieve tasks',
        details: e,
      );
    }
  }

  @override
  Future<EnhancedTask?> getTaskById(String id) async {
    try {
      final task = _tasksBox.get(id);
      if (task != null) {
        AppLogger.debug('Retrieved task: $id');
      } else {
        AppLogger.warning('Task not found: $id');
      }
      return task;
    } catch (e) {
      AppLogger.error('Failed to get task by id: $id', e);
      throw DatabaseException(
        message: 'Failed to retrieve task',
        details: e,
      );
    }
  }

  @override
  Future<String> createTask(EnhancedTask task) async {
    try {
      await _tasksBox.put(task.id, task);
      AppLogger.info('Task created successfully: ${task.id}');
      return task.id;
    } catch (e) {
      AppLogger.error('Failed to create task: ${task.id}', e);
      throw DatabaseException(
        message: 'Failed to create task',
        details: e,
      );
    }
  }

  @override
  Future<void> updateTask(EnhancedTask task) async {
    try {
      final updatedTask = task.copyWith(updatedAt: DateTime.now());
      await _tasksBox.put(task.id, updatedTask);
      AppLogger.info('Task updated successfully: ${task.id}');
    } catch (e) {
      AppLogger.error('Failed to update task: ${task.id}', e);
      throw DatabaseException(
        message: 'Failed to update task',
        details: e,
      );
    }
  }

  @override
  Future<void> deleteTask(String id) async {
    try {
      await _tasksBox.delete(id);
      AppLogger.info('Task deleted successfully: $id');
    } catch (e) {
      AppLogger.error('Failed to delete task: $id', e);
      throw DatabaseException(
        message: 'Failed to delete task',
        details: e,
      );
    }
  }

  @override
  Future<void> toggleTaskCompletion(String id) async {
    try {
      final task = await getTaskById(id);
      if (task == null) {
        throw DatabaseException(message: 'Task not found: $id');
      }

      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      await updateTask(updatedTask);
      AppLogger.info('Task completion toggled: $id');
    } catch (e) {
      AppLogger.error('Failed to toggle task completion: $id', e);
      rethrow;
    }
  }

  @override
  Future<List<EnhancedTask>> searchTasks(String query) async {
    try {
      final allTasks = await getAllTasks();
      final filteredTasks = allTasks.where((task) {
        final searchQuery = query.toLowerCase();
        return task.title.toLowerCase().contains(searchQuery) ||
               task.description.toLowerCase().contains(searchQuery) ||
               (task.category?.toLowerCase().contains(searchQuery) ?? false) ||
               task.tags.any((tag) => tag.toLowerCase().contains(searchQuery)) ||
               (task.notes?.toLowerCase().contains(searchQuery) ?? false);
      }).toList();

      AppLogger.debug('Search completed: ${filteredTasks.length} tasks found for query: $query');
      return filteredTasks;
    } catch (e) {
      AppLogger.error('Failed to search tasks: $query', e);
      throw DatabaseException(
        message: 'Failed to search tasks',
        details: e,
      );
    }
  }

  @override
  Future<List<EnhancedTask>> getTasksByCategory(String category) async {
    try {
      final allTasks = await getAllTasks();
      final filteredTasks = allTasks.where((task) => task.category == category).toList();
      AppLogger.debug('Retrieved ${filteredTasks.length} tasks for category: $category');
      return filteredTasks;
    } catch (e) {
      AppLogger.error('Failed to get tasks by category: $category', e);
      throw DatabaseException(
        message: 'Failed to get tasks by category',
        details: e,
      );
    }
  }

  @override
  Future<List<EnhancedTask>> getTasksByPriority(TaskPriority priority) async {
    try {
      final allTasks = await getAllTasks();
      final filteredTasks = allTasks.where((task) => task.priority == priority).toList();
      AppLogger.debug('Retrieved ${filteredTasks.length} tasks for priority: ${priority.displayName}');
      return filteredTasks;
    } catch (e) {
      AppLogger.error('Failed to get tasks by priority: ${priority.displayName}', e);
      throw DatabaseException(
        message: 'Failed to get tasks by priority',
        details: e,
      );
    }
  }

  @override
  Future<List<EnhancedTask>> getOverdueTasks() async {
    try {
      final allTasks = await getAllTasks();
      final overdueTasks = allTasks.where((task) => task.isOverdue).toList();
      AppLogger.debug('Retrieved ${overdueTasks.length} overdue tasks');
      return overdueTasks;
    } catch (e) {
      AppLogger.error('Failed to get overdue tasks', e);
      throw DatabaseException(
        message: 'Failed to get overdue tasks',
        details: e,
      );
    }
  }

  @override
  Future<List<EnhancedTask>> getTasksDueToday() async {
    try {
      final allTasks = await getAllTasks();
      final todayTasks = allTasks.where((task) => task.isDueToday).toList();
      AppLogger.debug('Retrieved ${todayTasks.length} tasks due today');
      return todayTasks;
    } catch (e) {
      AppLogger.error('Failed to get tasks due today', e);
      throw DatabaseException(
        message: 'Failed to get tasks due today',
        details: e,
      );
    }
  }

  @override
  Future<List<EnhancedTask>> getCompletedTasks() async {
    try {
      final allTasks = await getAllTasks();
      final completedTasks = allTasks.where((task) => task.isCompleted).toList();
      AppLogger.debug('Retrieved ${completedTasks.length} completed tasks');
      return completedTasks;
    } catch (e) {
      AppLogger.error('Failed to get completed tasks', e);
      throw DatabaseException(
        message: 'Failed to get completed tasks',
        details: e,
      );
    }
  }

  @override
  Future<List<EnhancedTask>> getPendingTasks() async {
    try {
      final allTasks = await getAllTasks();
      final pendingTasks = allTasks.where((task) => !task.isCompleted).toList();
      AppLogger.debug('Retrieved ${pendingTasks.length} pending tasks');
      return pendingTasks;
    } catch (e) {
      AppLogger.error('Failed to get pending tasks', e);
      throw DatabaseException(
        message: 'Failed to get pending tasks',
        details: e,
      );
    }
  }

  @override
  Future<void> archiveTask(String id) async {
    try {
      final task = await getTaskById(id);
      if (task == null) {
        throw DatabaseException(message: 'Task not found: $id');
      }

      final archivedTask = task.copyWith(
        isArchived: true,
        updatedAt: DateTime.now(),
      );

      await updateTask(archivedTask);
      AppLogger.info('Task archived: $id');
    } catch (e) {
      AppLogger.error('Failed to archive task: $id', e);
      rethrow;
    }
  }

  @override
  Future<void> unarchiveTask(String id) async {
    try {
      final task = await getTaskById(id);
      if (task == null) {
        throw DatabaseException(message: 'Task not found: $id');
      }

      final unarchivedTask = task.copyWith(
        isArchived: false,
        updatedAt: DateTime.now(),
      );

      await updateTask(unarchivedTask);
      AppLogger.info('Task unarchived: $id');
    } catch (e) {
      AppLogger.error('Failed to unarchive task: $id', e);
      rethrow;
    }
  }

  @override
  Future<List<String>> getAllCategories() async {
    try {
      final allTasks = await getAllTasks();
      final categories = allTasks
          .map((task) => task.category)
          .where((category) => category != null && category.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      categories.sort();
      AppLogger.debug('Retrieved ${categories.length} categories');
      return categories;
    } catch (e) {
      AppLogger.error('Failed to get all categories', e);
      throw DatabaseException(
        message: 'Failed to get categories',
        details: e,
      );
    }
  }

  @override
  Future<List<String>> getAllTags() async {
    try {
      final allTasks = await getAllTasks();
      final tags = allTasks
          .expand((task) => task.tags)
          .where((tag) => tag.isNotEmpty)
          .toSet()
          .toList();
      tags.sort();
      AppLogger.debug('Retrieved ${tags.length} tags');
      return tags;
    } catch (e) {
      AppLogger.error('Failed to get all tags', e);
      throw DatabaseException(
        message: 'Failed to get tags',
        details: e,
      );
    }
  }

  @override
  Future<void> clearCompletedTasks() async {
    try {
      final completedTasks = await getCompletedTasks();
      for (final task in completedTasks) {
        await deleteTask(task.id);
      }
      AppLogger.info('Cleared ${completedTasks.length} completed tasks');
    } catch (e) {
      AppLogger.error('Failed to clear completed tasks', e);
      throw DatabaseException(
        message: 'Failed to clear completed tasks',
        details: e,
      );
    }
  }

  @override
  Future<void> clearArchivedTasks() async {
    try {
      final allTasks = await getAllTasks();
      final archivedTasks = allTasks.where((task) => task.isArchived).toList();
      for (final task in archivedTasks) {
        await deleteTask(task.id);
      }
      AppLogger.info('Cleared ${archivedTasks.length} archived tasks');
    } catch (e) {
      AppLogger.error('Failed to clear archived tasks', e);
      throw DatabaseException(
        message: 'Failed to clear archived tasks',
        details: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getTaskStatistics() async {
    try {
      final allTasks = await getAllTasks();
      final completedTasks = allTasks.where((task) => task.isCompleted).length;
      final pendingTasks = allTasks.where((task) => !task.isCompleted).length;
      final overdueTasks = allTasks.where((task) => task.isOverdue).length;
      final todayTasks = allTasks.where((task) => task.isDueToday).length;
      final totalEstimatedMinutes = allTasks.fold(0, (sum, task) => sum + task.estimatedMinutes);
      final totalActualMinutes = allTasks.fold(0, (sum, task) => sum + task.actualMinutes);

      final stats = {
        'totalTasks': allTasks.length,
        'completedTasks': completedTasks,
        'pendingTasks': pendingTasks,
        'overdueTasks': overdueTasks,
        'todayTasks': todayTasks,
        'completionRate': allTasks.isEmpty ? 0.0 : (completedTasks / allTasks.length) * 100,
        'totalEstimatedMinutes': totalEstimatedMinutes,
        'totalActualMinutes': totalActualMinutes,
        'efficiency': totalEstimatedMinutes == 0 ? 0.0 : (totalActualMinutes / totalEstimatedMinutes) * 100,
      };

      AppLogger.debug('Task statistics calculated: $stats');
      return stats;
    } catch (e) {
      AppLogger.error('Failed to calculate task statistics', e);
      throw DatabaseException(
        message: 'Failed to calculate statistics',
        details: e,
      );
    }
  }
}
