// lib/presentation/screens/admin/comercios_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/domain/model/comercio.dart';
import 'package:kache/presentation/providers/admin/comercio_admin_provider.dart';
import 'package:kache/presentation/screens/admin/widgets/admin_list_scaffold.dart';
import 'package:kache/theme/app_colors.dart';

class ComerciosAdminScreen extends ConsumerStatefulWidget {
  const ComerciosAdminScreen({super.key});

  @override
  ConsumerState<ComerciosAdminScreen> createState() =>
      _ComerciosAdminScreenState();
}

class _ComerciosAdminScreenState extends ConsumerState<ComerciosAdminScreen> {
  String? _filtroTipo;
  bool? _filtroActivo;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(comercioAdminProvider);
    final notifier = ref.read(comercioAdminProvider.notifier);

    return AdminListScaffold<Comercio>(
      state: state,
      onRefrescar: notifier.cargar,
      onCargarMas: notifier.cargarMas,
      etiquetaVacio: 'No hay comercios registrados.',
      iconoVacio: Icons.storefront_outlined,
      onAgregar: () => _abrirFormulario(context, ref),
      barraFiltros: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _ChipFiltro(
            label: 'Todos',
            seleccionado: _filtroTipo == null,
            onTap: () => _cambiarTipo(notifier, null),
          ),
          for (final t in TipoComercio.values)
            _ChipFiltro(
              label: t.label,
              seleccionado: _filtroTipo == t.value,
              onTap: () => _cambiarTipo(notifier, t.value),
            ),
          _ChipFiltro(
            label: 'Solo activos',
            seleccionado: _filtroActivo == true,
            onTap: () => _alternarSoloActivos(notifier),
          ),
        ],
      ),
      itemBuilder: (context, comercio) => AdminItemCard(
        titulo: comercio.nombre,
        subtitulo: comercio.sitioWeb ?? 'Sin sitio web',
        badge: comercio.activo ? 'Activo' : 'Inactivo',
        colorBadge: comercio.activo ? AppColors.success : AppColors.error,
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: comercio.tipo.color.withValues(alpha: 0.25),
          child: Text(comercio.tipo.emoji, style: const TextStyle(fontSize: 16)),
        ),
        onEditar: () => _abrirFormulario(context, ref, comercio: comercio),
        onEliminar: () async {
          final confirmar = await confirmarEliminar(context, comercio.nombre);
          if (confirmar) {
            await ref.read(comercioAdminProvider.notifier).eliminar(comercio.id);
          }
        },
      ),
    );
  }

  void _cambiarTipo(ComercioAdminNotifier notifier, String? tipo) {
    setState(() => _filtroTipo = tipo);
    notifier.establecerFiltros(tipo: _filtroTipo, activo: _filtroActivo);
  }

  void _alternarSoloActivos(ComercioAdminNotifier notifier) {
    setState(() => _filtroActivo = (_filtroActivo == true) ? null : true);
    notifier.establecerFiltros(tipo: _filtroTipo, activo: _filtroActivo);
  }

  void _abrirFormulario(BuildContext context, WidgetRef ref, {Comercio? comercio}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComercioFormSheet(comercio: comercio),
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

class _ComercioFormSheet extends ConsumerStatefulWidget {
  final Comercio? comercio;
  const _ComercioFormSheet({this.comercio});

  @override
  ConsumerState<_ComercioFormSheet> createState() => _ComercioFormSheetState();
}

class _ComercioFormSheetState extends ConsumerState<_ComercioFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _logoCtrl;
  late final TextEditingController _sitioCtrl;
  late TipoComercio _tipo;
  late bool _activo;
  late bool _destacado;

  bool get _esEdicion => widget.comercio != null;

  @override
  void initState() {
    super.initState();
    final c = widget.comercio;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _logoCtrl = TextEditingController(text: c?.logoUrl ?? '');
    _sitioCtrl = TextEditingController(text: c?.sitioWeb ?? '');
    _tipo = c?.tipo ?? TipoComercio.supermercado;
    _activo = c?.activo ?? true;
    _destacado = c?.destacado ?? false;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _logoCtrl.dispose();
    _sitioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardando = ref.watch(comercioAdminProvider).guardando;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
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
                  _esEdicion ? 'Editar comercio' : 'Nuevo comercio',
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
                DropdownButtonFormField<TipoComercio>(
                  value: _tipo,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: [
                    for (final t in TipoComercio.values)
                      DropdownMenuItem(value: t, child: Text(t.label)),
                  ],
                  onChanged: (v) => setState(() => _tipo = v!),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _logoCtrl,
                  decoration: const InputDecoration(labelText: 'URL del logo'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _sitioCtrl,
                  decoration: const InputDecoration(labelText: 'Sitio web'),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Activo'),
                  value: _activo,
                  onChanged: (v) => setState(() => _activo = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Destacado'),
                  value: _destacado,
                  onChanged: (v) => setState(() => _destacado = v),
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
                        : Text(_esEdicion ? 'Guardar cambios' : 'Crear comercio'),
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

    final comercio = Comercio(
      id: widget.comercio?.id ?? 0,
      nombre: _nombreCtrl.text.trim(),
      tipo: _tipo,
      logoUrl: _logoCtrl.text.trim().isEmpty ? null : _logoCtrl.text.trim(),
      sitioWeb: _sitioCtrl.text.trim().isEmpty ? null : _sitioCtrl.text.trim(),
      activo: _activo,
      destacado: _destacado,
      fechaFinDestacado: widget.comercio?.fechaFinDestacado,
      destacadoActivo: widget.comercio?.destacadoActivo ?? false,
    );

    final notifier = ref.read(comercioAdminProvider.notifier);
    final ok = _esEdicion
        ? await notifier.actualizar(widget.comercio!.id, comercio)
        : await notifier.crear(comercio);

    if (ok && mounted) Navigator.of(context).pop();
  }
}
