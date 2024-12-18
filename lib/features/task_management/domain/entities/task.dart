import 'package:equatable/equatable.dart';

class TaskEntity extends Equatable {
  final String id;
  final String? content; // Task content
  final String? description; // Optional task description
  final String? projectId; // Task project ID
  final String? sectionId; // Section ID
  final String? parentId; // Parent task ID
  final int? order; // Order for sorting tasks
  final List<String>? labels; // Labels for the task
  final int? priority; // Task priority (1 - normal to 4 - urgent)
  final String? dueString; // Human-readable due date string
  final String? dueDate; // Specific due date in YYYY-MM-DD
  final String? dueDatetime; // RFC3339 formatted datetime
  final String? dueLang; // Language for due string
  final String? assigneeId; // User responsible for the task
  final bool? isCompleted; // Task completion status
  final int? commentCount; // Number of comments on the task
  final DateTime? createdAt; // Task creation timestamp
  final String? duration; // Task duration
  final String? url; // URL of the task

  const TaskEntity({
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
  });

  // Added copyWith method
  TaskEntity copyWith({
    String? id,
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
  }) {
    return TaskEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      sectionId: sectionId ?? this.sectionId,
      parentId: parentId ?? this.parentId,
      order: order ?? this.order,
      labels: labels ?? this.labels,
      priority: priority ?? this.priority,
      dueString: dueString ?? this.dueString,
      dueDate: dueDate ?? this.dueDate,
      dueDatetime: dueDatetime ?? this.dueDatetime,
      dueLang: dueLang ?? this.dueLang,
      assigneeId: assigneeId ?? this.assigneeId,
      isCompleted: isCompleted ?? this.isCompleted,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      url: url ?? this.url,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        description,
        projectId,
        sectionId,
        parentId,
        order,
        labels,
        priority,
        dueString,
        dueDate,
        dueDatetime,
        dueLang,
        assigneeId,
        isCompleted,
        commentCount,
        createdAt,
        duration,
        url,
      ];
}
