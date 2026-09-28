// import 'package:flutter/material.dart'; // unused
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dayforge/features/auth/ui/login_page.dart';
import 'package:dayforge/features/auth/ui/register_page.dart';
import 'package:dayforge/features/dashboard/ui/dashboard_page.dart';
import 'package:dayforge/features/auth/providers/auth_provider.dart'; // auth providers
// import 'package:supabase_flutter/supabase_flutter.dart'; // unused

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',
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
      final authAsync = ref.read(authStateProvider);
      final isLoggedIn = authAsync.whenOrNull(
        data: (auth) => auth.session != null,
      ) ?? false;

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
