// lib/data/remote/admin/producto_admin_datasource.dart

import 'package:dio/dio.dart';
import 'package:kache/data/remote/api/dio_client.dart';
import 'package:kache/core/error/api_exception.dart';
import 'package:kache/domain/model/producto.dart';
import 'package:kache/domain/model/paginado.dart';

class ProductoAdminDatasource {
  final Dio _dio = DioClient.instance;

  Future<Paginado<Producto>> listar({
    int page = 1,
    String? buscar,
    int? idCategoria,
  }) async {
    try {
      final response = await _dio.get('/kache/productos/', queryParameters: {
        'page': page,
        if (buscar != null && buscar.isNotEmpty) 'buscar': buscar,
        if (idCategoria != null) 'categoria': idCategoria,
      });
      return Paginado.fromJson(
        response.data as Map<String, dynamic>,
        (j) => Producto.fromJson(j),
      );
    } on DioException catch (e) {
      throw ApiException(
        _mensajeError(e, 'No se pudieron cargar los productos.'),
      );
    }
  }

  Future<Producto> crear(Producto producto) async {
    try {
      final response =
          await _dio.post('/kache/productos/', data: producto.toJson());
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo crear el producto.'));
    }
  }

  Future<Producto> actualizar(int id, Producto producto) async {
    try {
      final response = await _dio.patch('/kache/productos/$id/',
          data: producto.toJson());
      return Producto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
          _mensajeError(e, 'No se pudo actualizar el producto.'));
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/kache/productos/$id/');
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo eliminar el producto.'));
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
