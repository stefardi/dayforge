// lib/features/dashboard/models/task.dart
// NOTE: File model utama ada di lib/features/dashboard/models/task.dart
// File ini deprecated, gunakan model dari dashboard/models/task.dart
class Task {
  final String id;
  final String title;
  final DateTime createdAt;

  Task({required this.id, required this.title, DateTime? createdAt})
    : createdAt = createdAt ?? DateTime.now();

  // Optional JSON helpers (bermanfaat untuk Supabase)
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
