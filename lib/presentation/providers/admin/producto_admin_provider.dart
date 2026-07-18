// lib/presentation/providers/admin/producto_admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/data/remote/admin/producto_admin_datasource.dart';
import 'package:kache/domain/model/producto.dart';
import 'package:kache/domain/model/paginado.dart';
import 'package:kache/presentation/providers/admin/admin_list_base.dart';

class ProductoAdminNotifier extends AdminListNotifier<Producto> {
  final _datasource = ProductoAdminDatasource();

  String? filtroBuscar;
  int? filtroIdCategoria;

  @override
  Future<Paginado<Producto>> fetchPage(int page) {
    return _datasource.listar(
      page: page,
      buscar: filtroBuscar,
      idCategoria: filtroIdCategoria,
    );
  }

  @override
  Future<Producto> crearItem(Producto item) => _datasource.crear(item);

  @override
  Future<Producto> actualizarItem(int id, Producto item) =>
      _datasource.actualizar(id, item);

  @override
  Future<void> eliminarItem(int id) => _datasource.eliminar(id);

  @override
  int idDe(Producto item) => item.id;

  void establecerFiltros({String? buscar, int? idCategoria}) {
    filtroBuscar = buscar;
    filtroIdCategoria = idCategoria;
    cargar();
  }
}

final productoAdminProvider =
    StateNotifierProvider.autoDispose<ProductoAdminNotifier, AdminListState<Producto>>(
  (ref) => ProductoAdminNotifier()..cargar(),
);
