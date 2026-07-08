// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/theme/app_theme.dart';
import 'package:kache/theme/app_colors.dart';
import 'package:kache/presentation/providers/auth_provider.dart';
import 'package:kache/presentation/screens/auth/login_screen.dart';
import 'package:kache/presentation/screens/home_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KacheApp(),
    ),
  );
}

class KacheApp extends StatelessWidget {
  const KacheApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kache',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    switch (authState.status) {
      case AuthStatus.checking:
        return const Scaffold(
          backgroundColor: AppColors.background,
          body:
              Center(child: CircularProgressIndicator(color: AppColors.accent)),
        );
      case AuthStatus.authenticated:
        return const HomeScreen();
      case AuthStatus.unauthenticated:
        return const LoginScreen();
    }
  }
}
