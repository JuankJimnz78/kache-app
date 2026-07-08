// lib/features/catalog/presentation/screens/catalog_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalog_provider.dart';
import '../../../comercios/domain/models/comercio.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../precios/presentation/screens/precios_screen.dart';
import '../../../../core/widgets/fondo_patron.dart';

class CatalogScreen extends ConsumerWidget {
  final TipoComercio tipo;
  final int? idCategoria;
  final String? nombreCategoria;
  const CatalogScreen(
      {super.key, required this.tipo, this.idCategoria, this.nombreCategoria});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerKey =
        idCategoria != null ? '${tipo.value}_$idCategoria' : tipo.value;
    final state = ref.watch(catalogProvider(providerKey));
    final notifier = ref.read(catalogProvider(providerKey).notifier);
    final colorOscuro = Color.lerp(tipo.color, Colors.black, 0.25)!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const FondoPatron(),
          Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 48, 20, 40),
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
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(tipo.emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          nombreCategoria ?? tipo.label,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -22,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 12,
                              offset: const Offset(0, 4)),
                        ],
                      ),
                      child: TextField(
                        onChanged: notifier.buscar,
                        decoration: InputDecoration(
                          hintText: 'Buscar producto o marca...',
                          prefixIcon: Icon(Icons.search, color: tipo.color),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 38),
              if (state.cargando)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: state.productos.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final producto = state.productos[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) =>
                                    PreciosScreen(producto: producto)),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: tipo.color.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: tipo.color.withValues(alpha: 0.25)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: tipo.color.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: producto.imagenUrl != null
                                    ? Image.network(
                                        producto.imagenUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(tipo.emoji,
                                              style: const TextStyle(
                                                  fontSize: 20)),
                                        ),
                                      )
                                    : Center(
                                        child: Text(tipo.emoji,
                                            style:
                                                const TextStyle(fontSize: 20)),
                                      ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(producto.nombre,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    if (producto.marca.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          producto.marca,
                                          style: const TextStyle(
                                              color: AppColors.textSecondary,
                                              fontSize: 12),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: tipo.color.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.compare_arrows,
                                    color: colorOscuro, size: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
