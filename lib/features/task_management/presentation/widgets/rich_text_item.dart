import 'package:appflowy_board/appflowy_board.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/task.dart';

class RichTextItem extends AppFlowyGroupItem {
  final String id;
  final String title;
  final String subtitle;
  final String projectId;

  RichTextItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.projectId,
  });

  @override
  String get itemId => id;

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  // Convert to TaskEntity
  TaskEntity toTaskEntity() {
    return TaskEntity(
      id: id,
      content: title,
      description: subtitle,
      projectId: projectId,
    );
  }

  // Factory for creating RichTextItem from TaskEntity
  static RichTextItem fromTaskEntity(TaskEntity task) {
    return RichTextItem(
      id: task.id,
      title: task.content ?? 'No title',
      subtitle: task.description ?? 'No description',
      projectId: task.projectId ?? '',
    );
  }
}
