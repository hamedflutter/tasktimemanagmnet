import 'package:equatable/equatable.dart';
import '../entities/task.dart';

class TaskParams extends Equatable {
  final TaskEntity task;

  const TaskParams({required this.task});

  @override
  List<Object?> get props => [task];
}
