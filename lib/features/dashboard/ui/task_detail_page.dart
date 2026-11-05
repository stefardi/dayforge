import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dayforge/features/dashboard/models/task.dart';
import 'package:dayforge/features/dashboard/providers/task_provider.dart';
import 'package:dayforge/core/services/notification_service.dart';

class TaskDetailPage extends ConsumerStatefulWidget {
  final Task task;

  const TaskDetailPage({super.key, required this.task});

  @override
  ConsumerState<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends ConsumerState<TaskDetailPage> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _contentCtrl;
  bool _isSaving = false;
  bool _hasChanges = false;

  late DateTime _selectedDate;
  DateTime? _reminderAt;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.task.title);
    _contentCtrl = TextEditingController(text: widget.task.content);
    _selectedDate = widget.task.createdAt;
    _reminderAt = widget.task.reminderAt;

    _titleCtrl.addListener(_onChanged);
    _contentCtrl.addListener(_onChanged);
  }

  void _onChanged() {
    final changed = _titleCtrl.text != widget.task.title ||
        _contentCtrl.text != widget.task.content;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul tidak boleh kosong')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(taskProvider.notifier).update(
            widget.task.id,
            title: title,
            content: _contentCtrl.text,
          );
      if (mounted) {
        setState(() => _hasChanges = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Entri berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ada perubahan yang belum disimpan'),
        content: const Text('Simpan sebelum keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar tanpa simpan'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop(false);
              await _save();
              if (mounted) context.pop();
            },
            child: const Text('Simpan & Keluar'),
          ),
        ],
      ),
    );
    return shouldLeave ?? false;
  }

  // ──────────────────────────────────────────────
  // Date Picker – ubah tanggal catatan
  // ──────────────────────────────────────────────
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pilih tanggal catatan',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked == null || !mounted) return;

    // Pertahankan jam & menit asli, hanya ganti tanggal
    final newDate = DateTime(
      picked.year,
      picked.month,
      picked.day,
      _selectedDate.hour,
      _selectedDate.minute,
      _selectedDate.second,
    );

    setState(() => _selectedDate = newDate);

    try {
      await ref
          .read(taskProvider.notifier)
          .updateDate(widget.task.id, createdAt: newDate);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tanggal catatan diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui tanggal: $e')),
        );
      }
    }
  }

  // ──────────────────────────────────────────────
  // Reminder – jadwalkan atau hapus pengingat
  // ──────────────────────────────────────────────
  Future<void> _pickReminder() async {
    final now = DateTime.now();

    // Pilih tanggal
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _reminderAt ?? now.add(const Duration(hours: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Pilih tanggal pengingat',
      cancelText: 'Batal',
      confirmText: 'Lanjut',
    );
    if (pickedDate == null || !mounted) return;

    // Pilih waktu
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _reminderAt ?? now.add(const Duration(hours: 1)),
      ),
      helpText: 'Pilih waktu pengingat',
      cancelText: 'Batal',
      confirmText: 'Simpan',
    );
    if (pickedTime == null || !mounted) return;

    final reminderDateTime = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // Validasi: reminder harus di masa depan
    if (reminderDateTime.isBefore(DateTime.now())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waktu pengingat harus di masa depan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _reminderAt = reminderDateTime);

    try {
      // Simpan ke Supabase
      await ref
          .read(taskProvider.notifier)
          .updateReminder(widget.task.id, reminderAt: reminderDateTime);

      // Jadwalkan local notification
      final notifId = widget.task.id.hashCode;
      await NotificationService.instance.scheduleNotification(
        id: notifId,
        title: '🔔 Pengingat: ${widget.task.title}',
        body: widget.task.content.isNotEmpty
            ? widget.task.content
            : 'Kamu punya catatan yang perlu dilihat',
        scheduledAt: reminderDateTime,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengingat diatur: ${_formatDateTime(reminderDateTime)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengatur pengingat: $e')),
        );
      }
    }
  }

  Future<void> _cancelReminder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Pengingat'),
        content: const Text('Apakah kamu yakin ingin menghapus pengingat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _reminderAt = null);

    try {
      // Hapus dari Supabase
      await ref
          .read(taskProvider.notifier)
          .updateReminder(widget.task.id, reminderAt: null);

      // Batalkan local notification
      final notifId = widget.task.id.hashCode;
      await NotificationService.instance.cancelNotification(notifId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengingat dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus pengingat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final isReminderPast =
        _reminderAt != null && _reminderAt!.isBefore(now);

    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final leave = await _onWillPop();
          if (leave && mounted) context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detail Entri'),
          leading: IconButton(
            tooltip: 'Kembali',
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              if (_hasChanges) {
                final leave = await _onWillPop();
                if (leave && mounted) context.pop();
              } else {
                context.pop();
              }
            },
          ),
          actions: [
            // Tombol Reminder
            IconButton(
              tooltip: _reminderAt != null
                  ? 'Ubah Pengingat'
                  : 'Atur Pengingat',
              icon: Icon(
                _reminderAt != null
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: _reminderAt != null
                    ? (isReminderPast ? Colors.grey : Colors.amber.shade700)
                    : null,
              ),
              onPressed: _pickReminder,
            ),
            // Tombol Simpan
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              IconButton(
                tooltip: 'Simpan',
                icon: Icon(
                  Icons.save_rounded,
                  color: _hasChanges ? colorScheme.primary : Colors.grey,
                ),
                onPressed: _hasChanges ? _save : null,
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tanggal — bisa di-tap untuk ubah
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withAlpha(128),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(_selectedDate),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),

              // Reminder badge
              if (_reminderAt != null) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickReminder,
                  onLongPress: _cancelReminder,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isReminderPast
                          ? Colors.grey.shade200
                          : Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isReminderPast
                            ? Colors.grey.shade400
                            : Colors.amber.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isReminderPast
                              ? Icons.notifications_off_rounded
                              : Icons.notifications_active_rounded,
                          size: 16,
                          color: isReminderPast
                              ? Colors.grey
                              : Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isReminderPast
                              ? 'Pengingat lewat: ${_formatDateTime(_reminderAt!)}'
                              : 'Pengingat: ${_formatDateTime(_reminderAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isReminderPast
                                ? Colors.grey.shade600
                                : Colors.amber.shade900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _cancelReminder,
                          child: Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: isReminderPast
                                ? Colors.grey
                                : Colors.amber.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Field Judul
              TextField(
                controller: _titleCtrl,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: 'Judul entri...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                textInputAction: TextInputAction.next,
                maxLines: 2,
                minLines: 1,
              ),

              const Divider(height: 24),

              // Field Isi / Konten
              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  style: const TextStyle(fontSize: 16, height: 1.6),
                  decoration: const InputDecoration(
                    hintText: 'Tulis isi catatan di sini...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ],
          ),
        ),
        // FAB simpan yang muncul saat ada perubahan
        floatingActionButton: _hasChanges
            ? FloatingActionButton.extended(
                onPressed: _isSaving ? null : _save,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Simpan'),
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}  •  '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
