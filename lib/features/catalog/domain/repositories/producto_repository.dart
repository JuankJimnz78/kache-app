// lib/features/catalog/domain/repositories/producto_repository.dart

import '../models/producto.dart';

abstract class ProductoRepository {
  Future<PaginatedProductos> listar(
      {String? tipo, String? buscar, int? categoria});
}
