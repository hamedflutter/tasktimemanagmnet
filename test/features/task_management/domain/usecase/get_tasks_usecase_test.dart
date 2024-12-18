import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:tasktimetracker/core/error/failures.dart';
import 'package:tasktimetracker/core/usecases/usecase.dart';
import 'package:tasktimetracker/features/task_management/domain/entities/task.dart';
import 'package:tasktimetracker/features/task_management/domain/repositories/todoist_local_repository.dart';
import 'package:tasktimetracker/features/task_management/domain/repositories/todoist_remote_repository.dart';
import 'package:tasktimetracker/features/task_management/domain/usecases/get_tasks_usecase.dart';


// Generate mock classes
@GenerateMocks([TodoistLocalRepository, TodoistRemoteRepository])
import 'get_tasks_usecase_test.mocks.dart';

void main() {
  late MockTodoistLocalRepository mockLocalRepository;
  late MockTodoistRemoteRepository mockRemoteRepository;
  late GetTasksUseCase useCase;

  setUp(() {
    mockLocalRepository = MockTodoistLocalRepository();
    mockRemoteRepository = MockTodoistRemoteRepository();
    useCase = GetTasksUseCase(mockLocalRepository, mockRemoteRepository);
  });

  test('should return tasks from the local repository when they are available', () async {
    // Arrange
    final mockTasks = [
      TaskEntity(
        id: '1',
        content: 'Test Task',
        description: 'Test Description',
        projectId: '123',
        sectionId: '456',
        parentId: null,
        order: 1,
        labels: [],
        priority: 1,
        dueString: null,
        dueDate: null,
        dueDatetime: null,
        dueLang: null,
        assigneeId: null,
        isCompleted: false,
        commentCount: 0,
        createdAt: DateTime.now(),
        duration: null,
        url: 'http://example.com',
      ),
    ];
    when(mockLocalRepository.getAllTasks()).thenAnswer((_) async => mockTasks);

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, Right(mockTasks));
    verify(mockLocalRepository.getAllTasks()).called(1);
    verifyNever(mockRemoteRepository.getTasks());
  });

  test('should fetch tasks from remote repository when no local tasks are available', () async {
    // Arrange
    final mockTasks = [
      TaskEntity(
        id: '1',
        content: 'Remote Task',
        description: 'Test Description',
        projectId: '123',
        sectionId: '456',
        parentId: null,
        order: 1,
        labels: [],
        priority: 1,
        dueString: null,
        dueDate: null,
        dueDatetime: null,
        dueLang: null,
        assigneeId: null,
        isCompleted: false,
        commentCount: 0,
        createdAt: DateTime.now(),
        duration: null,
        url: 'http://example.com',
      ),
    ];
    when(mockLocalRepository.getAllTasks()).thenAnswer((_) async => []);
    when(mockRemoteRepository.getTasks()).thenAnswer((_) async => Right(mockTasks));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, Right(mockTasks));
    verify(mockLocalRepository.getAllTasks()).called(1);
    verify(mockRemoteRepository.getTasks()).called(1);
  });

  test('should return failure when remote fetch fails', () async {
    // Arrange
    when(mockLocalRepository.getAllTasks()).thenAnswer((_) async => []);
    when(mockRemoteRepository.getTasks()).thenAnswer((_) async => const Left(ServerFailure(message: "Error")));

    // Act
    final result = await useCase(NoParams());

    // Assert
    expect(result, const Left(ServerFailure(message: 'Error')));
    verify(mockLocalRepository.getAllTasks()).called(1);
    verify(mockRemoteRepository.getTasks()).called(1);
  });
}
