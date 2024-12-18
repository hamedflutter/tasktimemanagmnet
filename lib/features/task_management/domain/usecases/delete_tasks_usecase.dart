import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/todoist_local_repository.dart';
import '../repositories/todoist_remote_repository.dart';
import 'task_params.dart';

class DeleteTasksUseCase implements UseCase<void, TaskParams> {
  final TodoistLocalRepository localRepository;
  final TodoistRemoteRepository remoteRepository;

  DeleteTasksUseCase(this.localRepository, this.remoteRepository);

  @override
  Future<Either<Failure, void>> call(TaskParams params) async {
    final taskId = params.task.id;

    // First, try to delete the task remotely
    final failureOrVoid = await remoteRepository.deleteTask(taskId);

    return failureOrVoid.fold(
      (failure) => Left(failure), // Return failure if remote deletion failed
      (_) async {
    // Sync the task deletion to local storage (Hive) if deletion is successful
        await localRepository.deleteTask(taskId);
        return Right(null);
      },
    );
  }
}
