// lib/presentation/providers/admin/admin_list_base.dart
//
// Base genérica para el estado y la lógica de las listas del panel admin:
// paginación (cargar más), CRUD optimista y manejo de error, compartida
// por comercios, sucursales, categorías, productos y precios.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/domain/model/paginado.dart';

class AdminListState<T> {
  final List<T> items;
  final bool cargando;
  final bool cargandoMas;
  final bool guardando;
  final bool hayMas;
  final int pagina;
  final int total;
  final String? error;

  const AdminListState({
    this.items = const [],
    this.cargando = false,
    this.cargandoMas = false,
    this.guardando = false,
    this.hayMas = false,
    this.pagina = 1,
    this.total = 0,
    this.error,
  });

  AdminListState<T> copyWith({
    List<T>? items,
    bool? cargando,
    bool? cargandoMas,
    bool? guardando,
    bool? hayMas,
    int? pagina,
    int? total,
    String? error,
    bool limpiarError = false,
  }) {
    return AdminListState<T>(
      items: items ?? this.items,
      cargando: cargando ?? this.cargando,
      cargandoMas: cargandoMas ?? this.cargandoMas,
      guardando: guardando ?? this.guardando,
      hayMas: hayMas ?? this.hayMas,
      pagina: pagina ?? this.pagina,
      total: total ?? this.total,
      error: limpiarError ? null : (error ?? this.error),
    );
  }
}

abstract class AdminListNotifier<T> extends StateNotifier<AdminListState<T>> {
  AdminListNotifier() : super(const AdminListState());

  /// Trae una página específica desde la API con los filtros vigentes.
  Future<Paginado<T>> fetchPage(int page);

  /// Crea un registro nuevo en la API.
  Future<T> crearItem(T item);

  /// Actualiza (PATCH) un registro existente.
  Future<T> actualizarItem(int id, T item);

  /// Elimina un registro.
  Future<void> eliminarItem(int id);

  /// Identificador único del item, usado para localizarlo tras editar/eliminar.
  int idDe(T item);

  Future<void> cargar() async {
    state = state.copyWith(cargando: true, limpiarError: true);
    try {
      final resultado = await fetchPage(1);
      state = AdminListState<T>(
        items: resultado.results,
        hayMas: resultado.haySiguiente,
        pagina: 1,
        total: resultado.count,
      );
    } catch (e) {
      state = state.copyWith(cargando: false, error: e.toString());
    }
  }

  Future<void> cargarMas() async {
    if (state.cargandoMas || !state.hayMas) return;
    state = state.copyWith(cargandoMas: true, limpiarError: true);
    try {
      final siguiente = state.pagina + 1;
      final resultado = await fetchPage(siguiente);
      state = state.copyWith(
        items: [...state.items, ...resultado.results],
        cargandoMas: false,
        hayMas: resultado.haySiguiente,
        pagina: siguiente,
      );
    } catch (e) {
      state = state.copyWith(cargandoMas: false, error: e.toString());
    }
  }

  Future<bool> crear(T item) async {
    state = state.copyWith(guardando: true, limpiarError: true);
    try {
      await crearItem(item);
      await cargar();
      return true;
    } catch (e) {
      state = state.copyWith(guardando: false, error: e.toString());
      return false;
    }
  }

  Future<bool> actualizar(int id, T item) async {
    state = state.copyWith(guardando: true, limpiarError: true);
    try {
      final actualizado = await actualizarItem(id, item);
      state = state.copyWith(
        guardando: false,
        items: [
          for (final it in state.items) idDe(it) == id ? actualizado : it,
        ],
      );
      return true;
    } catch (e) {
      state = state.copyWith(guardando: false, error: e.toString());
      return false;
    }
  }

  Future<bool> eliminar(int id) async {
    state = state.copyWith(guardando: true, limpiarError: true);
    try {
      await eliminarItem(id);
      state = state.copyWith(
        guardando: false,
        items: state.items.where((it) => idDe(it) != id).toList(),
        total: state.total > 0 ? state.total - 1 : 0,
      );
      return true;
    } catch (e) {
      state = state.copyWith(guardando: false, error: e.toString());
      return false;
    }
  }

  void limpiarError() => state = state.copyWith(limpiarError: true);
}
