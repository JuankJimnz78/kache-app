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
import 'lista_comparacion_screen.dart';

class PreciosScreen extends ConsumerWidget {
  final Producto producto;
  const PreciosScreen({super.key, required this.producto});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preciosAsync = ref.watch(preciosPorProductoProvider(producto.id));

    return Scaffold(
      appBar: AppBar(title: const Text('Comparar precios')),
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
          return Column(
            children: [
              // ── Encabezado con nombre completo del producto ──────
              Builder(
                builder: (context) {
                  // Tomamos el color del primer precio (el más barato)
                  final precioBarato = precios.first;
                  final comercioBarato = precioBarato.comercioDetalle;
                  final tipoBarato = comercioBarato != null
                      ? TipoComercio.fromValue(comercioBarato.tipo)
                      : TipoComercio.supermercado;
                  final colorBarato = comercioBarato != null
                      ? Comercio(
                          id: comercioBarato.id,
                          nombre: comercioBarato.nombre,
                          tipo: tipoBarato,
                          activo: true,
                          destacado: false,
                          destacadoActivo: false,
                        ).colorMarca
                      : tipoBarato.color;
                  final colorOscuro =
                      Color.lerp(colorBarato, Colors.black, 0.3)!;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colorBarato, colorOscuro],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          producto.nombre,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        if (producto.marca.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            producto.marca,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Elige el comercio donde quieres comprarlo',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const Divider(height: 1),

              // ── Tarjetas de precios ───────────────────────────────
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
                ),
              ),

              // ── Botón ir a lista ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  label: const Text('Ir a mis listas de compras'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ListaComparacionScreen()),
                  ),
                ),
              ),
            ],
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

    final colorBase = comercio != null
        ? Comercio(
            id: comercio.id,
            nombre: comercio.nombre,
            tipo: tipo,
            activo: true,
            destacado: false,
            destacadoActivo: false,
          ).colorMarca
        : tipo.color;
    final colorOscuro = Color.lerp(colorBase, Colors.black, 0.3)!;

    return Container(
      decoration: BoxDecoration(
        color: esElMasBarato
            ? colorBase.withValues(alpha: 0.10)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: esElMasBarato
              ? colorBase.withValues(alpha: 0.4)
              : AppColors.border,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
              color: esElMasBarato
                  ? colorBase.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: comercio?.logoUrl != null
                        ? Image.network(
                            comercio!.logoUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(tipo.emoji,
                                  style: const TextStyle(fontSize: 22)),
                            ),
                          )
                        : Center(
                            child: Text(tipo.emoji,
                                style: const TextStyle(fontSize: 22)),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comercio?.nombre ?? 'Comercio',
                            style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                          if (esElMasBarato) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('MÁS BARATO',
                                  style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ],
                      ),
                      if (precio.enOferta)
                        const Text('En oferta',
                            style: TextStyle(
                                color: AppColors.warning, fontSize: 12)),
                    ],
                  ),
                ),
                Text(
                  formatPrice(precio.precioEfectivo),
                  style: TextStyle(
                      color: esElMasBarato ? colorBase : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: Icon(Icons.add_shopping_cart, size: 18, color: colorBase),
                label: Text('Elegir este', style: TextStyle(color: colorBase)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorBase),
                ),
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
                                    'Agregado a tu lista en ${comercio.nombre}')),
                          );
                        }
                      },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
