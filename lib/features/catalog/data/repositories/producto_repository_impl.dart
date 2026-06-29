// lib/features/catalog/data/repositories/producto_repository_impl.dart

import '../../domain/models/producto.dart';
import '../../domain/repositories/producto_repository.dart';
import '../datasources/producto_remote_datasource.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoRemoteDatasource _remote;
  ProductoRepositoryImpl(this._remote);

  @override
  Future<PaginatedProductos> listar(
      {String? tipo, String? buscar, int? categoria}) {
    return _remote.listar(tipo: tipo, buscar: buscar, categoria: categoria);
  }
}
