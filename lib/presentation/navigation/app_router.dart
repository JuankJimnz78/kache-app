// lib/presentation/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/presentation/providers/auth_provider.dart';
import 'package:kache/presentation/screens/auth/login_screen.dart';
import 'package:kache/presentation/screens/auth/register_screen.dart';
import 'package:kache/presentation/screens/home_screen.dart';
import 'package:kache/presentation/screens/admin/admin_home_screen.dart';
import 'package:kache/presentation/screens/admin/widgets/admin_guard.dart';

/// Rutas nombradas de la aplicación.
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String catalog = '/catalog';
  static const String precios = '/precios';
  static const String comparador = '/comparador';
  static const String admin = '/admin';
}

/// Guard de autenticación — redirige al login si no hay sesión activa.
class AuthGuard extends ConsumerWidget {
  final Widget child;
  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      AuthStatus.checking => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.authenticated => child,
      AuthStatus.unauthenticated => const LoginScreen(),
    };
  }
}

/// Generador de rutas de la aplicación.
/// Uso: MaterialApp(onGenerateRoute: AppRouter.generateRoute)
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: HomeScreen()),
        );

      case AppRoutes.admin:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(
            child: AdminGuard(child: AdminHomeScreen()),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const AuthGuard(child: HomeScreen()),
        );
    }
  }
}
