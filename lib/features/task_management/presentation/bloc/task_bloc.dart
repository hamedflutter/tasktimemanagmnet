import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart'; // Import the Failure classes
import '../../domain/entities/task.dart';
import '../../domain/usecases/create_tasks_usecase.dart';
import '../../domain/usecases/delete_tasks_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_tasks_usecase.dart';
import '../../domain/usecases/task_params.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUseCase getTasksUseCase;
  final DeleteTasksUseCase deleteTaskUseCase;
  final UpdateTasksUseCase updateTaskUseCase;
  final CreateTasksUseCase createTasksUseCase;

  TaskBloc({
    required this.getTasksUseCase,
    required this.deleteTaskUseCase,
    required this.updateTaskUseCase,
    required this.createTasksUseCase,
  }) : super(TaskInitial()) {
    on<FetchTasksEvent>(_onFetchTasks);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<UpdateTaskOrderEvent>(_onUpdateTaskOrder);
  }

  Future<void> _onFetchTasks(
      FetchTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final failureOrTasks = await getTasksUseCase(NoParams());

      failureOrTasks.fold(
        (failure) {
          emit(TaskError(message: _mapFailureToMessage(failure)));
        },
        (tasks) => emit(TaskLoaded(tasks: tasks)),
      );
    } catch (e) {
      emit(TaskError(message: 'Failed to fetch tasks: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTask(
      DeleteTaskEvent event, Emitter<TaskState> emit) async {
    final currentState = state;

    if (currentState is TaskLoaded) {
      emit(TaskDeleting());
      try {
        final taskToDelete =
            currentState.tasks.firstWhere((task) => task.id == event.taskId);

        final failureOrSuccess =
            await deleteTaskUseCase(TaskParams(task: taskToDelete));

        failureOrSuccess.fold(
          (failure) {
            emit(TaskError(message: _mapFailureToMessage(failure)));
          },
          (_) {
            final updatedTasks = currentState.tasks
                .where((task) => task.id != event.taskId)
                .toList();
            emit(TaskLoaded(tasks: updatedTasks));
          },
        );
      } catch (e) {
        emit(TaskError(message: 'Failed to delete task: ${e.toString()}'));
      }
    }
  }

  Future<void> _onCreateTask(
      CreateTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskCreating());
    try {
      final failureOrSuccess =
          await createTasksUseCase(TaskParams(task: event.task));

      failureOrSuccess.fold(
        (failure) {
          emit(TaskError(message: _mapFailureToMessage(failure)));
        },
        (createdTask) {
          if (state is TaskLoaded) {
            final currentTasks = (state as TaskLoaded).tasks;
            emit(TaskLoaded(tasks: [...currentTasks, createdTask]));
          } else {
            emit(TaskCreated(task: createdTask));
          }
        },
      );
    } catch (e) {
      emit(TaskError(message: 'Failed to create task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTask(
      UpdateTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskUpdating());
    try {
      final failureOrSuccess =
          await updateTaskUseCase(TaskParams(task: event.task));

      failureOrSuccess.fold(
        (failure) {
          emit(TaskError(message: _mapFailureToMessage(failure)));
        },
        (updatedTask) {
          if (state is TaskLoaded) {
            final currentTasks = (state as TaskLoaded).tasks.map((task) {
              return task.id == updatedTask.id ? updatedTask : task;
            }).toList();
            emit(TaskLoaded(tasks: currentTasks));
          } else {
            emit(TaskUpdated(task: updatedTask));
          }
        },
      );
    } catch (e) {
      emit(TaskError(message: 'Failed to update task: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTaskOrder(
      UpdateTaskOrderEvent event, Emitter<TaskState> emit) async {
    final currentState = state;
    if (currentState is TaskLoaded) {
      try {
        // Filter tasks for the specific group (project ID)
        final groupTasks = currentState.tasks
            .where((task) =>
                _getProjectIdForGroup(event.groupId) == task.projectId)
            .toList();

        // Remove the task from its original position
        final movedTask = groupTasks.removeAt(event.fromIndex);

        // Insert the task at the new position
        groupTasks.insert(event.toIndex, movedTask);

        // Update the entire tasks list
        final updatedTasks = currentState.tasks.map((task) {
          // Replace tasks in this group with the reordered list
          if (_getProjectIdForGroup(event.groupId) == task.projectId) {
            return groupTasks[groupTasks.indexOf(task)];
          }
          return task;
        }).toList();

        emit(TaskLoaded(tasks: updatedTasks));
      } catch (e) {
        emit(TaskError(message: 'Failed to reorder tasks: ${e.toString()}'));
      }
    }
  }

  // Helper method to get project ID based on group name
  String _getProjectIdForGroup(String groupName) {
    switch (groupName) {
      case "To Do":
        return "2344836189";
      case "In Progress":
        return "2344836280";
      case "Done":
        return "2344836299";
      default:
        return "2344836189"; // Default to "To Do"
    }
  }

  // Helper method to map failure to message
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server failure: ${failure.message}';
    } else if (failure is CacheFailure) {
      return 'Cache failure: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Network failure: ${failure.message}';
    } else if (failure is LocalFailure) {
      return 'Local failure: ${failure.message}';
    } else {
      return 'Unexpected error: ${failure.message}';
    }
  }
}
