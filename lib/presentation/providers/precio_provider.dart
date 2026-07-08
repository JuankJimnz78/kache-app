// lib/features/precios/presentation/providers/precio_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/data/remote/dto/precio_dto.dart';
import 'package:kache/data/repository/precio_repository_impl.dart';
import 'package:kache/domain/model/precio.dart';
import 'package:kache/domain/repository/precio_repository.dart';

final precioRepositoryProvider = Provider<PrecioRepository>((ref) {
  return PrecioRepositoryImpl(PrecioRemoteDatasource());
});

/// El backend ya devuelve los precios ordenados del más barato al más caro,
/// así que el primer elemento de la lista siempre es la mejor opción.
final preciosPorProductoProvider =
    FutureProvider.family<List<Precio>, int>((ref, idProducto) async {
  return ref.read(precioRepositoryProvider).listarPorProducto(idProducto);
});
