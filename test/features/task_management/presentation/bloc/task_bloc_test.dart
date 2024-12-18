import 'package:bloc_test/bloc_test.dart';
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
import 'package:tasktimetracker/features/task_management/presentation/bloc/task_bloc.dart';

class MockGetTasksUseCase extends Mock implements GetTasksUseCase {}

class MockDeleteTasksUseCase extends Mock implements DeleteTasksUseCase {}

class MockUpdateTasksUseCase extends Mock implements UpdateTasksUseCase {}

class MockCreateTasksUseCase extends Mock implements CreateTasksUseCase {}

void main() {
  late MockGetTasksUseCase mockGetTasksUseCase;
  late MockDeleteTasksUseCase mockDeleteTasksUseCase;
  late MockUpdateTasksUseCase mockUpdateTasksUseCase;
  late MockCreateTasksUseCase mockCreateTasksUseCase;
  late TaskBloc taskBloc;

  setUp(() {
    mockGetTasksUseCase = MockGetTasksUseCase();
    mockDeleteTasksUseCase = MockDeleteTasksUseCase();
    mockUpdateTasksUseCase = MockUpdateTasksUseCase();
    mockCreateTasksUseCase = MockCreateTasksUseCase();
    taskBloc = TaskBloc(
      getTasksUseCase: mockGetTasksUseCase,
      deleteTaskUseCase: mockDeleteTasksUseCase,
      updateTaskUseCase: mockUpdateTasksUseCase,
      createTasksUseCase: mockCreateTasksUseCase,
    );
  });

  group('TaskBloc', () {
    test('initial state should be TaskInitial', () {
      expect(taskBloc.state, equals(TaskInitial()));
    });

    blocTest<TaskBloc, TaskState>(
      'FetchTasksEvent emits [TaskLoading, TaskLoaded] when fetching tasks is successful',
      build: () {
        when(mockGetTasksUseCase(NoParams()))
            .thenAnswer((_) async => const Right([
                  TaskEntity(
                    id: '1',
                    content: 'Test Task',
                    description: null,
                    projectId: null,
                    sectionId: null,
                    parentId: null,
                    order: null,
                    labels: null,
                    priority: null,
                    dueString: null,
                    dueDate: null,
                    dueDatetime: null,
                    dueLang: null,
                    assigneeId: null,
                    isCompleted: null,
                    commentCount: null,
                    createdAt: null,
                    duration: null,
                    url: null,
                  )
                ]));
        return taskBloc;
      },
      act: (bloc) => bloc.add(FetchTasksEvent()),
      expect: () => [
        TaskLoading(),
        const TaskLoaded(tasks: [
          TaskEntity(
            id: '1',
            content: 'Test Task',
            description: null,
            projectId: null,
            sectionId: null,
            parentId: null,
            order: null,
            labels: null,
            priority: null,
            dueString: null,
            dueDate: null,
            dueDatetime: null,
            dueLang: null,
            assigneeId: null,
            isCompleted: null,
            commentCount: null,
            createdAt: null,
            duration: null,
            url: null,
          )
        ]),
      ],
      verify: (_) {
        verify(mockGetTasksUseCase(NoParams())).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'FetchTasksEvent emits [TaskLoading, TaskError] when fetching tasks fails',
      build: () {
        when(mockGetTasksUseCase(NoParams())).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Server Error')));
        return taskBloc;
      },
      act: (bloc) => bloc.add(FetchTasksEvent()),
      expect: () => [
        TaskLoading(),
        const TaskError(message: 'Failed to fetch tasks: Server Error'),
      ],
      verify: (_) {
        verify(mockGetTasksUseCase(NoParams())).called(1);
      },
    );

    blocTest<TaskBloc, TaskState>(
      'CreateTaskEvent emits [TaskCreating, TaskCreated] when creating a task is successful',
      build: () {
        when(mockCreateTasksUseCase(const TaskParams(
            task: TaskEntity(
          id: '1', // Example TaskEntity data
          content: 'Test Task',
          description: null,
          projectId: null,
          sectionId: null,
          parentId: null,
          order: null,
          labels: null,
          priority: null,
          dueString: null,
          dueDate: null,
          dueDatetime: null,
          dueLang: null,
          assigneeId: null,
          isCompleted: null,
          commentCount: null,
          createdAt: null,
          duration: null,
          url: null,
        )))).thenAnswer((_) async => const Right(TaskEntity(
              id: '1',
              content: 'Test Task',
              description: null,
              projectId: null,
              sectionId: null,
              parentId: null,
              order: null,
              labels: null,
              priority: null,
              dueString: null,
              dueDate: null,
              dueDatetime: null,
              dueLang: null,
              assigneeId: null,
              isCompleted: null,
              commentCount: null,
              createdAt: null,
              duration: null,
              url: null,
            )));

        return taskBloc;
      },
      act: (bloc) => bloc.add(
        CreateTaskEvent(
          task: TaskEntity(
            id: '1', // Example ID
            content: 'Test Task',
            description: null,
            projectId: null,
            sectionId: null,
            parentId: null,
            order: null,
            labels: null,
            priority: null,
            dueString: null,
            dueDate: null,
            dueDatetime: null,
            dueLang: null,
            assigneeId: null,
            isCompleted: null,
            commentCount: null,
            createdAt: null,
            duration: null,
            url: null,
          ),
        ),
      ),
      expect: () => [
        TaskCreating(),
        TaskCreated(
          task: TaskEntity(
            id: '1', // Example ID
            content: 'Test Task',
            description: null,
            projectId: null,
            sectionId: null,
            parentId: null,
            order: null,
            labels: null,
            priority: null,
            dueString: null,
            dueDate: null,
            dueDatetime: null,
            dueLang: null,
            assigneeId: null,
            isCompleted: null,
            commentCount: null,
            createdAt: null,
            duration: null,
            url: null,
          ),
        ),
      ],
    );

    // blocTest<TaskBloc, TaskState>(
    //   'UpdateTaskEvent emits [TaskUpdating, TaskUpdated] when updating a task is successful',
    //   build: () {
    //     when(mockUpdateTasksUseCase(anyThat(isA<TaskParams>()))).thenAnswer(
    //       (_) async => const Right(
    //         TaskEntity(
    //           id: '1', // ID type match
    //           content: 'Updated Task',
    //           description: null,
    //           projectId: null,
    //           sectionId: null,
    //           parentId: null,
    //           order: null,
    //           labels: null,
    //           priority: null,
    //           dueString: null,
    //           dueDate: null,
    //           dueDatetime: null,
    //           dueLang: null,
    //           assigneeId: null,
    //           isCompleted: null,
    //           commentCount: null,
    //           createdAt: null,
    //           duration: null,
    //           url: null,
    //         ),
    //       ),
    //     );
    //     return taskBloc;
    //   },
    //   act: (bloc) => bloc.add(UpdateTaskEvent(
    //     task: TaskEntity(
    //       id: '1',
    //       content: 'Updated Task',
    //       description: null,
    //       projectId: null,
    //       sectionId: null,
    //       parentId: null,
    //       order: null,
    //       labels: null,
    //       priority: null,
    //       dueString: null,
    //       dueDate: null,
    //       dueDatetime: null,
    //       dueLang: null,
    //       assigneeId: null,
    //       isCompleted: null,
    //       commentCount: null,
    //       createdAt: null,
    //       duration: null,
    //       url: null,
    //     ),
    //   )),
    //   expect: () => [
    //     TaskUpdating(),
    //     TaskUpdated(
    //       task: TaskEntity(
    //         id: '1',
    //         content: 'Updated Task',
    //         description: null,
    //         projectId: null,
    //         sectionId: null,
    //         parentId: null,
    //         order: null,
    //         labels: null,
    //         priority: null,
    //         dueString: null,
    //         dueDate: null,
    //         dueDatetime: null,
    //         dueLang: null,
    //         assigneeId: null,
    //         isCompleted: null,
    //         commentCount: null,
    //         createdAt: null,
    //         duration: null,
    //         url: null,
    //       ),
    //     ),
    //   ],
    // );
  });
}
