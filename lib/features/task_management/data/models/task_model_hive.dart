import 'package:hive/hive.dart';
import '../../domain/entities/task.dart';

part 'task_model_hive.g.dart';

@HiveType(typeId: 0)
class TaskModelHive extends TaskEntity {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? content;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final String? projectId;
  @HiveField(4)
  final String? sectionId;
  @HiveField(5)
  final String? parentId;
  @HiveField(6)
  final int? order;
  @HiveField(7)
  final List<String>? labels;
  @HiveField(8)
  final int? priority;
  @HiveField(9)
  final String? dueString;
  @HiveField(10)
  final String? dueDate;
  @HiveField(11)
  final String? dueDatetime;
  @HiveField(12)
  final String? dueLang;
  @HiveField(13)
  final String? assigneeId;
  @HiveField(14)
  final bool? isCompleted;
  @HiveField(15)
  final int? commentCount;
  @HiveField(16)
  final DateTime? createdAt;
  @HiveField(17)
  final String? duration;
  @HiveField(18)
  final String? url;

  const TaskModelHive({
    required this.id,
    this.content,
    this.description,
    this.projectId,
    this.sectionId,
    this.parentId,
    this.order,
    this.labels,
    this.priority,
    this.dueString,
    this.dueDate,
    this.dueDatetime,
    this.dueLang,
    this.assigneeId,
    this.isCompleted,
    this.commentCount,
    this.createdAt,
    this.duration,
    this.url,
  }) : super(
          id: id,
          content: content,
          description: description,
          projectId: projectId,
          sectionId: sectionId,
          parentId: parentId,
          order: order,
          labels: labels,
          priority: priority,
          dueString: dueString,
          dueDate: dueDate,
          dueDatetime: dueDatetime,
          dueLang: dueLang,
          assigneeId: assigneeId,
          isCompleted: isCompleted,
          commentCount: commentCount,
          createdAt: createdAt,
          duration: duration,
          url: url,
        );

  factory TaskModelHive.fromJson(Map<String, dynamic> json) {
    return TaskModelHive(
      id: json['id'],
      content: json['content'],
      description: json['description'],
      projectId: json['project_id'],
      sectionId: json['section_id'],
      parentId: json['parent_id'],
      order: json['order'],
      labels: List<String>.from(json['labels'] ?? []),
      priority: json['priority'],
      dueString: json['due_string'],
      dueDate: json['due_date'],
      dueDatetime: json['due_datetime'],
      dueLang: json['due_lang'],
      assigneeId: json['assignee_id'],
      isCompleted: json['is_completed'],
      commentCount: json['comment_count'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      duration: json['duration'],
      url: json['url'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    data['id'] = id;
    if (content != null) data['content'] = content;
    if (description != null) data['description'] = description;
    if (projectId != null) data['project_id'] = projectId;
    if (sectionId != null) data['section_id'] = sectionId;
    if (parentId != null) data['parent_id'] = parentId;
    if (order != null) data['order'] = order;
    if (labels != null && labels!.isNotEmpty) data['labels'] = labels;
    if (priority != null) data['priority'] = priority;
    if (dueString != null) data['due_string'] = dueString;
    if (dueDate != null) data['due_date'] = dueDate;
    if (dueDatetime != null) data['due_datetime'] = dueDatetime;
    if (dueLang != null) data['due_lang'] = dueLang;
    if (assigneeId != null) data['assignee_id'] = assigneeId;
    if (isCompleted != null) data['is_completed'] = isCompleted;
    if (commentCount != null) data['comment_count'] = commentCount;
    if (createdAt != null) data['created_at'] = createdAt?.toIso8601String();
    if (duration != null) data['duration'] = duration;
    if (url != null) data['url'] = url;

    return data;
  }
}
