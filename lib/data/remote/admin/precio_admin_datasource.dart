// lib/data/remote/admin/precio_admin_datasource.dart

import 'package:dio/dio.dart';
import 'package:kache/data/remote/api/dio_client.dart';
import 'package:kache/core/error/api_exception.dart';
import 'package:kache/domain/model/precio.dart';
import 'package:kache/domain/model/paginado.dart';

class PrecioAdminDatasource {
  final Dio _dio = DioClient.instance;

  Future<Paginado<Precio>> listar({
    int page = 1,
    int? idProducto,
    int? idComercio,
    bool? enOferta,
  }) async {
    try {
      final response = await _dio.get('/kache/precios/', queryParameters: {
        'page': page,
        if (idProducto != null) 'producto': idProducto,
        if (idComercio != null) 'comercio': idComercio,
        if (enOferta != null) 'en_oferta': enOferta,
      });
      return Paginado.fromJson(
        response.data as Map<String, dynamic>,
        (j) => Precio.fromJson(j),
      );
    } on DioException catch (e) {
      throw ApiException(
        _mensajeError(e, 'No se pudieron cargar los precios.'),
      );
    }
  }

  Future<Precio> crear(Precio precio) async {
    try {
      final response =
          await _dio.post('/kache/precios/', data: precio.toJson());
      return Precio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo crear el precio.'));
    }
  }

  Future<Precio> actualizar(int id, Precio precio) async {
    try {
      final response =
          await _dio.patch('/kache/precios/$id/', data: precio.toJson());
      return Precio.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo actualizar el precio.'));
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/kache/precios/$id/');
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo eliminar el precio.'));
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
