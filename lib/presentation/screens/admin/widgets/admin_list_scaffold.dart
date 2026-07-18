// lib/presentation/screens/admin/widgets/admin_list_scaffold.dart
//
// Estructura visual compartida por las 5 pantallas de listado del panel
// admin: barra de filtros (slot), scroll infinito (paginación), pull to
// refresh, estados de carga/vacío/error, y botón flotante para agregar.

import 'package:flutter/material.dart';
import 'package:kache/theme/app_colors.dart';
import 'package:kache/presentation/providers/admin/admin_list_base.dart';

class AdminListScaffold<T> extends StatefulWidget {
  final AdminListState<T> state;
  final Future<void> Function() onRefrescar;
  final VoidCallback onCargarMas;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final VoidCallback onAgregar;
  final Widget? barraFiltros;
  final String etiquetaVacio;
  final IconData iconoVacio;

  const AdminListScaffold({
    super.key,
    required this.state,
    required this.onRefrescar,
    required this.onCargarMas,
    required this.itemBuilder,
    required this.onAgregar,
    this.barraFiltros,
    this.etiquetaVacio = 'No hay registros todavía.',
    this.iconoVacio = Icons.inbox_outlined,
  });

  @override
  State<AdminListScaffold<T>> createState() => _AdminListScaffoldState<T>();
}

class _AdminListScaffoldState<T> extends State<AdminListScaffold<T>> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      widget.onCargarMas();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: widget.onAgregar,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          if (widget.barraFiltros != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: widget.barraFiltros!,
            ),
          if (state.total > 0 || state.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${state.total} en total',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textFaint,
                  ),
                ),
              ),
            ),
          if (state.error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.error!,
                      style: const TextStyle(
                          color: AppColors.error, fontSize: 12.5),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onRefrescar,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: state.cargando
                ? const Center(child: CircularProgressIndicator())
                : state.items.isEmpty
                    ? _EstadoVacio(
                        icono: widget.iconoVacio,
                        texto: widget.etiquetaVacio,
                        onRefrescar: widget.onRefrescar,
                      )
                    : RefreshIndicator(
                        onRefresh: widget.onRefrescar,
                        child: ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                          itemCount:
                              state.items.length + (state.hayMas ? 1 : 0),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5),
                                  ),
                                ),
                              );
                            }
                            return widget.itemBuilder(
                                context, state.items[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String texto;
  final Future<void> Function() onRefrescar;

  const _EstadoVacio({
    required this.icono,
    required this.texto,
    required this.onRefrescar,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => RefreshIndicator(
        onRefresh: onRefrescar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: constraints.maxHeight,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icono, size: 48, color: AppColors.textFaint),
                    const SizedBox(height: 12),
                    Text(
                      texto,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textFaint),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tarjeta base para cada fila del listado admin: título, subtítulo,
/// badge de estado opcional, y botones de editar/eliminar.
class AdminItemCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Widget? leading;
  final String? badge;
  final Color? colorBadge;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;

  const AdminItemCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.leading,
    this.badge,
    this.colorBadge,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 12)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (colorBadge ?? AppColors.accent)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: colorBadge ?? AppColors.accentDark,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitulo,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.textSecondary),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            color: AppColors.info,
            onPressed: onEditar,
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppColors.error,
            onPressed: onEliminar,
            tooltip: 'Eliminar',
          ),
        ],
      ),
    );
  }
}

/// Confirmación estándar antes de eliminar un registro.
Future<bool> confirmarEliminar(BuildContext context, String nombre) async {
  final resultado = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Eliminar registro'),
      content: Text('¿Seguro que quieres eliminar "$nombre"? '
          'Esta acción no se puede deshacer.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Eliminar',
              style: TextStyle(color: AppColors.error)),
        ),
      ],
    ),
  );
  return resultado ?? false;
}
