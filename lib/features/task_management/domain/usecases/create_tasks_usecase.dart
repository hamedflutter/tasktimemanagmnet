import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/todoist_local_repository.dart';
import '../repositories/todoist_remote_repository.dart';
import 'task_params.dart';

class CreateTasksUseCase implements UseCase<TaskEntity, TaskParams> {
  final TodoistLocalRepository localRepository;
  final TodoistRemoteRepository remoteRepository;

  CreateTasksUseCase(this.localRepository, this.remoteRepository);

  @override
  Future<Either<Failure, TaskEntity>> call(TaskParams params) async {
    final task = params.task;

    // First, try to create the task remotely
    final failureOrTask = await remoteRepository.createTask(task);

    return failureOrTask.fold(
      (failure) => Left(failure), // Return failure if remote creation failed
      (createdTask) async {
        // Sync the task to local storage (Hive) if creation is successful
        await localRepository.addTask(createdTask);
        return Right(createdTask);
      },
    );
  }
}
