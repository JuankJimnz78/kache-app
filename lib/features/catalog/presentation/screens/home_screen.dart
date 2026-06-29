// lib/features/catalog/presentation/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../comercios/domain/models/comercio.dart';
import '../../../../core/theme/app_colors.dart';
import 'catalog_screen.dart';
import '../../../precios/presentation/screens/lista_comparacion_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _confirmarCerrarSesion(
      BuildContext context, WidgetRef ref) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que quieres salir de tu cuenta?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Cerrar sesión',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmar == true) {
      ref.read(authProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Encabezado con degradado de marca ──────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 56, 20, 28),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.accentDark, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
                bottomRight: Radius.circular(5),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('Kache',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.list_alt, color: Colors.white),
                      tooltip: 'Mi comparación',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ListaComparacionScreen()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () => _confirmarCerrarSesion(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '¡Hola, ${user?.username ?? ''}! 👋',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ahorra comparando antes de comprar',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // ── Contenido ────────────────────────────────────────────
          Expanded(
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _AnuncioPlaceholder(),
                    const SizedBox(height: 24),
                    const Text(
                      '¿Qué quieres comparar hoy?',
                      style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.05,
                      children: TipoComercio.values
                          .map((tipo) => _CategoriaTile(tipo: tipo))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnuncioPlaceholder extends StatelessWidget {
  const _AnuncioPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 84,
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.campaign_outlined, color: AppColors.textFaint, size: 20),
            SizedBox(height: 4),
            Text('Espacio para anuncio publicitario',
                style: TextStyle(color: AppColors.textFaint, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _CategoriaTile extends StatelessWidget {
  final TipoComercio tipo;
  const _CategoriaTile({required this.tipo});

  @override
  Widget build(BuildContext context) {
    final colorOscuro = Color.lerp(tipo.color, Colors.black, 0.25)!;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => CatalogScreen(tipo: tipo)));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [tipo.color, colorOscuro],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
                color: tipo.color.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(tipo.icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              tipo.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
