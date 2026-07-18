// lib/presentation/screens/admin/precios_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/core/utils/formatters.dart';
import 'package:kache/data/remote/admin/producto_admin_datasource.dart';
import 'package:kache/domain/model/precio.dart';
import 'package:kache/domain/model/producto.dart';
import 'package:kache/presentation/providers/admin/comercio_admin_provider.dart';
import 'package:kache/presentation/providers/admin/precio_admin_provider.dart';
import 'package:kache/presentation/screens/admin/widgets/admin_list_scaffold.dart';
import 'package:kache/theme/app_colors.dart';

class PreciosAdminScreen extends ConsumerStatefulWidget {
  const PreciosAdminScreen({super.key});

  @override
  ConsumerState<PreciosAdminScreen> createState() =>
      _PreciosAdminScreenState();
}

class _PreciosAdminScreenState extends ConsumerState<PreciosAdminScreen> {
  bool? _filtroEnOferta;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(precioAdminProvider);
    final notifier = ref.read(precioAdminProvider.notifier);

    return AdminListScaffold<Precio>(
      state: state,
      onRefrescar: notifier.cargar,
      onCargarMas: notifier.cargarMas,
      etiquetaVacio: 'No hay precios registrados.',
      iconoVacio: Icons.attach_money,
      onAgregar: () => _abrirFormulario(context),
      barraFiltros: Row(
        children: [
          _ChipFiltro(
            label: 'Todos',
            seleccionado: _filtroEnOferta == null,
            onTap: () {
              setState(() => _filtroEnOferta = null);
              notifier.establecerFiltros(enOferta: null);
            },
          ),
          const SizedBox(width: 8),
          _ChipFiltro(
            label: 'En oferta',
            seleccionado: _filtroEnOferta == true,
            onTap: () {
              setState(() => _filtroEnOferta = true);
              notifier.establecerFiltros(enOferta: true);
            },
          ),
        ],
      ),
      itemBuilder: (context, precio) => AdminItemCard(
        titulo: precio.productoDetalle?.nombre ?? 'Producto #${precio.idProducto}',
        subtitulo:
            '${precio.comercioDetalle?.nombre ?? 'Comercio #${precio.idComercio}'} · ${formatPrice(precio.precioEfectivo)}',
        badge: precio.enOferta ? 'Oferta' : null,
        colorBadge: AppColors.warning,
        leading: const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0x1A15803D),
          child: Icon(Icons.attach_money, size: 18, color: AppColors.success),
        ),
        onEditar: () => _abrirFormulario(context, precio: precio),
        onEliminar: () async {
          final nombre = precio.productoDetalle?.nombre ?? 'este precio';
          final confirmar = await confirmarEliminar(context, nombre);
          if (confirmar) {
            await ref.read(precioAdminProvider.notifier).eliminar(precio.id);
          }
        },
      ),
    );
  }

  void _abrirFormulario(BuildContext context, {Precio? precio}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrecioFormSheet(precio: precio),
    );
  }
}

