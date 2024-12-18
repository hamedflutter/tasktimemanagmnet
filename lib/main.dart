import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tasktimetracker/core/di/injection_container.dart' as di;
import 'package:tasktimetracker/features/task_management/presentation/bloc/task_bloc.dart';

import 'features/task_management/data/models/task_model_hive.dart';
import 'features/task_management/presentation/pages/create_task_page.dart';
import 'features/task_management/presentation/pages/tasks_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(TaskModelHiveAdapter());

  // Open the Hive box before initializing DI
  await Hive.openBox<TaskModelHive>('tasks');

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => di.sl<TaskBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const TasksPage(),
          '/taskForm': (context) => const TaskFormPage(),
        },
      ),
    );
  }
}
