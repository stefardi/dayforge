import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';

import 'package:dayforge/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
// import 'package:riverpod/riverpod.dart'; // removed unused

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final isLoading = ref.watch(_loginLoadingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')), // placeholder, can be hidden later
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    ref.read(_loginLoadingProvider.notifier).state = true;
                    try {
                      await ref.read(authServiceProvider).signInWithEmailPassword(
                        emailController.text.trim(),
                        passwordController.text,
                      );
                      // Navigate to dashboard after successful login
                      if (context.mounted) {
                        context.go('/dashboard');
                      }
                    } finally {
                      if (context.mounted) {
                        ref.read(_loginLoadingProvider.notifier).state = false;
                      }
                    }
                  },
                  child: isLoading
                      ? const CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Simple loading state provider for the login button
final _loginLoadingProvider = StateProvider<bool>((ref) => false);
