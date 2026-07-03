// lib/features/precios/presentation/screens/lista_comparacion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/comparador_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';

class ListaComparacionScreen extends ConsumerStatefulWidget {
  const ListaComparacionScreen({super.key});

  @override
  ConsumerState<ListaComparacionScreen> createState() =>
      _ListaComparacionScreenState();
}

class _ListaComparacionScreenState
    extends ConsumerState<ListaComparacionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(comparadorProvider.notifier).cargarListaActiva());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comparadorProvider);
    final detalle = state.detalle;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi lista de compras')),
      body: () {
        if (state.cargando && detalle == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (detalle == null || detalle.items.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Todavía no has elegido ningún producto.\nVe a un producto y toca "Elegir este" en el comercio que prefieras.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: detalle.totalesPorComercio.map((total) {
            final itemsDeEsteComercio = detalle.items
                .where((i) => i.comercioDetalle.id == total.idComercio)
                .toList();
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(total.nombreComercio,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(formatPrice(total.total),
                          style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 20),
                  ...itemsDeEsteComercio.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(child: Text(item.productoDetalle.nombre)),
                            Text(formatPrice(item.precioMomento)),
                            IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: AppColors.textFaint),
                              onPressed: () => ref
                                  .read(comparadorProvider.notifier)
                                  .eliminarItem(item.id),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            );
          }).toList(),
        );
      }(),
    );
  }
}
