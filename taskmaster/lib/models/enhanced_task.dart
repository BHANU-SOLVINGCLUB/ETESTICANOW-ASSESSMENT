import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

// part 'enhanced_task.g.dart';

@HiveType(typeId: 1)
class EnhancedTask extends HiveObject with EquatableMixin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool isCompleted;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime? dueDate;

  @HiveField(6)
  final TaskPriority priority;

  @HiveField(7)
  final String? category;

  @HiveField(8)
  final DateTime? completedAt;

  @HiveField(9)
  final DateTime? updatedAt;

  @HiveField(10)
  final List<String> tags;

  @HiveField(11)
  final String? notes;

  @HiveField(12)
  final bool isArchived;

  @HiveField(13)
  final int sortOrder;

  @HiveField(14)
  final int estimatedMinutes;

  @HiveField(15)
  final int actualMinutes;

  @HiveField(16)
  final String? location;

  @HiveField(17)
  final bool isRecurring;

  @HiveField(18)
  final RecurrenceType? recurrenceType;

  @HiveField(19)
  final int? recurrenceInterval;

  EnhancedTask({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = TaskPriority.medium,
    this.category,
    this.completedAt,
    this.updatedAt,
    this.tags = const [],
    this.notes,
    this.isArchived = false,
    this.sortOrder = 0,
    this.estimatedMinutes = 0,
    this.actualMinutes = 0,
    this.location,
    this.isRecurring = false,
    this.recurrenceType,
    this.recurrenceInterval,
  });

  EnhancedTask copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    TaskPriority? priority,
    String? category,
    DateTime? completedAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? notes,
    bool? isArchived,
    int? sortOrder,
    int? estimatedMinutes,
    int? actualMinutes,
    String? location,
    bool? isRecurring,
    RecurrenceType? recurrenceType,
    int? recurrenceInterval,
  }) {
    return EnhancedTask(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isArchived: isArchived ?? this.isArchived,
      sortOrder: sortOrder ?? this.sortOrder,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      actualMinutes: actualMinutes ?? this.actualMinutes,
      location: location ?? this.location,
      isRecurring: isRecurring ?? this.isRecurring,
      recurrenceType: recurrenceType ?? this.recurrenceType,
      recurrenceInterval: recurrenceInterval ?? this.recurrenceInterval,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        isCompleted,
        createdAt,
        dueDate,
        priority,
        category,
        completedAt,
        updatedAt,
        tags,
        notes,
        isArchived,
        sortOrder,
        estimatedMinutes,
        actualMinutes,
        location,
        isRecurring,
        recurrenceType,
        recurrenceInterval,
      ];

  // Business logic methods
  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.day == now.day &&
           dueDate!.month == now.month &&
           dueDate!.year == now.year;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.day == tomorrow.day &&
           dueDate!.month == tomorrow.month &&
           dueDate!.year == tomorrow.year;
  }

  Duration? get timeUntilDue {
    if (dueDate == null) return null;
    return dueDate!.difference(DateTime.now());
  }

  double get completionProgress {
    if (estimatedMinutes == 0) return 0.0;
    return (actualMinutes / estimatedMinutes).clamp(0.0, 1.0);
  }

  bool get hasTimeTracking => estimatedMinutes > 0 || actualMinutes > 0;

  String get priorityDisplayName => priority.displayName;

  String get categoryDisplayName => category ?? 'Uncategorized';

  List<String> get displayTags => tags.where((tag) => tag.isNotEmpty).toList();

  bool get hasLocation => location != null && location!.isNotEmpty;

  bool get isRecurringTask => isRecurring && recurrenceType != null;

  String get statusText {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';
    if (isDueToday) return 'Due Today';
    if (isDueTomorrow) return 'Due Tomorrow';
    return 'Pending';
  }
}

@HiveType(typeId: 2)
enum TaskPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent,
}

@HiveType(typeId: 3)
enum RecurrenceType {
  @HiveField(0)
  daily,
  @HiveField(1)
  weekly,
  @HiveField(2)
  monthly,
  @HiveField(3)
  yearly,
}

extension TaskPriorityExtension on TaskPriority {
  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  int get value {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
      case TaskPriority.urgent:
        return 4;
    }
  }

  String get colorCode {
    switch (this) {
      case TaskPriority.low:
        return '#4CAF50'; // Green
      case TaskPriority.medium:
        return '#FF9800'; // Orange
      case TaskPriority.high:
        return '#F44336'; // Red
      case TaskPriority.urgent:
        return '#9C27B0'; // Purple
    }
  }
}

extension RecurrenceTypeExtension on RecurrenceType {
  String get displayName {
    switch (this) {
      case RecurrenceType.daily:
        return 'Daily';
      case RecurrenceType.weekly:
        return 'Weekly';
      case RecurrenceType.monthly:
        return 'Monthly';
      case RecurrenceType.yearly:
        return 'Yearly';
    }
  }
}
