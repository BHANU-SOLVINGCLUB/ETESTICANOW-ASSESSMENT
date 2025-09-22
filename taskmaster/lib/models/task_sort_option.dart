enum TaskSortOption {
  createdDate,
  dueDate,
  priority,
  title,
  category,
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
      case TaskSortOption.category:
        return 'Category';
    }
  }
}
