// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:taskmaster/main.dart';
import 'package:taskmaster/providers/simple_task_provider.dart';
import 'package:taskmaster/providers/theme_provider.dart';
import 'package:taskmaster/services/task_repository.dart';
import 'package:taskmaster/models/task.dart';

void main() {
  testWidgets('TaskMaster app smoke test', (WidgetTester tester) async {
    // Build a minimal app tree to avoid heavy layouts and persistence in tests
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => SimpleTaskProvider(repository: _EmptyRepo())..initialize()),
        ],
        child: MaterialApp(
          home: const Scaffold(body: Text('TaskMaster')),
        ),
      ),
    );

    expect(find.text('TaskMaster'), findsOneWidget);
  });
}

class _EmptyRepo implements TaskRepository {
  @override
  Future<void> deleteTask(String taskId) async {}

  @override
  List<Task> getAllTasks() => <Task>[];

  @override
  Future<void> saveTask(Task task) async {}
}
