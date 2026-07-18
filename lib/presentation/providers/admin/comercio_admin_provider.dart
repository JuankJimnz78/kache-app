// lib/presentation/providers/admin/comercio_admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/data/remote/admin/comercio_admin_datasource.dart';
import 'package:kache/domain/model/comercio.dart';
import 'package:kache/domain/model/paginado.dart';
import 'package:kache/presentation/providers/admin/admin_list_base.dart';

class ComercioAdminNotifier extends AdminListNotifier<Comercio> {
  final _datasource = ComercioAdminDatasource();

  String? filtroTipo;
  bool? filtroActivo;

  @override
  Future<Paginado<Comercio>> fetchPage(int page) {
    return _datasource.listar(
      page: page,
      tipo: filtroTipo,
      activo: filtroActivo,
    );
  }

  @override
  Future<Comercio> crearItem(Comercio item) => _datasource.crear(item);

  @override
  Future<Comercio> actualizarItem(int id, Comercio item) =>
      _datasource.actualizar(id, item);

  @override
  Future<void> eliminarItem(int id) => _datasource.eliminar(id);

  @override
  int idDe(Comercio item) => item.id;

  void establecerFiltros({String? tipo, bool? activo}) {
    filtroTipo = tipo;
    filtroActivo = activo;
    cargar();
  }
}

final comercioAdminProvider =
    StateNotifierProvider.autoDispose<ComercioAdminNotifier, AdminListState<Comercio>>(
  (ref) => ComercioAdminNotifier()..cargar(),
);
