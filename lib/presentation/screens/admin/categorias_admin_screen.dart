// lib/presentation/screens/admin/categorias_admin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/domain/model/categoria.dart';
import 'package:kache/presentation/providers/admin/categoria_admin_provider.dart';
import 'package:kache/presentation/screens/admin/widgets/admin_list_scaffold.dart';
import 'package:kache/theme/app_colors.dart';

class CategoriasAdminScreen extends ConsumerWidget {
  const CategoriasAdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoriaAdminProvider);
    final notifier = ref.read(categoriaAdminProvider.notifier);

    return AdminListScaffold<Categoria>(
      state: state,
      onRefrescar: notifier.cargar,
      onCargarMas: notifier.cargarMas,
      etiquetaVacio: 'No hay categorías registradas.',
      iconoVacio: Icons.category_outlined,
      onAgregar: () => _abrirFormulario(context),
      itemBuilder: (context, categoria) => AdminItemCard(
        titulo: categoria.nombre,
        subtitulo: categoria.descripcion.isEmpty
            ? 'Sin descripción'
            : categoria.descripcion,
        badge: categoria.categoriaPadre != null ? 'Subcategoría' : null,
        leading: const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0x1A6A1B9A),
          child: Icon(Icons.category, size: 18, color: Color(0xFF6A1B9A)),
        ),
        onEditar: () => _abrirFormulario(context, categoria: categoria),
        onEliminar: () async {
          final confirmar = await confirmarEliminar(context, categoria.nombre);
          if (confirmar) {
            await ref
                .read(categoriaAdminProvider.notifier)
                .eliminar(categoria.id);
          }
        },
      ),
    );
  }

  void _abrirFormulario(BuildContext context, {Categoria? categoria}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CategoriaFormSheet(categoria: categoria),
    );
  }
}

class _CategoriaFormSheet extends ConsumerStatefulWidget {
  final Categoria? categoria;
  const _CategoriaFormSheet({this.categoria});

  @override
  ConsumerState<_CategoriaFormSheet> createState() =>
      _CategoriaFormSheetState();
}

class _CategoriaFormSheetState extends ConsumerState<_CategoriaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _descripcionCtrl;
  int? _categoriaPadre;

  bool get _esEdicion => widget.categoria != null;

  @override
  void initState() {
    super.initState();
    final c = widget.categoria;
    _nombreCtrl = TextEditingController(text: c?.nombre ?? '');
    _descripcionCtrl = TextEditingController(text: c?.descripcion ?? '');
    _categoriaPadre = c?.categoriaPadre;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final guardando = ref.watch(categoriaAdminProvider).guardando;
    final categorias = ref.watch(categoriaAdminProvider).items
        .where((c) => c.id != widget.categoria?.id)
        .toList();

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
                  _esEdicion ? 'Editar categoría' : 'Nueva categoría',
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
                  controller: _descripcionCtrl,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  value: _categoriaPadre,
                  decoration: const InputDecoration(
                    labelText: 'Categoría padre (opcional)',
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Ninguna')),
                    for (final c in categorias)
                      DropdownMenuItem(value: c.id, child: Text(c.nombre)),
                  ],
                  onChanged: (v) => setState(() => _categoriaPadre = v),
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
                        : Text(_esEdicion ? 'Guardar cambios' : 'Crear categoría'),
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

    final categoria = Categoria(
      id: widget.categoria?.id ?? 0,
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      categoriaPadre: _categoriaPadre,
    );

    final notifier = ref.read(categoriaAdminProvider.notifier);
    final ok = _esEdicion
        ? await notifier.actualizar(widget.categoria!.id, categoria)
        : await notifier.crear(categoria);

    if (ok && mounted) Navigator.of(context).pop();
  }
}