class _ChipFiltro extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;

  const _ChipFiltro({
    required this.label,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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

class _PrecioFormSheet extends ConsumerStatefulWidget {
  final Precio? precio;
  const _PrecioFormSheet({this.precio});

  @override
  ConsumerState<_PrecioFormSheet> createState() => _PrecioFormSheetState();
}

class _PrecioFormSheetState extends ConsumerState<_PrecioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _precioActualCtrl;
  late final TextEditingController _precioOfertaCtrl;
  Producto? _productoSeleccionado;
  int? _idComercio;
  late bool _enOferta;

  bool get _esEdicion => widget.precio != null;

  @override
  void initState() {
    super.initState();
    final p = widget.precio;
    _precioActualCtrl =
        TextEditingController(text: p?.precioActual.toStringAsFixed(2) ?? '');
    _precioOfertaCtrl = TextEditingController(
        text: p?.precioOferta?.toStringAsFixed(2) ?? '');
    _productoSeleccionado = p?.productoDetalle;
    _idComercio = p?.idComercio;
    _enOferta = p?.enOferta ?? false;
  }

  @override
  void dispose() {
    _precioActualCtrl.dispose();
    _precioOfertaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardando = ref.watch(precioAdminProvider).guardando;
    final comercios = ref.watch(comercioAdminProvider).items;

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
                  _esEdicion ? 'Editar precio' : 'Nuevo precio',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Selector de producto por búsqueda
                GestureDetector(
                  onTap: _seleccionarProducto,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Producto'),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _productoSeleccionado?.nombre ??
                                'Toca para buscar un producto',
                            style: TextStyle(
                              color: _productoSeleccionado == null
                                  ? AppColors.textFaint
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const Icon(Icons.search, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<int>(
                  value: _idComercio,
                  decoration: const InputDecoration(labelText: 'Comercio'),
                  items: [
                    for (final c in comercios)
                      DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  ],
                  onChanged: (v) => setState(() => _idComercio = v),
                  validator: (v) => v == null ? 'Selecciona un comercio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _precioActualCtrl,
                  decoration: const InputDecoration(labelText: 'Precio actual'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Requerido';
                    if (double.tryParse(v.replaceAll(',', '.')) == null) {
                      return 'Número inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('En oferta'),
                  value: _enOferta,
                  onChanged: (v) => setState(() => _enOferta = v),
                ),
                if (_enOferta) ...[
                  TextFormField(
                    controller: _precioOfertaCtrl,
                    decoration:
                        const InputDecoration(labelText: 'Precio de oferta'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (!_enOferta) return null;
                      if (v == null || v.trim().isEmpty) {
                        return 'Requerido si está en oferta';
                      }
                      if (double.tryParse(v.replaceAll(',', '.')) == null) {
                        return 'Número inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 8),
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
                        : Text(_esEdicion ? 'Guardar cambios' : 'Crear precio'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarProducto() async {
    final producto = await showModalBottomSheet<Producto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _SelectorProductoSheet(),
    );
    if (producto != null) {
      setState(() => _productoSeleccionado = producto);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_productoSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un producto')),
      );
      return;
    }

    final precio = Precio(
      id: widget.precio?.id ?? 0,
      idProducto: _productoSeleccionado!.id,
      idComercio: _idComercio!,
      precioActual:
          double.parse(_precioActualCtrl.text.trim().replaceAll(',', '.')),
      precioOferta: _enOferta && _precioOfertaCtrl.text.trim().isNotEmpty
          ? double.parse(_precioOfertaCtrl.text.trim().replaceAll(',', '.'))
          : null,
      enOferta: _enOferta,
      precioEfectivo: widget.precio?.precioEfectivo ?? 0,
      fechaActualizacion: widget.precio?.fechaActualizacion ?? '',
      productoDetalle: _productoSeleccionado,
      comercioDetalle: widget.precio?.comercioDetalle,
    );

    final notifier = ref.read(precioAdminProvider.notifier);
    final ok = _esEdicion
        ? await notifier.actualizar(widget.precio!.id, precio)
        : await notifier.crear(precio);

    if (ok && mounted) Navigator.of(context).pop();
  }
}

/// Buscador modal de productos (para elegir el producto de un precio,
/// sin necesidad de cargar miles de productos en un dropdown).
class _SelectorProductoSheet extends StatefulWidget {
  const _SelectorProductoSheet();

  @override
  State<_SelectorProductoSheet> createState() =>
      _SelectorProductoSheetState();
}

class _SelectorProductoSheetState extends State<_SelectorProductoSheet> {
  final _datasource = ProductoAdminDatasource();
  final _buscarCtrl = TextEditingController();
  List<Producto> _resultados = [];
  bool _cargando = false;

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  Future<void> _buscar(String texto) async {
    setState(() => _cargando = true);
    try {
      final pagina = await _datasource.listar(buscar: texto);
      setState(() {
        _resultados = pagina.results;
        _cargando = false;
      });
    } catch (_) {
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buscar producto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _buscarCtrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Nombre o marca...',
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              onSubmitted: _buscar,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _resultados.isEmpty
                      ? const Center(
                          child: Text(
                            'Escribe y presiona buscar para ver resultados.',
                            style: TextStyle(color: AppColors.textFaint),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _resultados.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final p = _resultados[index];
                            return ListTile(
                              title: Text(p.nombre),
                              subtitle: Text(p.marca.isEmpty
                                  ? p.unidadMedida
                                  : '${p.marca} · ${p.unidadMedida}'),
                              onTap: () => Navigator.of(context).pop(p),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
