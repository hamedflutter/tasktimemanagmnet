import 'package:dio/dio.dart';
import '../models/task_model.dart';

abstract class TodoistRemoteDataSource {
  Future<List<TaskModel>> getTasks();
  Future<TaskModel> createTask(TaskModel task);
  Future<void> deleteTask(String taskId);
  Future<TaskModel> updateTask(TaskModel task);
}

class TodoistRemoteDataSourceImpl implements TodoistRemoteDataSource {
  final Dio dio;
  static const String baseUrl = 'https://api.todoist.com/rest/v2';

  TodoistRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TaskModel>> getTasks() async {
    try {
      final response = await dio.get('/tasks');
      return (response.data as List)
          .map((taskJson) => TaskModel.fromJson(taskJson))
          .toList();
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      final response = await dio.post('/tasks', data: task.toJson());
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await dio.delete('/tasks/$taskId');
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final response = await dio.post('/tasks/${task.id}', data: task.toJson());
      return TaskModel.fromJson(response.data);
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException e) {
    if (e.response != null) {
      print('Todoist API Error: ${e.response?.data}');
      print('Status Code: ${e.response?.statusCode}');
    } else {
      print('Network Error: ${e.message}');
    }
  }
}