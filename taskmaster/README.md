# TaskMaster - Intelligent Task Management

A comprehensive Flutter to-do and notes application with advanced features and beautiful UI.

## 🚀 Features

### Core Features
- ✅ **Add, Edit, Delete Tasks** - Complete CRUD operations
- ✅ **Mark Complete/Incomplete** - Toggle task status with smooth animations
- ✅ **Two Tabs** - Pending & Completed tasks with separate views
- ✅ **Persistent Storage** - Using Hive database for offline support
- ✅ **State Management** - Provider pattern for clean state handling

### Advanced Features
- ✅ **Search & Filter** - Find tasks by title, description, or category
- ✅ **Due Dates** - Set and track task deadlines with visual indicators
- ✅ **Priority Levels** - Low, Medium, High priority with color coding
- ✅ **Categories** - Organize tasks by custom categories
- ✅ **Statistics Dashboard** - Task completion overview with progress bars
- ✅ **Beautiful UI** - Modern Material Design 3 with smooth animations

### Bonus Features
- ✅ **Dark Mode Support** - Toggle between light and dark themes
- ✅ **Swipe Actions** - Swipe to complete or delete tasks
- ✅ **Smart Sorting** - Sort by date, priority, title, or completion status
- ✅ **Empty States** - Beautiful empty state illustrations
- ✅ **Pull-to-Refresh** - Refresh task list with pull gesture

## 🏗️ Architecture

```
lib/
├── models/          # Task data models with Hive annotations
├── providers/       # State management using Provider
├── screens/         # UI screens (Home, Add Task)
├── widgets/         # Reusable UI components
├── services/        # Hive database service
└── utils/           # Helper functions and extensions
```

## 🛠️ Tech Stack

- **Flutter** - UI framework
- **Provider** - State management
- **Hive** - Local database
- **Google Fonts** - Typography
- **Flutter Slidable** - Swipe actions
- **Intl** - Date formatting

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Dart SDK

### Installation

1. **Navigate to the project**
   ```bash
   cd taskmaster
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Generate Hive adapters**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## 📱 Screenshots

### Home Screen
- Task statistics dashboard
- Pending/Completed/All tabs
- Search and filter options
- Beautiful task cards

### Add Task Screen
- Clean form with validation
- Priority selection
- Due date picker
- Category input

### Task Management
- Swipe to complete/delete
- Visual priority indicators
- Due date warnings
- Category tags

## 🎯 Key Features Explained

### State Management
Uses Provider pattern for clean, predictable state management:
- `TaskProvider` - Main state management
- Reactive UI updates
- Efficient state updates

### Data Persistence
Hive database for local storage:
- Fast, lightweight database
- Type-safe data models
- Offline support

### UI/UX Design
Modern Material Design 3:
- Consistent theming
- Smooth animations
- Responsive design
- Accessibility support

## 🧪 Testing

### Run Tests
```bash
flutter test
```

### Test Coverage
- Unit tests for business logic
- Widget tests for UI components
- Provider tests for state management

## 📦 Build

### Debug Build
```bash
flutter build apk --debug
```

### Release Build
```bash
flutter build apk --release
```

## 🔧 Development

### Code Generation
```bash
flutter packages pub run build_runner build
```

### Linting
```bash
flutter analyze
```

### Formatting
```bash
flutter format .
```

## 🚀 Future Enhancements

- [ ] Task sharing
- [ ] Team collaboration
- [ ] Advanced analytics
- [ ] Voice notes
- [ ] Location-based reminders
- [ ] Task templates
- [ ] Recurring tasks

## 📄 License

Created for ETESTICANOW Assessment

---

**TaskMaster** - Your intelligent task management companion! 🎯