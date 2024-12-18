import '../../domain/entities/task.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required String id,
    String? content,
    String? description,
    String? projectId,
    String? sectionId,
    String? parentId,
    int? order,
    List<String>? labels,
    int? priority,
    String? dueString,
    String? dueDate,
    String? dueDatetime,
    String? dueLang,
    String? assigneeId,
    bool? isCompleted,
    int? commentCount,
    DateTime? createdAt,
    String? duration,
    String? url,
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
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

  static TaskModel fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      content: entity.content,
      description: entity.description,
      projectId: entity.projectId,
      sectionId: entity.sectionId,
      parentId: entity.parentId,
      order: entity.order,
      labels: entity.labels,
      priority: entity.priority,
      dueString: entity.dueString,
      dueDate: entity.dueDate,
      dueDatetime: entity.dueDatetime,
      dueLang: entity.dueLang,
      assigneeId: entity.assigneeId,
      isCompleted: entity.isCompleted,
      commentCount: entity.commentCount,
      createdAt: entity.createdAt,
      duration: entity.duration,
      url: entity.url,
    );
  }

  TaskEntity toEntity() {
    return TaskEntity(
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
  }
}
