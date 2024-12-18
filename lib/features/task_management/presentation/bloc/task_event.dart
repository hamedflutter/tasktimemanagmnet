part of 'task_bloc.dart';

abstract class TaskEvent extends Equatable {
  const TaskEvent();

  @override
  List<Object?> get props => [];
}

class FetchTasksEvent extends TaskEvent {}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  const DeleteTaskEvent({required this.taskId});

  @override
  List<Object?> get props => [taskId];
}

class CreateTaskEvent extends TaskEvent {
  final TaskEntity task;

  const CreateTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;

  const UpdateTaskEvent({required this.task});

  @override
  List<Object?> get props => [task];
}

class UpdateTaskOrderEvent extends TaskEvent {
  final String groupId;
  final int fromIndex;
  final int toIndex;

  const UpdateTaskOrderEvent({
    required this.groupId,
    required this.fromIndex,
    required this.toIndex,
  });

  @override
  List<Object?> get props => [groupId, fromIndex, toIndex];
}
