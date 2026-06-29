// lib/features/precios/domain/repositories/precio_repository.dart

import '../models/precio.dart';

abstract class PrecioRepository {
  Future<List<Precio>> listarPorProducto(int idProducto);
}
