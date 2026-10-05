import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dayforge/features/dashboard/models/task.dart';

class TaskRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final String _table = 'tasks'; // Pastikan tabel ini ada di Supabase

  String get _userId => _client.auth.currentUser!.id;

  // Membuat (insert) task baru
  Future<void> createTask(String title) async {
    await _client.from(_table).insert({
      'title': title,
      'user_id': _userId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Mengambil semua task milik user yang sedang login (read)
  Future<List<Task>> fetchTasks() async {
    final res = await _client
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    // Mapping ke model Task
    return (res as List).map((json) {
      return Task(
        id: json['id'].toString(),
        title: json['title'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    }).toList();
  }

  // Menghapus task berdasar id
  Future<void> deleteTask(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}

