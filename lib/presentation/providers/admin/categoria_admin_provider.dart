// lib/presentation/providers/admin/categoria_admin_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kache/data/remote/admin/categoria_admin_datasource.dart';
import 'package:kache/domain/model/categoria.dart';
import 'package:kache/domain/model/paginado.dart';
import 'package:kache/presentation/providers/admin/admin_list_base.dart';

class CategoriaAdminNotifier extends AdminListNotifier<Categoria> {
  final _datasource = CategoriaAdminDatasource();

  @override
  Future<Paginado<Categoria>> fetchPage(int page) {
    return _datasource.listar(page: page);
  }

  @override
  Future<Categoria> crearItem(Categoria item) => _datasource.crear(item);

  @override
  Future<Categoria> actualizarItem(int id, Categoria item) =>
      _datasource.actualizar(id, item);

  @override
  Future<void> eliminarItem(int id) => _datasource.eliminar(id);

  @override
  int idDe(Categoria item) => item.id;
}

final categoriaAdminProvider =
    StateNotifierProvider.autoDispose<CategoriaAdminNotifier, AdminListState<Categoria>>(
  (ref) => CategoriaAdminNotifier()..cargar(),
);
