// lib/features/precios/presentation/providers/comparador_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/comparador_remote_datasource.dart';
import '../../domain/models/lista_comparacion.dart';

class ComparadorState {
  final int? listaId;
  final ListaComparacionDetalle? detalle;
  final bool cargando;
  final String? error;

  const ComparadorState(
      {this.listaId, this.detalle, this.cargando = false, this.error});

  ComparadorState copyWith(
          {int? listaId,
          ListaComparacionDetalle? detalle,
          bool? cargando,
          String? error}) =>
      ComparadorState(
        listaId: listaId ?? this.listaId,
        detalle: detalle ?? this.detalle,
        cargando: cargando ?? this.cargando,
        error: error,
      );
}

class ComparadorNotifier extends StateNotifier<ComparadorState> {
  final ComparadorRemoteDatasource _ds;
  ComparadorNotifier(this._ds) : super(const ComparadorState());

  Future<int> _asegurarListaActiva() async {
    if (state.listaId != null) return state.listaId!;
    final listas = await _ds.listarListas();
    if (listas.isNotEmpty) {
      state = state.copyWith(listaId: listas.first.id);
      return listas.first.id;
    }
    final nueva = await _ds.crearLista();
    state = state.copyWith(listaId: nueva.id, detalle: nueva);
    return nueva.id;
  }

  Future<void> agregarProducto(int idProducto, int idComercio) async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final listaId = await _asegurarListaActiva();
      await _ds.agregarItem(listaId, idProducto, idComercio);
      final detalle = await _ds.obtenerLista(listaId);
      state = state.copyWith(detalle: detalle, cargando: false);
    } catch (_) {
      state = state.copyWith(
          cargando: false, error: 'No se pudo agregar a la comparación.');
    }
  }

  Future<void> cargarListaActiva() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final listaId = await _asegurarListaActiva();
      final detalle = await _ds.obtenerLista(listaId);
      state = state.copyWith(detalle: detalle, cargando: false);
    } catch (_) {
      state =
          state.copyWith(cargando: false, error: 'No se pudo cargar la lista.');
    }
  }

  Future<void> eliminarItem(int itemId) async {
    try {
      await _ds.eliminarItem(itemId);
      if (state.listaId != null) {
        final detalle = await _ds.obtenerLista(state.listaId!);
        state = state.copyWith(detalle: detalle);
      }
    } catch (_) {}
  }
}

final comparadorProvider =
    StateNotifierProvider<ComparadorNotifier, ComparadorState>((ref) {
  return ComparadorNotifier(ComparadorRemoteDatasource());
});
