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
      'content': '',
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

    return (res as List).map((json) => Task.fromJson(json)).toList();
  }

  // Mengambil satu task berdasar id
  Future<Task> fetchTask(String id) async {
    final res = await _client
        .from(_table)
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .single();
    return Task.fromJson(res);
  }

  // Memperbarui judul dan isi task
  Future<void> updateTask(
    String id, {
    required String title,
    required String content,
  }) async {
    await _client.from(_table).update({
      'title': title,
      'content': content,
    }).eq('id', id).eq('user_id', _userId);
  }

  // Memperbarui tanggal catatan
  Future<void> updateTaskDate(String id, {required DateTime createdAt}) async {
    await _client.from(_table).update({
      'created_at': createdAt.toIso8601String(),
    }).eq('id', id).eq('user_id', _userId);
  }

  // Memperbarui reminder
  Future<void> updateTaskReminder(String id, {DateTime? reminderAt}) async {
    await _client.from(_table).update({
      'reminder_at': reminderAt?.toIso8601String(),
    }).eq('id', id).eq('user_id', _userId);
  }

  // Menghapus task berdasar id
  Future<void> deleteTask(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
