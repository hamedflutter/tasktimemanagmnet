import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../widgets/rich_text_item.dart';

void showTaskOptions(BuildContext context, RichTextItem item, TaskEntity taskEntity) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/taskForm',
                  arguments: taskEntity,
                );
              },
            ),
            BlocConsumer<TaskBloc, TaskState>(
              builder: (BuildContext context, state) {
                return ListTile(
                  leading: state is TaskLoaded
                      ? const Icon(Icons.delete)
                      : const CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                  title: const Text('Delete Task'),
                  onTap: () {
                    context.read<TaskBloc>().add(DeleteTaskEvent(taskId: item.id));
                  },
                );
              },
              listener: (BuildContext context, state) {
                if (state is TaskLoaded) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}