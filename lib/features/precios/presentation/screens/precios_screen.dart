// lib/features/precios/presentation/screens/precios_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/precio_provider.dart';
import '../providers/comparador_provider.dart';
import '../../domain/models/precio.dart';
import '../../../catalog/domain/models/producto.dart';
import '../../../comercios/domain/models/comercio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class PreciosScreen extends ConsumerWidget {
  final Producto producto;
  const PreciosScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preciosAsync = ref.watch(preciosPorProductoProvider(producto.id));

    return Scaffold(
      appBar: AppBar(title: Text(producto.nombre)),
      body: preciosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('No se pudieron cargar los precios.',
              style: TextStyle(color: AppColors.error)),
        ),
        data: (precios) {
          if (precios.isEmpty) {
            return const Center(
              child: Text(
                'Todavía no hay precios registrados para este producto.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: precios.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final precio = precios[index];
              final esElMasBarato = index == 0 && precios.length > 1;
              return _PrecioCard(
                  producto: producto,
                  precio: precio,
                  esElMasBarato: esElMasBarato);
            },
          );
        },
      ),
    );
  }
}

class _PrecioCard extends ConsumerWidget {
  final Producto producto;
  final Precio precio;
  final bool esElMasBarato;
  const _PrecioCard(
      {required this.producto,
      required this.precio,
      required this.esElMasBarato});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comercio = precio.comercioDetalle;
    final tipo = comercio != null
        ? TipoComercio.fromValue(comercio.tipo)
        : TipoComercio.supermercado;
    final cargando = ref.watch(comparadorProvider).cargando;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esElMasBarato ? AppColors.success : AppColors.border,
          width: esElMasBarato ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: tipo.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(tipo.icon, color: tipo.color, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(comercio?.nombre ?? 'Comercio',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                        if (esElMasBarato) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('MÁS BARATO',
                                style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                formatPrice(precio.precioEfectivo),
                style: TextStyle(
                  color:
                      esElMasBarato ? AppColors.success : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('Elegir este'),
              onPressed: (cargando || comercio == null)
                  ? null
                  : () async {
                      await ref
                          .read(comparadorProvider.notifier)
                          .agregarProducto(producto.id, comercio.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Agregado a tu comparación en ${comercio.nombre}')),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}
