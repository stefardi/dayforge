// lib/config/supabase_config.dart

/// Configuration class for Supabase.
///
/// Credentials are read safely at compile-time from environment variables.
/// When running or building the app, pass:
///   `--dart-define-from-file=.env`
class SupabaseConfig {
  /// Supabase project URL (read from `--dart-define=SUPABASE_URL=...` or `.env`)
  static const String url = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anonymous key (read from `--dart-define=SUPABASE_ANON_KEY=...` or `.env`)
  static const String anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Returns true if both URL and Anon Key are supplied.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
