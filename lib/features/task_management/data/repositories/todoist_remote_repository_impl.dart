import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/todoist_remote_repository.dart';
import '../datasources/todoist_remote_datasource.dart';
import '../models/task_model.dart';

class TodoistRemoteRepositoryImpl implements TodoistRemoteRepository {
  final TodoistRemoteDataSource remoteDataSource;

  TodoistRemoteRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks() async {
    try {
      final tasks = await remoteDataSource.getTasks();
      // Convert List<TaskModel> to List<TaskEntity>
      final taskEntities =
          tasks.map((taskModel) => taskModel.toEntity()).toList();
      return Right(taskEntities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask(TaskEntity task) async {
    try {
      // Convert TaskEntity to TaskModel
      final taskModel = TaskModel.fromEntity(task);
      final createdTask = await remoteDataSource.createTask(taskModel);
      return Right(createdTask.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String taskId) async {
    try {
      await remoteDataSource.deleteTask(taskId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask(TaskEntity task) async {
    try {
      // Convert TaskEntity to TaskModel
      final taskModel = TaskModel.fromEntity(task);
      final updatedTask = await remoteDataSource.updateTask(taskModel);
      return Right(updatedTask.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
