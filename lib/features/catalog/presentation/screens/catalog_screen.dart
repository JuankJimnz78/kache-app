// lib/features/catalog/presentation/screens/catalog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalog_provider.dart';
import '../../../comercios/domain/models/comercio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../precios/presentation/screens/precios_screen.dart';

class CatalogScreen extends ConsumerWidget {
  final TipoComercio tipo;
  const CatalogScreen({super.key, required this.tipo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogProvider(tipo.value));
    final notifier = ref.read(catalogProvider(tipo.value).notifier);

    return Scaffold(
      appBar: AppBar(title: Text(tipo.label)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: notifier.buscar,
              decoration: InputDecoration(
                hintText: 'Buscar producto o marca...',
                prefixIcon: Icon(Icons.search, color: tipo.color),
              ),
            ),
          ),
          if (state.cargando)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.error != null)
            Expanded(
              child: Center(
                child: Text(state.error!,
                    style: const TextStyle(color: AppColors.error)),
              ),
            )
          else if (state.productos.isEmpty)
            const Expanded(
              child: Center(
                child: Text('No se encontraron productos.',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                itemCount: state.productos.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final producto = state.productos[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => PreciosScreen(producto: producto)),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: tipo.color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(tipo.icon, color: tipo.color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(producto.nombre,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                if (producto.marca.isNotEmpty)
                                  Text(
                                    producto.marca,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12),
                                  ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.textFaint),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
