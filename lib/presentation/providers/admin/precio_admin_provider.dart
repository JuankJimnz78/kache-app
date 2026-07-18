// lib/presentation/providers/admin/precio_admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/data/remote/admin/precio_admin_datasource.dart';
import 'package:kache/domain/model/precio.dart';
import 'package:kache/domain/model/paginado.dart';
import 'package:kache/presentation/providers/admin/admin_list_base.dart';

class PrecioAdminNotifier extends AdminListNotifier<Precio> {
  final _datasource = PrecioAdminDatasource();

  int? filtroIdProducto;
  int? filtroIdComercio;
  bool? filtroEnOferta;

  @override
  Future<Paginado<Precio>> fetchPage(int page) {
    return _datasource.listar(
      page: page,
      idProducto: filtroIdProducto,
      idComercio: filtroIdComercio,
      enOferta: filtroEnOferta,
    );
  }

  @override
  Future<Precio> crearItem(Precio item) => _datasource.crear(item);

  @override
  Future<Precio> actualizarItem(int id, Precio item) =>
      _datasource.actualizar(id, item);

  @override
  Future<void> eliminarItem(int id) => _datasource.eliminar(id);

  @override
  int idDe(Precio item) => item.id;

  void establecerFiltros({int? idProducto, int? idComercio, bool? enOferta}) {
    filtroIdProducto = idProducto;
    filtroIdComercio = idComercio;
    filtroEnOferta = enOferta;
    cargar();
  }
}

final precioAdminProvider =
    StateNotifierProvider.autoDispose<PrecioAdminNotifier, AdminListState<Precio>>(
  (ref) => PrecioAdminNotifier()..cargar(),
);
