// lib/features/catalog/presentation/providers/catalog_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/producto_remote_datasource.dart';
import '../../data/repositories/producto_repository_impl.dart';
import '../../domain/models/producto.dart';
import '../../domain/repositories/producto_repository.dart';

final productoRepositoryProvider = Provider<ProductoRepository>((ref) {
  return ProductoRepositoryImpl(ProductoRemoteDatasource());
});

class CatalogState {
  final List<Producto> productos;
  final bool cargando;
  final String? error;
  final String busqueda;

  const CatalogState({
    this.productos = const [],
    this.cargando = false,
    this.error,
    this.busqueda = '',
  });

  CatalogState copyWith(
          {List<Producto>? productos,
          bool? cargando,
          String? error,
          String? busqueda}) =>
      CatalogState(
        productos: productos ?? this.productos,
        cargando: cargando ?? this.cargando,
        error: error,
        busqueda: busqueda ?? this.busqueda,
      );
}

class CatalogNotifier extends StateNotifier<CatalogState> {
  final ProductoRepository _repository;
  final String tipoComercio;
  Timer? _debounce;

  CatalogNotifier(this._repository, this.tipoComercio)
      : super(const CatalogState()) {
    cargar();
  }

  Future<void> cargar() async {
    state = state.copyWith(cargando: true, error: null);
    try {
      final partes = tipoComercio.split('_');
      final tipo = partes[0];
      final idCategoria = partes.length > 1 ? int.tryParse(partes[1]) : null;

      final resultado = await _repository.listar(
        tipo: tipo,
        buscar: state.busqueda.isEmpty ? null : state.busqueda,
        categoria: idCategoria,
      );
      state = state.copyWith(productos: resultado.results, cargando: false);
    } catch (e) {
      state = state.copyWith(
          cargando: false, error: 'No se pudo cargar el catálogo: $e');
    }
  }

  void buscar(String texto) {
    state = state.copyWith(busqueda: texto);
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), cargar);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

final catalogProvider =
    StateNotifierProvider.family<CatalogNotifier, CatalogState, String>(
  (ref, tipoComercio) =>
      CatalogNotifier(ref.watch(productoRepositoryProvider), tipoComercio),
);
