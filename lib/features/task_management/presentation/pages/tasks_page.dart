import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:appflowy_board/appflowy_board.dart';
import '../../../../shared/themes/hex_color.dart';
import '../../domain/entities/task.dart';
import '../bloc/task_bloc.dart';
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

          // Optionally update the task status or other properties
          TaskEntity taskEntity = movedTask.toTaskEntity();

          context.read<TaskBloc>().add(UpdateTaskEvent(task: taskEntity));
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
      body: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
        print("State: ${state.toString()}");
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
          return _buildBoard(state.tasks, config);
        }
        return const Center(child: Text('No tasks available.'));
      }),
    );
  }

  Widget _buildBoard(List<TaskEntity> tasks, AppFlowyBoardConfig config) {
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

    return AppFlowyBoard(
      controller: boardController,
      boardScrollController: boardScrollController,
      cardBuilder: (context, group, groupItem) {
        // Ensure the groupItem is of the correct type (RichTextItem)
        return AppFlowyGroupCard(
          key: ValueKey(groupItem.id),
          child: _buildCard(groupItem as RichTextItem),
        );
      },
      headerBuilder: (context, columnData) {
        return AppFlowyGroupHeader(
          icon: const Icon(Icons.task),
          title: SizedBox(
            width: 80,
            child: TextField(
              controller: TextEditingController()
                ..text = columnData.headerData.groupName,
              onSubmitted: (val) {
                // Optional: Implement group renaming logic if needed
                debugPrint('Group renamed to: $val');
              },
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          addIcon: const Icon(Icons.add, size: 20),
          onAddButtonClick: () {
            final taskEntity = TaskEntity(
              id: "",
              content: "",
              description: "",
              projectId: columnData.headerData.groupName,
            );
            Navigator.pushNamed(
              context,
              '/taskForm',
              arguments: taskEntity,
            );
          },
          height: 50,
          margin: config.groupBodyPadding,
        );
      },
      footerBuilder: (context, columnData) {
        return AppFlowyGroupFooter(
          icon: const Icon(Icons.add),
          title: const Text('Add Task'),
          height: 50,
          margin: config.groupBodyPadding,
          onAddButtonClick: () {
            final taskEntity = TaskEntity(
              id: "",
              content: "",
              description: "",
              projectId: columnData.headerData.groupName,
            );
            Navigator.pushNamed(
              context,
              '/taskForm',
              arguments: taskEntity,
            );
            debugPrint('Add task to ${columnData.headerData.groupName}');
          },
        );
      },
      config: config,
      groupConstraints: const BoxConstraints.tightFor(width: 280),
    );
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

  Widget _buildCard(RichTextItem item) {
    // Create or get existing timer service for this task
    if (!_timerServices.containsKey(item.id)) {
      _timerServices[item.id] = TaskTimerService(item.id);
    }
    final timerService = _timerServices[item.id]!;
    // Convert RichTextItem back to TaskEntity if necessary
    final taskEntity = TaskEntity(
      id: item.id,
      content: item.title,
      description: item.subtitle,
      projectId: item.projectId,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
          Text(
            item.subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          StreamBuilder<Duration>(
            stream: timerService.timerStream,
            initialData:
                timerService.getElapsedTime(), // Use the loaded elapsed time
            builder: (context, snapshot) {
              final elapsedDuration =
                  snapshot.data ?? Duration.zero; // Fallback for safety
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      timerService.formatDuration(elapsedDuration),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          timerService.isRunning
                              ? Icons.pause
                              : Icons.play_arrow,
                          size: 20,
                          color: timerService.isRunning
                              ? Colors.red
                              : Colors.green,
                        ),
                        onPressed: () {
                          setState(() {
                            if (timerService.isRunning) {
                              timerService.stop();
                            } else {
                              timerService.start();
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.restart_alt, size: 20),
                        onPressed: () {
                          setState(() {
                            timerService.reset();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.more_vert, size: 16),
                onPressed: () {
                  _showTaskOptions(item, taskEntity);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTaskOptions(RichTextItem item, TaskEntity taskEntity) {
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
                      context
                          .read<TaskBloc>()
                          .add(DeleteTaskEvent(taskId: item.id));
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
}
