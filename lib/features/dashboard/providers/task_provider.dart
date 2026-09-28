import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayforge/features/dashboard/models/task.dart';
import 'package:dayforge/features/dashboard/repositories/task_repository.dart';

final taskRepositoryProvider = Provider((ref) => TaskRepository());

// StateNotifier yang memuat data dari Supabase
class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository _repo;
  TaskNotifier(this._repo) : super(const AsyncLoading()) {
    _load(); // muat data saat pertama kali
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

  Future<void> remove(String id) async {
    await _repo.deleteTask(id);
    await _load(); // refresh setelah delete
  }

  Future<void> refresh() => _load();
}

// Provider global
final taskProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>(
      (ref) => TaskNotifier(ref.read(taskRepositoryProvider)),
    );
