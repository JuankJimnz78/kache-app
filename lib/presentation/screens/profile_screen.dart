// lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/presentation/providers/auth_provider.dart';
import 'package:kache/theme/app_colors.dart';
import 'package:kache/core/widgets/fondo_patron.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 244, 248),
      body: Stack(
        children: [
          const FondoPatron(),
          SafeArea(
            child: Column(
              children: [
                // ── Encabezado ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(130, 10, 130, 10),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 165, 0),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            size: 44, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.username ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user?.email ?? '',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Opciones ─────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _OpcionTile(
                        icono: Icons.person_outline,
                        titulo: 'Mi cuenta',
                        subtitulo: 'Información personal',
                        onTap: () {},
                      ),
                      _OpcionTile(
                        icono: Icons.notifications_outlined,
                        titulo: 'Notificaciones',
                        subtitulo: 'Alertas de precios',
                        onTap: () {},
                      ),
                      _OpcionTile(
                        icono: Icons.help_outline,
                        titulo: 'Ayuda',
                        subtitulo: '¿Cómo usar PreciosEC?',
                        onTap: () {},
                      ),
                      _OpcionTile(
                        icono: Icons.info_outline,
                        titulo: 'Acerca de PreciosEC',
                        subtitulo: 'Versión 1.0.0',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      _OpcionTile(
                        icono: Icons.logout,
                        titulo: 'Cerrar sesión',
                        subtitulo: 'Salir de tu cuenta',
                        color: AppColors.error,
                        onTap: () async {
                          final confirmar = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.surface,
                              title: const Text('Cerrar sesión'),
                              content: const Text(
                                  '¿Seguro que quieres salir de tu cuenta?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Cerrar sesión',
                                      style: TextStyle(color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirmar == true) {
                            ref.read(authProvider.notifier).logout();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OpcionTile extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final Color? color;

  const _OpcionTile({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icono, color: c, size: 20),
        ),
        title: Text(titulo,
            style: TextStyle(fontWeight: FontWeight.w600, color: c)),
        subtitle: Text(subtitulo,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: c.withValues(alpha: 0.5)),
        onTap: onTap,
      ),
    );
  }
}
