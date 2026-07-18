// lib/data/remote/admin/comercio_admin_datasource.dart

import 'package:dio/dio.dart';
import 'package:kache/data/remote/api/dio_client.dart';
import 'package:kache/core/error/api_exception.dart';
import 'package:kache/domain/model/comercio.dart';
import 'package:kache/domain/model/paginado.dart';

class ComercioAdminDatasource {
  final Dio _dio = DioClient.instance;

  Future<Paginado<Comercio>> listar({
    int page = 1,
    String? tipo,
    bool? activo,
  }) async {
    try {
      final response = await _dio.get('/kache/comercios/', queryParameters: {
        'page': page,
        if (tipo != null && tipo.isNotEmpty) 'tipo': tipo,
        if (activo != null) 'activo': activo,
      });
      return Paginado.fromJson(
        response.data as Map<String, dynamic>,
        (j) => Comercio.fromJson(j),
      );
    } on DioException catch (e) {
      throw ApiException(
        _mensajeError(e, 'No se pudieron cargar los comercios.'),
      );
    }
  }

  Future<Comercio> crear(Comercio comercio) async {
    try {
      final response =
          await _dio.post('/kache/comercios/', data: comercio.toJson());
      return Comercio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo crear el comercio.'));
    }
  }

  Future<Comercio> actualizar(int id, Comercio comercio) async {
    try {
      final response = await _dio.patch('/kache/comercios/$id/',
          data: comercio.toJson());
      return Comercio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
          _mensajeError(e, 'No se pudo actualizar el comercio.'));
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/kache/comercios/$id/');
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo eliminar el comercio.'));
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
