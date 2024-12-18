import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/task_management/data/datasources/todoist_local_datasource.dart';
import '../../features/task_management/data/datasources/todoist_remote_datasource.dart';
import '../../features/task_management/data/models/task_model_hive.dart';
import '../../features/task_management/data/repositories/todoist_local_repository_impl.dart';
import '../../features/task_management/data/repositories/todoist_remote_repository_impl.dart';
import '../../features/task_management/domain/repositories/todoist_local_repository.dart';
import '../../features/task_management/domain/repositories/todoist_remote_repository.dart';
import '../../features/task_management/domain/usecases/create_tasks_usecase.dart';
import '../../features/task_management/domain/usecases/delete_tasks_usecase.dart';
import '../../features/task_management/domain/usecases/get_tasks_usecase.dart';
import '../../features/task_management/domain/usecases/update_tasks_usecase.dart';
import '../../features/task_management/presentation/bloc/task_bloc.dart';
import '../services/network_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register Core Services
  _registerCoreServices();

  // Register Data Sources
  _registerDataSources();

  // Register Repositories
  _registerRepositories();

  // Register Use Cases
  _registerUseCases();

  // Register Blocs
  _registerBlocs();
}

void _registerCoreServices() {
  // Network Service
  sl.registerLazySingleton(() => NetworkService());

  // Dio instance from Network Service
  sl.registerLazySingleton<Dio>(() => sl<NetworkService>().dio);
}

void _registerDataSources() {
  // Remote Data Source
  sl.registerLazySingleton<TodoistRemoteDataSource>(
    () => TodoistRemoteDataSourceImpl(dio: sl()),
  );

  // Hive Data Source
  final taskBox =
      Hive.box<TaskModelHive>('tasks'); // Ensure the box is open before using
  sl.registerLazySingleton<TodoistLocalDataSource>(
    () => TodoistLocalDataSourceImpl(taskBox),
  );
}

void _registerRepositories() {
  // Todoist Repositories
  sl.registerLazySingleton<TodoistLocalRepository>(
    () => TodoistLocalRepositoryImpl(dataSource: sl()),
  );

  sl.registerLazySingleton<TodoistRemoteRepository>(
    () => TodoistRemoteRepositoryImpl(remoteDataSource: sl()),
  );
}

void _registerUseCases() {
  // Use Case Registrations with both repositories injected
  sl.registerLazySingleton(() => GetTasksUseCase(
      sl<TodoistLocalRepository>(), sl<TodoistRemoteRepository>()));
  sl.registerLazySingleton(() => CreateTasksUseCase(
      sl<TodoistLocalRepository>(), sl<TodoistRemoteRepository>()));
  sl.registerLazySingleton(() => DeleteTasksUseCase(
      sl<TodoistLocalRepository>(), sl<TodoistRemoteRepository>()));
  sl.registerLazySingleton(
      () => UpdateTasksUseCase(sl<TodoistLocalRepository>()));
}

void _registerBlocs() {
  // Task Bloc Registration with use cases injected
  sl.registerFactory(() => TaskBloc(
        getTasksUseCase: sl(),
        deleteTaskUseCase: sl(),
        updateTaskUseCase: sl(),
        createTasksUseCase: sl(),
      ));
}
