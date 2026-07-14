// lib/features/precios/domain/repositories/precio_repository.dart

import 'package:kache/domain/model/precio.dart';

abstract class PrecioRepository {
  Future<List<Precio>> listarPorProducto(int idProducto);
}
