// lib/features/catalog/presentation/screens/subcategoria_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/categoria_provider.dart';
import '../../../comercios/domain/models/comercio.dart';
import '../../../../core/theme/app_colors.dart';
import 'catalog_screen.dart';

class SubcategoriaScreen extends ConsumerWidget {
  final TipoComercio tipo;
  const SubcategoriaScreen({super.key, required this.tipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategoriasAsync =
        ref.watch(subcategoriasProvider(tipo.idCategoriaPadre));
    final colorOscuro = Color.lerp(tipo.color, Colors.black, 0.25)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Encabezado ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 48, 20, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [tipo.color, colorOscuro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                Text(tipo.emoji, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Text(
                  tipo.label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Subcategorías ────────────────────────────────────
          Expanded(
            child: subcategoriasAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(
                child: Text('No se pudieron cargar las categorías.',
                    style: TextStyle(color: AppColors.error)),
              ),
              data: (subcategorias) {
                if (subcategorias.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(tipo.emoji, style: const TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        const Text('Próximamente más categorías',
                            style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  );
                }
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: subcategorias.length,
                  itemBuilder: (context, index) {
                    final cat = subcategorias[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CatalogScreen(
                            tipo: tipo,
                            idCategoria: cat.id,
                            nombreCategoria: cat.nombre,
                          ),
                        ),
                      ),
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
                              color: tipo.color.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(tipo.emoji,
                                  style: const TextStyle(fontSize: 24)),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              cat.nombre,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
