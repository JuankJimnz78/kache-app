// lib/data/remote/admin/categoria_admin_datasource.dart

import 'package:dio/dio.dart';
import 'package:kache/data/remote/api/dio_client.dart';
import 'package:kache/core/error/api_exception.dart';
import 'package:kache/domain/model/categoria.dart';
import 'package:kache/domain/model/paginado.dart';

class CategoriaAdminDatasource {
  final Dio _dio = DioClient.instance;

  Future<Paginado<Categoria>> listar({int page = 1}) async {
    try {
      final response = await _dio.get('/kache/categorias/', queryParameters: {
        'page': page,
      });
      return Paginado.fromJson(
        response.data as Map<String, dynamic>,
        (j) => Categoria.fromJson(j),
      );
    } on DioException catch (e) {
      throw ApiException(
        _mensajeError(e, 'No se pudieron cargar las categorías.'),
      );
    }
  }

  Future<Categoria> crear(Categoria categoria) async {
    try {
      final response =
          await _dio.post('/kache/categorias/', data: categoria.toJson());
      return Categoria.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo crear la categoría.'));
    }
  }

  Future<Categoria> actualizar(int id, Categoria categoria) async {
    try {
      final response = await _dio.patch('/kache/categorias/$id/',
          data: categoria.toJson());
      return Categoria.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
          _mensajeError(e, 'No se pudo actualizar la categoría.'));
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/kache/categorias/$id/');
    } on DioException catch (e) {
      throw ApiException(
          _mensajeError(e, 'No se pudo eliminar la categoría.'));
    }
  }

  String _mensajeError(DioException e, String fallback) {
    if (e.response?.statusCode == 403) {
      return 'No tienes permisos de administrador para esta acción.';
    }
    if (e.response?.data is Map) {
      final data = e.response!.data as Map;
      final primerError = data.values.isNotEmpty ? data.values.first : null;
      if (primerError is List && primerError.isNotEmpty) {
        return primerError.first.toString();
      }
    }
    return fallback;
  }
}
