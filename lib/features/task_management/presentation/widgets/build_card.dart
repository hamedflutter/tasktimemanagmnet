import 'package:flutter/material.dart';
  import 'package:appflowy_board/appflowy_board.dart';
  import '../../domain/entities/task.dart';
  import '../widgets/task_card.dart';
  import '../widgets/rich_text_item.dart';
  import '../widgets/task_timer_service.dart';

  Widget buildBoard(
    List<TaskEntity> tasks,
    AppFlowyBoardConfig config,
    AppFlowyBoardController boardController,
    AppFlowyBoardScrollController boardScrollController,
    Map<String, TaskTimerService> timerServices,
    void Function(List<TaskEntity>) updateBoard,
    BuildContext context,
  ) {
    updateBoard(tasks);

    return AppFlowyBoard(
      controller: boardController,
      boardScrollController: boardScrollController,
      cardBuilder: (context, group, groupItem) {
        // Ensure the groupItem is of the correct type (RichTextItem)
        return AppFlowyGroupCard(
          key: ValueKey(groupItem.id),
          child: TaskCard(
            item: groupItem as RichTextItem,
            timerServices: timerServices,
          ),
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
