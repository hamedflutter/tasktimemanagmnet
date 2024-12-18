

import '../../domain/entities/task.dart';
import '../../domain/repositories/todoist_local_repository.dart';
import '../datasources/todoist_local_datasource.dart';
import '../models/task_model_hive.dart';

class TodoistLocalRepositoryImpl implements TodoistLocalRepository {
  final TodoistLocalDataSource dataSource;

  TodoistLocalRepositoryImpl({required this.dataSource});

  @override
  Future<void> addTask(TaskEntity task) async {
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
    await dataSource.addTask(taskModel);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await dataSource.deleteTask(taskId);
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
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
    await dataSource.updateTask(taskModel);
  }

  @override
  Future<TaskEntity?> getTask(String taskId) async {
    return await dataSource.getTask(taskId);
  }

  @override
  Future<List<TaskEntity>> getAllTasks() async {
    final tasks = await dataSource.getAllTasks();
    return tasks.map((task) => TaskEntity(
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
    )).toList();
  }
}
