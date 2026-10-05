import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dayforge/features/auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    ref.read(_loginLoadingProvider.notifier).set(true);
                    try {
                      await ref.read(authServiceProvider).signInWithEmailPassword(
                        _emailController.text.trim(),
                        _passwordController.text,
                      );
                      // GoRouter redirect will automatically navigate to /dashboard
                      // via refreshListenable when auth state changes
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    } finally {
                      if (mounted) {
                        ref.read(_loginLoadingProvider.notifier).set(false);
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

// Simple loading state notifier for the login button
class _LoginLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final _loginLoadingProvider = NotifierProvider<_LoginLoadingNotifier, bool>(
  _LoginLoadingNotifier.new,
);
