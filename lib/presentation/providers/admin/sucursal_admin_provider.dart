// lib/presentation/providers/admin/sucursal_admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/data/remote/admin/sucursal_admin_datasource.dart';
import 'package:kache/domain/model/sucursal.dart';
import 'package:kache/domain/model/paginado.dart';
import 'package:kache/presentation/providers/admin/admin_list_base.dart';

class SucursalAdminNotifier extends AdminListNotifier<Sucursal> {
  final _datasource = SucursalAdminDatasource();

  int? filtroIdComercio;
  String? filtroCiudad;

  @override
  Future<Paginado<Sucursal>> fetchPage(int page) {
    return _datasource.listar(
      page: page,
      idComercio: filtroIdComercio,
      ciudad: filtroCiudad,
    );
  }

  @override
  Future<Sucursal> crearItem(Sucursal item) => _datasource.crear(item);

  @override
  Future<Sucursal> actualizarItem(int id, Sucursal item) =>
      _datasource.actualizar(id, item);

  @override
  Future<void> eliminarItem(int id) => _datasource.eliminar(id);

  @override
  int idDe(Sucursal item) => item.id;

  void establecerFiltros({int? idComercio, String? ciudad}) {
    filtroIdComercio = idComercio;
    filtroCiudad = ciudad;
    cargar();
  }
}

final sucursalAdminProvider =
    StateNotifierProvider.autoDispose<SucursalAdminNotifier, AdminListState<Sucursal>>(
  (ref) => SucursalAdminNotifier()..cargar(),
);
