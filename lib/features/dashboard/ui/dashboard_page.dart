import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dayforge/features/dashboard/providers/task_provider.dart';
import 'package:dayforge/features/auth/providers/auth_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskProvider);
    final titleCtrl = TextEditingController();
    final isAdding = ref.watch(_addLoadingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DayForge Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Input bar untuk menambah task
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Tambah entri...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isAdding
                      ? null
                      : () async {
                          final txt = titleCtrl.text.trim();
                          if (txt.isEmpty) return;
                          ref.read(_addLoadingProvider.notifier).state = true;
                          try {
                            await ref.read(taskProvider.notifier).add(txt);
                            titleCtrl.clear();
                          } finally {
                            if (context.mounted) {
                              ref.read(_addLoadingProvider.notifier).state =
                                  false;
                            }
                          }
                        },
                  child: isAdding
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Daftar task / jurnal
          Expanded(
            child: tasksAsync.when(
              data: (tasks) => tasks.isEmpty
                  ? const Center(
                      child: Text('Tidak ada entri. Tambahkan di atas!'),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: tasks.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final task = tasks[idx];
                        return Dismissible(
                          key: ValueKey(task.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.redAccent,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (_) async {
                            await ref
                                .read(taskProvider.notifier)
                                .remove(task.id);
                          },
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.note_outlined,
                                color: Colors.deepPurple,
                              ),
                              title: Text(
                                task.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Ditambahkan pada ${task.createdAt.hour.toString().padLeft(2, '0')}:${task.createdAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // Placeholder untuk detail view
                              },
                            ),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Gagal memuat data: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple loading state for the add‑task button
final _addLoadingProvider = StateProvider<bool>((ref) => false);
