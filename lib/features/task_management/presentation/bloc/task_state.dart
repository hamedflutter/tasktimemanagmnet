part of 'task_bloc.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskDeleting extends TaskState {}

class TaskCreating extends TaskState {}

class TaskUpdating extends TaskState {}

class TaskCreated extends TaskState {
  final TaskEntity task;

  const TaskCreated({required this.task});

  @override
  List<Object?> get props => [task];
}

class TaskUpdated extends TaskState {
  final TaskEntity task;

  const TaskUpdated({required this.task});

  @override
  List<Object?> get props => [task];
}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;

  const TaskLoaded({required this.tasks});

  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;

  const TaskError({required this.message});

  @override
  List<Object?> get props => [message];
}
