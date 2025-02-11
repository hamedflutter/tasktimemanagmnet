import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
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
        (failure) => emit(TaskError(message: _mapFailureToMessage(failure))),
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
          (failure) => emit(TaskError(message: _mapFailureToMessage(failure))),
          (_) => emit(TaskLoaded(
              tasks: _removeTaskFromList(currentState.tasks, event.taskId))),
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
        (failure) => emit(TaskError(message: _mapFailureToMessage(failure))),
        (createdTask) => emit(_getUpdatedTaskStateWithNewTask(createdTask)),
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
        (failure) => emit(TaskError(message: _mapFailureToMessage(failure))),
        (updatedTask) => emit(_getUpdatedTaskStateWithUpdatedTask(updatedTask)),
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
        final updatedTasks = _reorderTasks(currentState.tasks, event);
        emit(TaskLoaded(tasks: updatedTasks));
      } catch (e) {
        emit(TaskError(message: 'Failed to reorder tasks: ${e.toString()}'));
      }
    }
  }

  List<TaskEntity> _removeTaskFromList(List<TaskEntity> tasks, String taskId) {
    return tasks.where((task) => task.id != taskId).toList();
  }

  TaskState _getUpdatedTaskStateWithNewTask(TaskEntity createdTask) {
    if (state is TaskLoaded) {
      final currentTasks = (state as TaskLoaded).tasks;
      return TaskLoaded(tasks: [...currentTasks, createdTask]);
    } else {
      return TaskCreated(task: createdTask);
    }
  }

  TaskState _getUpdatedTaskStateWithUpdatedTask(TaskEntity updatedTask) {
    if (state is TaskLoaded) {
      final currentTasks = (state as TaskLoaded).tasks.map((task) {
        return task.id == updatedTask.id ? updatedTask : task;
      }).toList();
      return TaskLoaded(tasks: currentTasks);
    } else {
      return TaskUpdated(task: updatedTask);
    }
  }

  List<TaskEntity> _reorderTasks(
      List<TaskEntity> tasks, UpdateTaskOrderEvent event) {
    final groupTasks = tasks
        .where((task) => _getProjectIdForGroup(event.groupId) == task.projectId)
        .toList();

    final movedTask = groupTasks.removeAt(event.fromIndex);
    groupTasks.insert(event.toIndex, movedTask);

    return tasks.map((task) {
      if (_getProjectIdForGroup(event.groupId) == task.projectId) {
        return groupTasks[groupTasks.indexOf(task)];
      }
      return task;
    }).toList();
  }

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
