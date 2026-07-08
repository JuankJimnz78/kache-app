// lib/features/precios/presentation/screens/lista_comparacion_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:kache/presentation/providers/comparador_provider.dart';
import 'package:kache/theme/app_colors.dart';
import 'package:kache/core/utils/formatters.dart';
import 'package:kache/core/utils/comercio_links.dart';
import 'package:kache/presentation/widgets/fondo_patron.dart';
import 'package:kache/domain/model/comercio.dart';

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

  Future<void> _abrirUrl(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el enlace.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comparadorProvider);
    final detalle = state.detalle;

    return Scaffold(
      appBar: AppBar(title: const Text('Mis listas de compras')),
      body: Stack(
        children: [
          const FondoPatron(),
          Builder(
            builder: (context) {
              if (state.cargando && detalle == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (detalle == null || detalle.items.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Todavía no has elegido ningún producto.\nVe a un producto y toca "Elegir este".',
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
                  final nombreComercio = total.nombreComercio;
                  final tipo = TipoComercio.fromValue(
                    itemsDeEsteComercio.isNotEmpty
                        ? itemsDeEsteComercio.first.comercioDetalle.tipo
                        : 'supermercado',
                  );
                  final tieneDelivery =
                      ComercioLinks.tieneDelivery(nombreComercio);
                  final urlMaps = ComercioLinks.urlMaps(nombreComercio);
                  final nombresProductos = itemsDeEsteComercio
                      .map((i) => i.productoDetalle.nombre)
                      .join(' ');

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: tipo.color.withValues(alpha: 0.08),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(tipo.emoji,
                                      style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 8),
                                  Text(
                                    nombreComercio,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                              Text(
                                formatPrice(total.total),
                                style: TextStyle(
                                  color: tipo.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...itemsDeEsteComercio.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(item.productoDetalle.nombre,
                                          style:
                                              const TextStyle(fontSize: 13))),
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
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              if (tieneDelivery) ...[
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.delivery_dining,
                                        size: 18),
                                    label: const Text('Delivery',
                                        style: TextStyle(fontSize: 13)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: tipo.color,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 44),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                    ),
                                    onPressed: () {
                                      final url = ComercioLinks.urlDelivery(
                                          nombreComercio, nombresProductos);
                                      if (url != null) _abrirUrl(url, context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.store_outlined,
                                      size: 18),
                                  label: const Text('Recoger en local',
                                      style: TextStyle(fontSize: 13)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: tipo.color,
                                    side: BorderSide(color: tipo.color),
                                    minimumSize: const Size(0, 44),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                  onPressed: urlMaps != null
                                      ? () => _abrirUrl(urlMaps, context)
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
