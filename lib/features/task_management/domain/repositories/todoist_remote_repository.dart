import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task.dart';

abstract class TodoistRemoteRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks();
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task);
  Future<Either<Failure, void>> deleteTask(String taskId);
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task);
}