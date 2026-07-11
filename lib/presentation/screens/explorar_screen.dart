// lib/presentation/screens/explorar_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/presentation/providers/catalog_provider.dart';
import 'package:kache/domain/model/comercio.dart';
import 'package:kache/theme/app_colors.dart';
import 'package:kache/core/widgets/fondo_patron.dart';
import 'package:kache/presentation/screens/catalog/precios_screen.dart';

class ExplorarScreen extends ConsumerStatefulWidget {
  const ExplorarScreen({super.key});

  @override
  ConsumerState<ExplorarScreen> createState() => _ExplorarScreenState();
}

class _ExplorarScreenState extends ConsumerState<ExplorarScreen> {
  final _controller = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Busca en todos los tipos a la vez
    final supState = ref.watch(catalogProvider('supermercado'));
    final farState = ref.watch(catalogProvider('farmacia'));
    final ferState = ref.watch(catalogProvider('ferreteria'));

    final todos = [
      ...supState.productos,
      ...farState.productos,
      ...ferState.productos,
    ];

    final filtrados = _busqueda.isEmpty
        ? []
        : todos
            .where((p) =>
                p.nombre.toLowerCase().contains(_busqueda.toLowerCase()) ||
                p.marca.toLowerCase().contains(_busqueda.toLowerCase()))
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const FondoPatron(),
          SafeArea(
            child: Column(
              children: [
                // ── Encabezado ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 165, 0),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Explorar',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Busca en todos los comercios',
                          style: TextStyle(color: Colors.blue, fontSize: 20)),
                      const SizedBox(height: 16),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8),
                          ],
                        ),
                        child: TextField(
                          controller: _controller,
                          onChanged: (v) => setState(() => _busqueda = v),
                          decoration: InputDecoration(
                            hintText: 'Buscar producto o marca...',
                            prefixIcon: const Icon(Icons.search,
                                color: AppColors.accent),
                            suffixIcon: _busqueda.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.close,
                                        color: AppColors.textFaint),
                                    onPressed: () {
                                      _controller.clear();
                                      setState(() => _busqueda = '');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Resultados ───────────────────────────────────
                Expanded(
                  child: _busqueda.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.search,
                                  size: 64, color: AppColors.textFaint),
                              SizedBox(height: 16),
                              Text('Escribe para buscar productos',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                            ],
                          ),
                        )
                      : filtrados.isEmpty
                          ? const Center(
                              child: Text('No se encontraron productos.',
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              itemCount: filtrados.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final producto = filtrados[index];
                                return InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PreciosScreen(producto: producto),
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: AppColors.accent
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                              Icons.shopping_bag_outlined,
                                              color: AppColors.accent,
                                              size: 22),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(producto.nombre,
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14)),
                                              if (producto.marca.isNotEmpty)
                                                Text(producto.marca,
                                                    style: const TextStyle(
                                                        color: AppColors
                                                            .textSecondary,
                                                        fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.compare_arrows,
                                            color: AppColors.accent, size: 18),
                                      ],
                                    ),
                                  ),
                                );
                              },
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
