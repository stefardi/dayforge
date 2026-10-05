class Task {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    this.content = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Task copyWith({String? title, String? content}) => Task(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        createdAt: createdAt,
      );

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'].toString(),
        title: json['title'] as String,
        content: (json['content'] as String?) ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };
}
