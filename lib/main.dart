import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dayforge/config/supabase_config.dart';
import 'package:dayforge/core/router/app_router.dart';
import 'package:dayforge/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Validate that Supabase credentials were provided
  if (!SupabaseConfig.isConfigured) {
    throw StateError(
      '⚠️ Supabase credentials are missing!\n\n'
      'Please run the application with:\n'
      '  flutter run --dart-define-from-file=.env\n\n'
      'Make sure you have created your local .env file:\n'
      '  cp .env.example .env\n'
      'and filled in your SUPABASE_URL and SUPABASE_ANON_KEY.\n',
    );
  }

  // Initialize Supabase with environment variables
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );

  // Inisialisasi notification service untuk reminder
  await NotificationService.instance.init();

  runApp(
    const ProviderScope(
      child: DayForgeApp(),
    ),
  );
}

class DayForgeApp extends ConsumerWidget {
  const DayForgeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'DayForge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
