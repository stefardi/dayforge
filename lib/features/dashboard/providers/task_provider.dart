import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:dayforge/features/dashboard/models/task.dart';
import 'package:dayforge/features/dashboard/repositories/task_repository.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) => TaskRepository());

// Notifier yang memuat data dari Supabase
class TaskNotifier extends Notifier<AsyncValue<List<Task>>> {
  late final TaskRepository _repo;

  @override
  AsyncValue<List<Task>> build() {
    _repo = ref.read(taskRepositoryProvider);
    _load(); // muat data saat pertama kali
    return const AsyncLoading();
  }

  Future<void> _load() async {
    try {
      final tasks = await _repo.fetchTasks();
      state = AsyncData(tasks);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> add(String title) async {
    await _repo.createTask(title);
    await _load(); // refresh setelah insert
  }

  Future<void> update(String id, {required String title, required String content}) async {
    await _repo.updateTask(id, title: title, content: content);
    await _load(); // refresh setelah update
  }

  Future<void> remove(String id) async {
    await _repo.deleteTask(id);
    await _load(); // refresh setelah delete
  }

  Future<void> refresh() => _load();
}

// Provider global
final taskProvider =
    NotifierProvider<TaskNotifier, AsyncValue<List<Task>>>(
      TaskNotifier.new,
    );

