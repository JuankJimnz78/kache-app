// lib/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/presentation/providers/auth_provider.dart';
import 'package:kache/presentation/navigation/app_router.dart';
import 'package:kache/theme/app_colors.dart';
import 'package:kache/presentation/widgets/fondo_patron.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final username = user?.username ?? '';
    final email = user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const FondoPatron(),
          SafeArea(
            child: Column(
              children: [
                // ── Encabezado con rombos y PreciosEC ───────────
                const EncabezadoPreciosEC(titulo: 'Mi Perfil'),
                const SizedBox(height: 16),

                // ── Avatar y datos del usuario ───────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person,
                            size: 32, color: Color(0xFF1A237E)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary),
                            ),
                            if (user != null && user.rol != 'CLIENTE') ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (user.esAdmin
                                          ? const Color(0xFF6A1B9A)
                                          : const Color(0xFF1565C0))
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  user.esAdmin ? 'Administrador' : 'Operador',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: user.esAdmin
                                        ? const Color(0xFF6A1B9A)
                                        : const Color(0xFF1565C0),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Opciones ─────────────────────────────────────
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Mi cuenta
                      _OpcionTile(
                        icono: Icons.person_outline,
                        titulo: 'Mi cuenta',
                        subtitulo: 'Información personal',
                        color: const Color(0xFF1565C0),
                        onTap: () => _mostrarDialogo(
                          context,
                          titulo: 'Mi cuenta',
                          contenido:
                              'Usuario: $username\nCorreo: $email',
                          icono: Icons.person_outline,
                          color: const Color(0xFF1565C0),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Notificaciones
                      _OpcionTile(
                        icono: Icons.notifications_outlined,
                        titulo: 'Notificaciones',
                        subtitulo: 'Alertas de precios y ofertas',
                        color: const Color(0xFFFF8F00),
                        onTap: () => _mostrarDialogo(
                          context,
                          titulo: 'Notificaciones',
                          contenido:
                              'Próximamente podrás configurar alertas cuando el precio de un producto baje en cualquier comercio.',
                          icono: Icons.notifications_outlined,
                          color: const Color(0xFFFF8F00),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Panel de administración (solo ADMIN u OPERADOR)
                      if (user?.puedeAdministrar == true) ...[
                        _OpcionTile(
                          icono: Icons.admin_panel_settings_outlined,
                          titulo: 'Panel de administración',
                          subtitulo: user!.esAdmin
                              ? 'Gestionar comercios, productos y precios'
                              : 'Gestionar productos y precios',
                          color: const Color(0xFF37474F),
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.admin),
                        ),
                        const SizedBox(height: 10),
                      ],

                      // Ayuda
                      _OpcionTile(
                        icono: Icons.help_outline,
                        titulo: 'Ayuda',
                        subtitulo: '¿Cómo usar PreciosEC?',
                        color: const Color(0xFF2E7D32),
                        onTap: () => _mostrarDialogo(
                          context,
                          titulo: 'Ayuda',
                          contenido:
                              '1. Elige una categoría (Supermercados, Farmacias o Ferreterías)\n\n'
                              '2. Selecciona una subcategoría\n\n'
                              '3. Toca un producto para ver sus precios en distintos comercios\n\n'
                              '4. Toca "Elegir este" para agregar a tu lista de compras\n\n'
                              '5. En "Mi Lista" puedes pedir delivery o ver dónde recoger',
                          icono: Icons.help_outline,
                          color: const Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Acerca de PreciosEC
                      _OpcionTile(
                        icono: Icons.info_outline,
                        titulo: 'Acerca de PreciosEC',
                        subtitulo: 'Versión 1.0.0',
                        color: const Color(0xFF6A1B9A),
                        onTap: () => _mostrarDialogo(
                          context,
                          titulo: 'Acerca de PreciosEC',
                          contenido:
                              'PreciosEC es un comparador de precios para Ecuador.\n\n'
                              'Compara precios entre supermercados, farmacias y ferreterías para que siempre encuentres la mejor oferta antes de comprar.\n\n'
                              'Versión: 1.0.0\n'
                              'Desarrollado por: Equipo PreciosEC\n'
                              'Universidad: UTE',
                          icono: Icons.info_outline,
                          color: const Color(0xFF6A1B9A),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 10),

                      // Cerrar sesión
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
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
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
                                      style: TextStyle(
                                          color: AppColors.error)),
                                ),
                              ],
                            ),
                          );
                          if (confirmar == true) {
                            ref.read(authProvider.notifier).logout();
                          }
                        },
                      ),
                      const SizedBox(height: 20),
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

  void _mostrarDialogo(
    BuildContext context, {
    required String titulo,
    required String contenido,
    required IconData icono,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(titulo,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          contenido,
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
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
  final Color color;

  const _OpcionTile({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: color == AppColors.error
                              ? AppColors.error
                              : AppColors.textPrimary)),
                  Text(subtitulo,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                color: color.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}
