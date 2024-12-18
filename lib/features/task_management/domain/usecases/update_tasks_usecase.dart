import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/task.dart';
import '../repositories/todoist_local_repository.dart';
import 'task_params.dart';

class UpdateTasksUseCase implements UseCase<TaskEntity, TaskParams> {
  final TodoistLocalRepository localRepository;

  UpdateTasksUseCase(this.localRepository);

  @override
  Future<Either<Failure, TaskEntity>> call(TaskParams params) async {
    final task = params.task;

    try {
      // Update the task in the local Hive database
      await localRepository.updateTask(task);

      // Return the updated task wrapped in a Right (success) result
      return Right(task);
    } catch (e) {
      // If an error occurs, wrap it in a Failure and return Left (failure) result
      return Left(LocalFailure(message: e.toString()));
    }
  }
}
