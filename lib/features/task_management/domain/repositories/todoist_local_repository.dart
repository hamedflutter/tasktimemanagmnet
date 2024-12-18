import '../../domain/entities/task.dart';

abstract class TodoistLocalRepository {
  Future<void> addTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Future<void> updateTask(TaskEntity task);
  Future<TaskEntity?> getTask(String taskId);
  Future<List<TaskEntity>> getAllTasks();
}
