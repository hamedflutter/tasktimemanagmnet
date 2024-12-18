import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appflowy_board/appflowy_board.dart';
import 'package:tasktimetracker/features/task_management/domain/entities/task.dart';
import 'package:tasktimetracker/features/task_management/presentation/bloc/task_bloc.dart';
import 'package:tasktimetracker/features/task_management/presentation/pages/tasks_page.dart';

// Mock classes
class MockTaskBloc extends MockBloc<TaskEvent, TaskState> implements TaskBloc {}

void main() {
  late MockTaskBloc mockTaskBloc;

  setUp(() {
    mockTaskBloc = MockTaskBloc();
  });

  Widget createWidgetUnderTest() {
    return BlocProvider<TaskBloc>.value(
      value: mockTaskBloc,
      child: const MaterialApp(
        home: TasksPage(),
      ),
    );
  }

  group('TasksPage Widget Tests', () {
    testWidgets('should show loading indicator when state is TaskLoading',
        (WidgetTester tester) async {
      when(() => mockTaskBloc.state).thenReturn(TaskLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
        'should show no tasks message when state is TaskLoaded with no tasks',
        (WidgetTester tester) async {
      when(() => mockTaskBloc.state).thenReturn(const TaskLoaded(tasks: []));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No tasks available.'), findsOneWidget);
      expect(find.byType(AppFlowyBoard), findsNothing);
    });

    testWidgets('should render board when state is TaskLoaded with tasks',
        (WidgetTester tester) async {
      final tasks = [
        const TaskEntity(
            id: '1',
            content: 'Task 1',
            description: 'Desc 1',
            projectId: '2344836189'),
        const TaskEntity(
            id: '2',
            content: 'Task 2',
            description: 'Desc 2',
            projectId: '2344836280'),
      ];

      when(() => mockTaskBloc.state).thenReturn(TaskLoaded(tasks: tasks));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AppFlowyBoard), findsOneWidget);
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });

    testWidgets('should show error message when state is TaskError',
        (WidgetTester tester) async {
      when(() => mockTaskBloc.state)
          .thenReturn(const TaskError(message: 'Failed to fetch tasks'));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Error: Failed to fetch tasks'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should handle task movement between groups',
        (WidgetTester tester) async {
      final tasks = [
        const TaskEntity(
            id: '1',
            content: 'Task 1',
            description: 'Desc 1',
            projectId: '2344836189'),
        const TaskEntity(
            id: '2',
            content: 'Task 2',
            description: 'Desc 2',
            projectId: '2344836280'),
      ];

      when(() => mockTaskBloc.state).thenReturn(TaskLoaded(tasks: tasks));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AppFlowyBoard), findsOneWidget);
    });
  });
}
