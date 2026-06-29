// lib/features/precios/presentation/providers/precio_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/precio_remote_datasource.dart';
import '../../data/repositories/precio_repository_impl.dart';
import '../../domain/models/precio.dart';
import '../../domain/repositories/precio_repository.dart';

final precioRepositoryProvider = Provider<PrecioRepository>((ref) {
  return PrecioRepositoryImpl(PrecioRemoteDatasource());
});

/// El backend ya devuelve los precios ordenados del más barato al más caro,
/// así que el primer elemento de la lista siempre es la mejor opción.
final preciosPorProductoProvider =
    FutureProvider.family<List<Precio>, int>((ref, idProducto) async {
  return ref.read(precioRepositoryProvider).listarPorProducto(idProducto);
});
