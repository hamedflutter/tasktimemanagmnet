import 'package:appflowy_board/appflowy_board.dart';
  import '../../domain/entities/task.dart';
  import '../widgets/rich_text_item.dart';

  void updateBoard(
    List<TaskEntity> tasks,
    AppFlowyBoardController boardController,
    Map<String, List<RichTextItem>> groupItemsMap,
    Map<String, List<TaskEntity>> Function(List<TaskEntity>) groupTasks,
  ) {
    // Clear existing groups and reset items map
    boardController.clear();
    groupItemsMap.clear();

    final groupedTasks = groupTasks(tasks);

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