// lib/presentation/screens/admin/productos_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/domain/model/producto.dart';
import 'package:kache/presentation/providers/admin/categoria_admin_provider.dart';
import 'package:kache/presentation/providers/admin/producto_admin_provider.dart';
import 'package:kache/presentation/screens/admin/widgets/admin_list_scaffold.dart';
import 'package:kache/theme/app_colors.dart';

class ProductosAdminScreen extends ConsumerStatefulWidget {
  const ProductosAdminScreen({super.key});

  @override
  ConsumerState<ProductosAdminScreen> createState() =>
      _ProductosAdminScreenState();
}

class _ProductosAdminScreenState extends ConsumerState<ProductosAdminScreen> {
  final _buscarCtrl = TextEditingController();
  int? _filtroCategoria;

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productoAdminProvider);
    final notifier = ref.read(productoAdminProvider.notifier);
    final categorias = ref.watch(categoriaAdminProvider).items;

    return AdminListScaffold<Producto>(
      state: state,
      onRefrescar: notifier.cargar,
      onCargarMas: notifier.cargarMas,
      etiquetaVacio: 'No hay productos registrados.',
      iconoVacio: Icons.inventory_2_outlined,
      onAgregar: () => _abrirFormulario(context),
      barraFiltros: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _buscarCtrl,
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o marca...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
            ),
            onSubmitted: (v) => notifier.establecerFiltros(
              buscar: v.trim().isEmpty ? null : v.trim(),
              idCategoria: _filtroCategoria,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _ChipCategoria(
                  label: 'Todas',
                  seleccionado: _filtroCategoria == null,
                  onTap: () {
                    setState(() => _filtroCategoria = null);
                    notifier.establecerFiltros(
                      buscar: _buscarCtrl.text.trim().isEmpty
                          ? null
                          : _buscarCtrl.text.trim(),
                      idCategoria: null,
                    );
                  },
                ),
                for (final c in categorias)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: _ChipCategoria(
                      label: c.nombre,
                      seleccionado: _filtroCategoria == c.id,
                      onTap: () {
                        setState(() => _filtroCategoria = c.id);
                        notifier.establecerFiltros(
                          buscar: _buscarCtrl.text.trim().isEmpty
                              ? null
                              : _buscarCtrl.text.trim(),
                          idCategoria: c.id,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      itemBuilder: (context, producto) => AdminItemCard(
        titulo: producto.nombre,
        subtitulo:
            '${producto.marca.isEmpty ? 'Sin marca' : producto.marca} · ${producto.unidadMedida}',
        badge: producto.categoriaDetalle?.nombre,
        leading: const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0x1AC9952E),
          child: Icon(Icons.inventory_2, size: 18, color: AppColors.accentDark),
        ),
        onEditar: () => _abrirFormulario(context, producto: producto),
        onEliminar: () async {
          final confirmar = await confirmarEliminar(context, producto.nombre);
          if (confirmar) {
            await ref
                .read(productoAdminProvider.notifier)
                .eliminar(producto.id);
          }
        },
      ),
    );
  }

  void _abrirFormulario(BuildContext context, {Producto? producto}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProductoFormSheet(producto: producto),
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipCategoria({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: seleccionado ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: seleccionado ? AppColors.accent : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: seleccionado ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProductoFormSheet extends ConsumerStatefulWidget {
  final Producto? producto;
  const _ProductoFormSheet({this.producto});

  @override
  ConsumerState<_ProductoFormSheet> createState() =>
      _ProductoFormSheetState();
}

class _ProductoFormSheetState extends ConsumerState<_ProductoFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _marcaCtrl;
  late final TextEditingController _codigoCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _unidadCtrl;
  int? _idCategoria;

  bool get _esEdicion => widget.producto != null;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p?.nombre ?? '');
    _marcaCtrl = TextEditingController(text: p?.marca ?? '');
    _codigoCtrl = TextEditingController(text: p?.codigoBarras ?? '');
    _descripcionCtrl = TextEditingController(text: p?.descripcion ?? '');
    _unidadCtrl = TextEditingController(text: p?.unidadMedida ?? '');
    _idCategoria = p?.idCategoria;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _marcaCtrl.dispose();
    _codigoCtrl.dispose();
    _descripcionCtrl.dispose();
    _unidadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardando = ref.watch(productoAdminProvider).guardando;
    final categorias = ref.watch(categoriaAdminProvider).items;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _esEdicion ? 'Editar producto' : 'Nuevo producto',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nombreCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _marcaCtrl,
                  decoration: const InputDecoration(labelText: 'Marca'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _unidadCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Unidad de medida (ej: 1L, 500g)'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codigoCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Código de barras (opcional)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descripcionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _idCategoria,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                    for (final c in categorias)
                      DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  ],
                  onChanged: (v) => setState(() => _idCategoria = v),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: guardando ? null : _guardar,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: guardando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(_esEdicion ? 'Guardar cambios' : 'Crear producto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final producto = Producto(
      id: widget.producto?.id ?? 0,
      nombre: _nombreCtrl.text.trim(),
      marca: _marcaCtrl.text.trim(),
      codigoBarras:
          _codigoCtrl.text.trim().isEmpty ? null : _codigoCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      unidadMedida: _unidadCtrl.text.trim(),
      idCategoria: _idCategoria,
      imagenUrl: widget.producto?.imagenUrl,
      categoriaDetalle: widget.producto?.categoriaDetalle,
    );

    final notifier = ref.read(productoAdminProvider.notifier);
    final ok = _esEdicion
        ? await notifier.actualizar(widget.producto!.id, producto)
        : await notifier.crear(producto);

    if (ok && mounted) Navigator.of(context).pop();
  }
}
