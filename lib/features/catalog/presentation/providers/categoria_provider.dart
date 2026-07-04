// lib/features/catalog/presentation/providers/categoria_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/categoria_remote_datasource.dart';
import '../../domain/models/categoria.dart';

final categoriasProvider = FutureProvider<List<Categoria>>((ref) async {
  return CategoriaRemoteDatasource().listar();
});

/// Subcategorías filtradas por nombre de categoría padre
final subcategoriasProvider =
    FutureProvider.family<List<Categoria>, int>((ref, idPadre) async {
  final todas = await ref.watch(categoriasProvider.future);
  return todas.where((c) => c.categoriaPadre == idPadre).toList();
});
