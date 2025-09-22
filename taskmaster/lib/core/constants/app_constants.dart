class AppConstants {
  // App Information
  static const String appName = 'TaskMaster';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Storage Keys
  static const String tasksBoxName = 'tasks';
  static const String settingsBoxName = 'settings';
  static const String userPreferencesKey = 'user_preferences';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';
  
  // API Configuration
  static const String baseUrl = 'https://api.taskmaster.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Task Configuration
  static const int maxTasksPerUser = 1000;
  static const int maxTaskTitleLength = 200;
  static const int maxTaskDescriptionLength = 1000;
  static const int maxCategoryNameLength = 50;
  
  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Error Messages
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String storageErrorMessage = 'Failed to save data. Please try again.';
  static const String validationErrorMessage = 'Please check your input and try again.';
  
  // Success Messages
  static const String taskCreatedMessage = 'Task created successfully!';
  static const String taskUpdatedMessage = 'Task updated successfully!';
  static const String taskDeletedMessage = 'Task deleted successfully!';
  static const String taskCompletedMessage = 'Task completed!';
  
  // Validation Rules
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 128;
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  // Feature Flags
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
  static const bool enableLogging = true;
  static const bool enableOfflineMode = true;
}
