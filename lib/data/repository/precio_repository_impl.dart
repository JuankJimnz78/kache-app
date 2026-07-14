// lib/features/precios/data/repositories/precio_repository_impl.dart

import 'package:kache/domain/model/precio.dart';
import 'package:kache/domain/repository/precio_repository.dart';
import 'package:kache/data/remote/dto/precio_dto.dart';

class PrecioRepositoryImpl implements PrecioRepository {
  final PrecioRemoteDatasource _remote;
  PrecioRepositoryImpl(this._remote);

  @override
  Future<List<Precio>> listarPorProducto(int idProducto) async {
    final resultado = await _remote.listarPorProducto(idProducto);
    return resultado.results;
  }
}
