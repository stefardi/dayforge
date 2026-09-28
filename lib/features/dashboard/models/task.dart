class Task {
  final String id;
  final String title;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Optional: convert from JSON (Supabase) and to JSON
  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'].toString(),
        title: json['title'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt.toIso8601String(),
      };
}
