class Task {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? reminderAt;

  Task({
    required this.id,
    required this.title,
    this.content = '',
    DateTime? createdAt,
    this.reminderAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? reminderAt,
    bool clearReminder = false,
  }) =>
      Task(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
        reminderAt: clearReminder ? null : (reminderAt ?? this.reminderAt),
      );

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'].toString(),
        title: json['title'] as String,
        content: (json['content'] as String?) ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
        reminderAt: json['reminder_at'] != null
            ? DateTime.parse(json['reminder_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
        'reminder_at': reminderAt?.toIso8601String(),
      };
}
