import 'package:hive/hive.dart';
import '../models/task_model_hive.dart';

abstract class TodoistLocalDataSource {
  Future<void> addTask(TaskModelHive task);
  Future<void> deleteTask(String taskId);
  Future<void> updateTask(TaskModelHive task);
  Future<TaskModelHive?> getTask(String taskId);
  Future<List<TaskModelHive>> getAllTasks();
}

class TodoistLocalDataSourceImpl implements TodoistLocalDataSource {
  final Box<TaskModelHive> taskBox;

  TodoistLocalDataSourceImpl(this.taskBox);

  @override
  Future<void> addTask(TaskModelHive task) async {
    await taskBox.put(task.id, task);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await taskBox.delete(taskId);
  }

  @override
  Future<void> updateTask(TaskModelHive task) async {
    await taskBox.put(task.id, task);
  }

  @override
  Future<TaskModelHive?> getTask(String taskId) async {
    return taskBox.get(taskId);
  }

  @override
  Future<List<TaskModelHive>> getAllTasks() async {
    return taskBox.values.toList();
  }
}
