import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../core/theme/app_theme.dart';
import 'task_detail_sheet.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final VoidCallback? onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskTile({
    super.key,
    required this.task,
    this.onTap,
    this.onToggle,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: () => _showDetailsSheet(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
            color: task.isCompleted 
                ? theme.colorScheme.surface.withValues(alpha: 0.5)
                : theme.colorScheme.surface,
          ),
          constraints: const BoxConstraints(minHeight: 88),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            child: Row(
              children: [
                _buildCheckbox(context, isDark),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: _buildTaskContent(context, isDark),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingS,
                      vertical: AppTheme.spacingXS,
                    ),
                    child: Text(
                      'Swipe left to edit or delete',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      softWrap: true,
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return TaskDetailSheet(
          task: task,
          onEdit: onEdit ?? () {},
          onDelete: onDelete ?? () {},
          onToggleComplete: onToggle ?? () {},
        );
      },
    );
  }

  Widget _buildCheckbox(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final checkboxColor = task.isCompleted ? AppTheme.successColor : theme.colorScheme.outline;
    
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: checkboxColor,
            width: 2,
          ),
          color: task.isCompleted
              ? checkboxColor
              : Colors.transparent,
        ),
        child: task.isCompleted
            ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildTaskContent(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final textColor = task.isCompleted 
        ? theme.colorScheme.onSurface.withValues(alpha: 0.6)
        : theme.colorScheme.onSurface;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          task.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: textColor,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: AppTheme.spacingS),
        Wrap(
          spacing: AppTheme.spacingS,
          runSpacing: AppTheme.spacingXS,
          children: [
            if (task.category != null && task.category!.isNotEmpty)
              _buildCategoryChip(context),
            if (task.dueDate != null)
              _buildDueDateChip(context),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Text(
        task.category!,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDueDateChip(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final dueDate = task.dueDate!;
    final isOverdue = dueDate.isBefore(now) && !task.isCompleted;
    final isDueToday = dueDate.day == now.day && 
                      dueDate.month == now.month && 
                      dueDate.year == now.year;

    Color chipColor;
    if (isOverdue) {
      chipColor = AppTheme.errorColor;
    } else if (isDueToday) {
      chipColor = AppTheme.warningColor;
    } else {
      chipColor = AppTheme.successColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusS),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 12,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            _formatDueDate(dueDate),
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: chipColor,
            ),
          ),
        ],
      ),
    );
  }

  // Removed priority indicator bar per request

  String _formatDueDate(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference < 0) {
      return '${difference.abs()} days ago';
    } else if (difference <= 7) {
      return 'In $difference days';
    } else {
      return DateFormat('MMM dd').format(dueDate);
    }
  }

  // Trailing action buttons removed in favor of swipe actions text hint.
}
