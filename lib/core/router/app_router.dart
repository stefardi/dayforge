import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:dayforge/features/auth/ui/login_page.dart';
import 'package:dayforge/features/auth/ui/register_page.dart';
import 'package:dayforge/features/dashboard/ui/dashboard_page.dart';


/// A [ChangeNotifier] that listens to Supabase auth state changes
/// and notifies GoRouter to re-evaluate the redirect callback.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _authChangeNotifierProvider = Provider<_AuthChangeNotifier>((ref) {
  final notifier = _AuthChangeNotifier();
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authChangeNotifier = ref.watch(_authChangeNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    // Re-evaluates redirect whenever Supabase auth state changes
    refreshListenable: authChangeNotifier,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
    redirect: (context, state) {
      // Read session synchronously — always up-to-date after auth changes
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // If logged in and on an auth page, redirect to dashboard
      if (isLoggedIn && isOnAuthPage) {
        return '/dashboard';
      }

      // If not logged in and trying to access a protected page, redirect to login
      if (!isLoggedIn && !isOnAuthPage) {
        return '/login';
      }

      // No redirect needed
      return null;
    },
  );
});
