import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../data/models/task_model_hive.dart';
import '../entities/task.dart';
import '../repositories/todoist_local_repository.dart';
import '../repositories/todoist_remote_repository.dart';

class GetTasksUseCase implements UseCase<List<TaskEntity>, NoParams> {
  final TodoistLocalRepository localRepository;
  final TodoistRemoteRepository remoteRepository;

  GetTasksUseCase(this.localRepository, this.remoteRepository);

  @override
  Future<Either<Failure, List<TaskEntity>>> call(NoParams params) async {
    // First, try to get tasks from the local storage (Hive)
    final localTasks = await localRepository.getAllTasks();
    
    // If local tasks are available, return them
    if (localTasks.isNotEmpty) {
      return Right(localTasks);
    } else {
      // If no local tasks, fetch tasks from the remote repository
      final failureOrTasks = await remoteRepository.getTasks();

      // If tasks are successfully fetched from remote
      return failureOrTasks.fold(
        (failure) => Left(failure), // Return failure if remote fetch failed
        (tasks) async {
          // If we successfully fetched tasks, sync them to Hive
          await _syncTasksToLocal(tasks);  // Save tasks to local storage (Hive)
          return Right(tasks); // Return tasks after syncing
        },
      );
    }
  }

  // Sync tasks to local storage (Hive)
  Future<void> _syncTasksToLocal(List<TaskEntity> tasks) async {
    for (var task in tasks) {
      final taskModel = TaskModelHive(
        id: task.id,
        content: task.content,
        description: task.description,
        projectId: task.projectId,
        sectionId: task.sectionId,
        parentId: task.parentId,
        order: task.order,
        labels: task.labels,
        priority: task.priority,
        dueString: task.dueString,
        dueDate: task.dueDate,
        dueDatetime: task.dueDatetime,
        dueLang: task.dueLang,
        assigneeId: task.assigneeId,
        isCompleted: task.isCompleted,
        commentCount: task.commentCount,
        createdAt: task.createdAt,
        duration: task.duration,
        url: task.url,
      );
      await localRepository.addTask(taskModel); // Add each task to local storage
    }
  }
}
