// lib/features/catalog/data/repositories/producto_repository_impl.dart

import 'package:kache/domain/model/producto.dart';
import 'package:kache/domain/repository/catalog_repository.dart';
import 'package:kache/data/remote/dto/product_dto.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoRemoteDatasource _remote;
  ProductoRepositoryImpl(this._remote);

  @override
  Future<PaginatedProductos> listar(
      {String? tipo, String? buscar, int? categoria}) {
    return _remote.listar(tipo: tipo, buscar: buscar, categoria: categoria);
  }
}
