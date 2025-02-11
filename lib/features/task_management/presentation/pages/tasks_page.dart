import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appflowy_board/appflowy_board.dart';
import '../../../../shared/themes/hex_color.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
import '../widgets/build_card.dart';
import '../widgets/rich_text_item.dart';
import '../widgets/task_timer_service.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({Key? key}) : super(key: key);

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late AppFlowyBoardController boardController;
  late AppFlowyBoardScrollController boardScrollController;

  // Map to keep track of items across groups
  Map<String, List<RichTextItem>> groupItemsMap = {};
  Map<String, TaskTimerService> _timerServices = {};

  @override
  void dispose() {
    // Dispose all timer services when the page is disposed
    _timerServices.forEach((key, service) {
      service.dispose();
    });
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    boardController = AppFlowyBoardController(
      onMoveGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        debugPrint(
            'Move group from $fromGroupId:$fromIndex to $toGroupId:$toIndex');
      },
      onMoveGroupItem: (groupId, fromIndex, toIndex) {
        debugPrint('Move within group $groupId: $fromIndex to $toIndex');
      },
      onMoveGroupItemToGroup: (fromGroupId, fromIndex, toGroupId, toIndex) {
        debugPrint('Move $fromGroupId:$fromIndex to $toGroupId:$toIndex');

        // Check if the source group exists and if the index is within bounds
        if (groupItemsMap.containsKey(fromGroupId) &&
            fromIndex < groupItemsMap[fromGroupId]!.length) {
          final movedTask = groupItemsMap[fromGroupId]![fromIndex];

          // Remove the item from the source group
          groupItemsMap[fromGroupId]!.removeAt(fromIndex);

          // Add the item to the destination group at the specified index
          if (!groupItemsMap.containsKey(toGroupId)) {
            groupItemsMap[toGroupId] = [];
          }
          groupItemsMap[toGroupId]!.insert(toIndex, movedTask);

          // Update the task's projectId to reflect the new group
          TaskEntity updatedTask = movedTask.toTaskEntity().copyWith(
                projectId: _getProjectIdForGroup(toGroupId),
              );

          context.read<TaskBloc>().add(UpdateTaskEvent(task: updatedTask));
        }
      },
    );
    boardScrollController = AppFlowyBoardScrollController();
    context.read<TaskBloc>().add(FetchTasksEvent());
  }

  @override
  Widget build(BuildContext context) {
    final config = AppFlowyBoardConfig(
      groupBackgroundColor: HexColor.fromHex('#F7F8FC'),
      stretchGroupHeight: false,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks Board'),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(
        listener: (context, state) {
          if (state is TaskLoaded) {
            _updateBoard(state.tasks);
          }
        },
        builder: (context, state) {
          if (state is TaskLoading ||
              state is TaskUpdating ||
              state is TaskDeleting) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TaskBloc>().add(FetchTasksEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is TaskLoaded) {
            if (state.tasks.isEmpty) {
              return const Center(child: Text('No tasks available.'));
            }
            return buildBoard(state.tasks, config, boardController,
                boardScrollController, _timerServices, _updateBoard, context);
          }
          return const Center(child: Text('No tasks available.'));
        },
      ),
    );
  }

  void _updateBoard(List<TaskEntity> tasks) {
    // Clear existing groups and reset items map
    boardController.clear();
    groupItemsMap.clear();

    final groupedTasks = _groupTasks(tasks);

    // Add groups and their items
    for (final groupId in groupedTasks.keys) {
      // Convert tasks to RichTextItems or your desired type
      final items = List<AppFlowyGroupItem>.from(
        groupedTasks[groupId]!.map((task) {
          return RichTextItem(
            id: task.id,
            title: task.content ?? 'No title',
            subtitle: task.description ?? 'No description',
            projectId: task.projectId!,
          );
        }).toList(),
      );

      // Explicitly cast the items to List<RichTextItem> if needed
      groupItemsMap[groupId] = items.cast<RichTextItem>();

      // Add group to the board
      boardController.addGroup(
        AppFlowyGroupData(
          id: groupId,
          name: groupId,
          items: items,
        ),
      );
    }
  }

  // Group tasks based on project_id
  Map<String, List<TaskEntity>> _groupTasks(List<TaskEntity> tasks) {
    final Map<String, List<TaskEntity>> groupedTasks = {
      "To Do": [],
      "In Progress": [],
      "Done": [],
    };

    for (final task in tasks) {
      switch (task.projectId) {
        case "2344836189":
          groupedTasks["To Do"]!.add(task);
          break;
        case "2344836280":
          groupedTasks["In Progress"]!.add(task);
          break;
        case "2344836299":
          groupedTasks["Done"]!.add(task);
          break;
        default:
          groupedTasks["To Do"]!.add(task);
          break;
      }
    }

    return groupedTasks;
  }

  String _getProjectIdForGroup(String groupName) {
    switch (groupName) {
      case "To Do":
        return "2344836189";
      case "In Progress":
        return "2344836280";
      case "Done":
        return "2344836299";
      default:
        return "2344836189"; // Default to "To Do"
    }
  }
}
