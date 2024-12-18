import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tasktimetracker/core/error/failures.dart';
import 'package:tasktimetracker/core/usecases/usecase.dart';
import 'package:tasktimetracker/features/task_management/domain/entities/task.dart';
import 'package:tasktimetracker/features/task_management/domain/usecases/create_tasks_usecase.dart';
import 'package:tasktimetracker/features/task_management/domain/usecases/delete_tasks_usecase.dart';
import 'package:tasktimetracker/features/task_management/domain/usecases/get_tasks_usecase.dart';
import 'package:tasktimetracker/features/task_management/domain/usecases/task_params.dart';
import 'package:tasktimetracker/features/task_management/domain/usecases/update_tasks_usecase.dart';

import 'get_tasks_usecase_test.mocks.dart';

void main() {
  late MockTodoistLocalRepository mockLocalRepository;
  late MockTodoistRemoteRepository mockRemoteRepository;

  setUp(() {
    mockLocalRepository = MockTodoistLocalRepository();
    mockRemoteRepository = MockTodoistRemoteRepository();
  });

  group('GetTasksUseCase', () {
    test('should return tasks from local storage if available', () async {
      // Arrange
      final tasks = [TaskEntity(id: '1', content: 'Task 1')];
      when(mockLocalRepository.getAllTasks()).thenAnswer((_) async => tasks);

      final useCase =
          GetTasksUseCase(mockLocalRepository, mockRemoteRepository);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, Right(tasks));
      verify(mockLocalRepository.getAllTasks());
      verifyNoMoreInteractions(mockRemoteRepository);
    });

    test(
  'should fetch tasks from remote and sync to local if local storage is empty',
        () async {
      // Arrange
      final tasks = [TaskEntity(id: '2', content: 'Task 2')];
      when(mockLocalRepository.getAllTasks()).thenAnswer((_) async => []);
      when(mockRemoteRepository.getTasks())
          .thenAnswer((_) async => Right(tasks));

      final useCase =
          GetTasksUseCase(mockLocalRepository, mockRemoteRepository);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, Right(tasks));
      verify(mockLocalRepository.getAllTasks());
      verify(mockRemoteRepository.getTasks());
      verify(mockLocalRepository.addTask(any)).called(tasks.length);
    });

    test('should return failure if remote fetch fails', () async {
      // Arrange
      final failure = ServerFailure(message: "");
      when(mockLocalRepository.getAllTasks()).thenAnswer((_) async => []);
      when(mockRemoteRepository.getTasks())
          .thenAnswer((_) async => Left(failure));

      final useCase =
          GetTasksUseCase(mockLocalRepository, mockRemoteRepository);

      // Act
      final result = await useCase(NoParams());

      // Assert
      expect(result, Left(failure));
      verify(mockLocalRepository.getAllTasks());
      verify(mockRemoteRepository.getTasks());
    });
  });

  group('CreateTasksUseCase', () {
    test('should create a task remotely and sync to local storage', () async {
      // Arrange
      final task = TaskEntity(id: '3', content: 'Task 3');
      when(mockRemoteRepository.createTask(task))
          .thenAnswer((_) async => Right(task));

      final useCase =
          CreateTasksUseCase(mockLocalRepository, mockRemoteRepository);

      // Act
      final result = await useCase(TaskParams(task: task));

      // Assert
      expect(result, Right(task));
      verify(mockRemoteRepository.createTask(task));
      verify(mockLocalRepository.addTask(task));
    });

    test('should return failure if remote task creation fails', () async {
      // Arrange
      final task = TaskEntity(id: '4', content: 'Task 4');
      final failure = ServerFailure(message: '');
      when(mockRemoteRepository.createTask(task))
          .thenAnswer((_) async => Left(failure));

      final useCase =
          CreateTasksUseCase(mockLocalRepository, mockRemoteRepository);

      // Act
      final result = await useCase(TaskParams(task: task));

      // Assert
      expect(result, Left(failure));
      verify(mockRemoteRepository.createTask(task));
      verifyZeroInteractions(mockLocalRepository);
    });
  });

  group('DeleteTasksUseCase', () {
    test('should delete a task remotely and sync local storage', () async {
      // Arrange
      final task = TaskEntity(id: '5', content: 'Task 5');
      when(mockRemoteRepository.deleteTask(task.id))
          .thenAnswer((_) async => Right(null));

      final useCase =
          DeleteTasksUseCase(mockLocalRepository, mockRemoteRepository);

      // Act
      final result = await useCase(TaskParams(task: task));

      // Assert
      expect(result, Right(null));
      verify(mockRemoteRepository.deleteTask(task.id));
      verify(mockLocalRepository.deleteTask(task.id));
    });

    test('should return failure if remote deletion fails', () async {
      // Arrange
      final task = TaskEntity(id: '6', content: 'Task 6');
      final failure = ServerFailure(message: '');
      when(mockRemoteRepository.deleteTask(task.id))
          .thenAnswer((_) async => Left(failure));

      final useCase =
          DeleteTasksUseCase(mockLocalRepository, mockRemoteRepository);

      // Act
      final result = await useCase(TaskParams(task: task));

      // Assert
      expect(result, Left(failure));
      verify(mockRemoteRepository.deleteTask(task.id));
      verifyZeroInteractions(mockLocalRepository);
    });
  });

  group('UpdateTasksUseCase', () {
    test('should update a task in local storage', () async {
      // Arrange
      final task = TaskEntity(id: '7', content: 'Updated Task 7');
      when(mockLocalRepository.updateTask(task)).thenAnswer((_) async => null);

      final useCase = UpdateTasksUseCase(mockLocalRepository);

      // Act
      final result = await useCase(TaskParams(task: task));

      // Assert
      expect(result, Right(task));
      verify(mockLocalRepository.updateTask(task));
    });

    test('should return failure if local update fails', () async {
      // Arrange
      final task = TaskEntity(id: '8', content: 'Task 8');
      when(mockLocalRepository.updateTask(task))
          .thenThrow(Exception('Hive Error'));

      final useCase = UpdateTasksUseCase(mockLocalRepository);

      // Act
      final result = await useCase(TaskParams(task: task));

      // Assert
      expect(result, Left(LocalFailure(message: 'Exception: Hive Error')));
      verify(mockLocalRepository.updateTask(task));
    });
  });
}
