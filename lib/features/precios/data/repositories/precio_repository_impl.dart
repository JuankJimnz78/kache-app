// lib/features/precios/data/repositories/precio_repository_impl.dart

import '../../domain/models/precio.dart';
import '../../domain/repositories/precio_repository.dart';
import '../datasources/precio_remote_datasource.dart';

class PrecioRepositoryImpl implements PrecioRepository {
  final PrecioRemoteDatasource _remote;
  PrecioRepositoryImpl(this._remote);

  @override
  Future<List<Precio>> listarPorProducto(int idProducto) async {
    final resultado = await _remote.listarPorProducto(idProducto);
    return resultado.results;
  }
}
