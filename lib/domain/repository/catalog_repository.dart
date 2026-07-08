// lib/features/catalog/domain/repositories/producto_repository.dart

import 'package:kache/domain/model/producto.dart';

abstract class ProductoRepository {
  Future<PaginatedProductos> listar(
      {String? tipo, String? buscar, int? categoria});
}
