// lib/presentation/screens/admin/widgets/admin_guard.dart
//
// Bloquea el acceso al panel admin a cualquier usuario cuyo JWT no traiga
// is_staff = true. La verificación real de permisos igual ocurre en el
// backend (IsAdminUser); esto solo evita que un usuario normal vea la
// pantalla y reciba errores 403 confusos.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/presentation/providers/auth_provider.dart';
import 'package:kache/theme/app_colors.dart';

class AdminGuard extends ConsumerWidget {
  final Widget child;
  const AdminGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puedeAdministrar =
        ref.watch(authProvider).user?.puedeAdministrar ?? false;

    if (!puedeAdministrar) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline,
                    size: 48, color: AppColors.textFaint),
                const SizedBox(height: 12),
                const Text(
                  'Acceso restringido',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Solo los administradores pueden ver esta sección.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return child;
  }
}
