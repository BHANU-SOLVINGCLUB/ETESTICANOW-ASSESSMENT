import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../providers/simple_task_provider.dart';
import '../models/task_tab.dart';
import '../models/task.dart';
import '../widgets/task_tile.dart';
import '../widgets/empty_state.dart';
import '../screens/add_task_screen.dart';
import '../screens/edit_task_screen.dart';
import '../core/theme/app_theme.dart';

class _CategorySection extends StatelessWidget {
  final String title;
  final List<Task> tasks;
  const _CategorySection({required this.title, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 18,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    '$title (${tasks.length})',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ...tasks.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
                child: TaskTile(
                  task: t,
                  onTap: () {},
                  onToggle: () => context.read<SimpleTaskProvider>().toggleTaskCompletion(t.id),
                  onEdit: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditTaskScreen(task: t),
                      ),
                    );
                  },
                  onDelete: () => context.read<SimpleTaskProvider>().deleteTask(t.id),
                ),
              )),
        ],
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final TaskTab tab;

  const TaskList({
    super.key,
    required this.tab,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<SimpleTaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = taskProvider.getTasksForFilter(_getFilterTypeFromTab(tab));

        if (tasks.isEmpty) {
          return _buildEmptyState(context);
        }

        if (taskProvider.groupByCategory) {
          final grouped = taskProvider.tasksGroupedByCategory;
          return RefreshIndicator(
            onRefresh: () async {
              await taskProvider.loadTasks();
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingM,
                AppTheme.spacingXS,
                AppTheme.spacingM,
                AppTheme.spacingS,
              ),
              itemCount: grouped.keys.length,
              itemBuilder: (context, sectionIndex) {
                final category = grouped.keys.elementAt(sectionIndex);
                final sectionTasks = grouped[category]!;
                return _CategorySection(
                  title: category,
                  tasks: sectionTasks,
                );
              },
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await taskProvider.loadTasks();
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingM,
              AppTheme.spacingXS,
              AppTheme.spacingM,
              AppTheme.spacingS,
            ),
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              final theme = Theme.of(context);
              
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spacingXS),
                child: Slidable(
                  key: ValueKey(task.id),
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.3,
                    children: [
                      SlidableAction(
                        onPressed: (context) => _editTask(context, task),
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        icon: Icons.edit_rounded,
                        label: 'Edit',
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(AppTheme.radiusL),
                          bottomLeft: Radius.circular(AppTheme.radiusL),
                        ),
                      ),
                      SlidableAction(
                        onPressed: (context) => _deleteTask(context, taskProvider, task),
                        backgroundColor: AppTheme.errorColor,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_rounded,
                        label: 'Delete',
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(AppTheme.radiusL),
                          bottomRight: Radius.circular(AppTheme.radiusL),
                        ),
                      ),
                    ],
                  ),
                  child: Tooltip(
                    message: 'Swipe left for edit and delete options',
                    child: TaskTile(
                      task: task,
                      onTap: () => _editTask(context, task),
                      onToggle: () => _toggleTask(context, taskProvider, task),
                      onEdit: () => _editTask(context, task),
                      onDelete: () => _deleteTask(context, taskProvider, task),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    String title;
    String subtitle;
    IconData icon;

    switch (tab) {
      case TaskTab.pending:
        title = 'No Pending Tasks';
        subtitle = 'All caught up! Add a new task to get started.';
        icon = Icons.check_circle_outline;
        break;
      case TaskTab.completed:
        title = 'No Completed Tasks';
        subtitle = 'Complete some tasks to see them here.';
        icon = Icons.task_alt;
        break;
      case TaskTab.all:
        title = 'No Tasks Yet';
        subtitle = 'Create your first task to get organized!';
        icon = Icons.add_task;
        break;
    }

    return EmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      actionText: 'Add Task',
      onActionPressed: () => _addTask(context),
    );
  }

  void _toggleTask(BuildContext context, SimpleTaskProvider taskProvider, Task task) {
    taskProvider.toggleTaskCompletion(task.id);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task.isCompleted ? 'Task marked as pending' : 'Task completed!',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteTask(BuildContext context, SimpleTaskProvider taskProvider, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskProvider.deleteTask(task.id);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _editTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditTaskScreen(task: task),
      ),
    );
  }

  void _addTask(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddTaskScreen(),
      ),
    );
  }

  TaskFilterType _getFilterTypeFromTab(TaskTab tab) {
    switch (tab) {
      case TaskTab.pending:
        return TaskFilterType.pending;
      case TaskTab.completed:
        return TaskFilterType.completed;
      case TaskTab.all:
        return TaskFilterType.all;
    }
  }
}
