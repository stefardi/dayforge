import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

/// Service untuk mengelola local notification (reminder).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inisialisasi plugin notification. Panggil sekali di `main()`.
  Future<void> init() async {
    if (_initialized) return;

    // Inisialisasi timezone
    tzdata.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    // Minta izin notifikasi di Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  /// Jadwalkan notifikasi pada waktu tertentu.
  ///
  /// [id] — ID unik notifikasi (gunakan hashCode dari task ID).
  /// [title] — Judul notifikasi.
  /// [body] — Isi notifikasi.
  /// [scheduledAt] — Waktu notifikasi dijadwalkan.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
  }) async {
    final tzScheduled = tz.TZDateTime.from(scheduledAt, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'dayforge_reminders',
      'Reminders',
      channelDescription: 'Notifikasi pengingat catatan DayForge',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id: id,
      scheduledDate: tzScheduled,
      notificationDetails: details,
      title: title,
      body: body,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Batalkan notifikasi berdasar ID.
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
  }

  /// Batalkan semua notifikasi.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
