// lib/presentation/screens/admin/sucursales_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/domain/model/sucursal.dart';
import 'package:kache/presentation/providers/admin/comercio_admin_provider.dart';
import 'package:kache/presentation/providers/admin/sucursal_admin_provider.dart';
import 'package:kache/presentation/screens/admin/widgets/admin_list_scaffold.dart';
import 'package:kache/theme/app_colors.dart';

class SucursalesAdminScreen extends ConsumerStatefulWidget {
  const SucursalesAdminScreen({super.key});

  @override
  ConsumerState<SucursalesAdminScreen> createState() =>
      _SucursalesAdminScreenState();
}

class _SucursalesAdminScreenState
    extends ConsumerState<SucursalesAdminScreen> {
  final _ciudadCtrl = TextEditingController();

  @override
  void dispose() {
    _ciudadCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(sucursalAdminProvider);
    final notifier = ref.read(sucursalAdminProvider.notifier);

    return AdminListScaffold<Sucursal>(
      state: state,
      onRefrescar: notifier.cargar,
      onCargarMas: notifier.cargarMas,
      etiquetaVacio: 'No hay sucursales registradas.',
      iconoVacio: Icons.location_on_outlined,
      onAgregar: () => _abrirFormulario(context),
      barraFiltros: TextField(
        controller: _ciudadCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar por ciudad...',
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
          ciudad: v.trim().isEmpty ? null : v.trim(),
        ),
      ),
      itemBuilder: (context, sucursal) => AdminItemCard(
        titulo: sucursal.nombreSucursal,
        subtitulo:
            '${sucursal.comercioDetalle?.nombre ?? 'Comercio #${sucursal.idComercio}'} · ${sucursal.ciudad}',
        badge: sucursal.activo ? 'Activa' : 'Inactiva',
        colorBadge: sucursal.activo ? AppColors.success : AppColors.error,
        leading: const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0x1A1565C0),
          child: Icon(Icons.storefront, size: 18, color: Color(0xFF1565C0)),
        ),
        onEditar: () => _abrirFormulario(context, sucursal: sucursal),
        onEliminar: () async {
          final confirmar =
              await confirmarEliminar(context, sucursal.nombreSucursal);
          if (confirmar) {
            await ref
                .read(sucursalAdminProvider.notifier)
                .eliminar(sucursal.id);
          }
        },
      ),
    );
  }

  void _abrirFormulario(BuildContext context, {Sucursal? sucursal}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SucursalFormSheet(sucursal: sucursal),
    );
  }
}

class _SucursalFormSheet extends ConsumerStatefulWidget {
  final Sucursal? sucursal;
  const _SucursalFormSheet({this.sucursal});

  @override
  ConsumerState<_SucursalFormSheet> createState() =>
      _SucursalFormSheetState();
}

class _SucursalFormSheetState extends ConsumerState<_SucursalFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _ciudadCtrl;
  late final TextEditingController _direccionCtrl;
  int? _idComercio;
  late bool _activo;

  bool get _esEdicion => widget.sucursal != null;

  @override
  void initState() {
    super.initState();
    final s = widget.sucursal;
    _nombreCtrl = TextEditingController(text: s?.nombreSucursal ?? '');
    _ciudadCtrl = TextEditingController(text: s?.ciudad ?? '');
    _direccionCtrl = TextEditingController(text: s?.direccion ?? '');
    _idComercio = s?.idComercio;
    _activo = s?.activo ?? true;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _ciudadCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardando = ref.watch(sucursalAdminProvider).guardando;
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
                  _esEdicion ? 'Editar sucursal' : 'Nueva sucursal',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                  controller: _nombreCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Nombre de la sucursal'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _ciudadCtrl,
                  decoration: const InputDecoration(labelText: 'Ciudad'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccionCtrl,
                  decoration: const InputDecoration(labelText: 'Dirección'),
                  maxLines: 2,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Requerido' : null,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activa'),
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v),
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
                        : Text(_esEdicion ? 'Guardar cambios' : 'Crear sucursal'),
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

    final sucursal = Sucursal(
      id: widget.sucursal?.id ?? 0,
      idComercio: _idComercio!,
      nombreSucursal: _nombreCtrl.text.trim(),
      ciudad: _ciudadCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      activo: _activo,
      comercioDetalle: widget.sucursal?.comercioDetalle,
    );

    final notifier = ref.read(sucursalAdminProvider.notifier);
    final ok = _esEdicion
        ? await notifier.actualizar(widget.sucursal!.id, sucursal)
        : await notifier.crear(sucursal);

    if (ok && mounted) Navigator.of(context).pop();
  }
}
