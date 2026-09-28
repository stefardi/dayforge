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
      // Redirect unauthenticated users to login (except when on register page)
      final authAsync = ref.watch(authStateProvider);
      return authAsync.when(
        data: (auth) => auth.session == null && state.matchedLocation != '/register' ? '/login' : null,
        loading: () => null,
        error: (error, stack) => '/login',
      );
    },
    refreshListenable: null,
  );
});
