// lib/data/remote/admin/sucursal_admin_datasource.dart

import 'package:dio/dio.dart';
import 'package:kache/data/remote/api/dio_client.dart';
import 'package:kache/core/error/api_exception.dart';
import 'package:kache/domain/model/sucursal.dart';
import 'package:kache/domain/model/paginado.dart';

class SucursalAdminDatasource {
  final Dio _dio = DioClient.instance;

  Future<Paginado<Sucursal>> listar({
    int page = 1,
    int? idComercio,
    String? ciudad,
  }) async {
    try {
      final response = await _dio.get('/kache/sucursales/', queryParameters: {
        'page': page,
        if (idComercio != null) 'comercio': idComercio,
        if (ciudad != null && ciudad.isNotEmpty) 'ciudad': ciudad,
      });
      return Paginado.fromJson(
        response.data as Map<String, dynamic>,
        (j) => Sucursal.fromJson(j),
      );
    } on DioException catch (e) {
      throw ApiException(
        _mensajeError(e, 'No se pudieron cargar las sucursales.'),
      );
    }
  }

  Future<Sucursal> crear(Sucursal sucursal) async {
    try {
      final response =
          await _dio.post('/kache/sucursales/', data: sucursal.toJson());
      return Sucursal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(_mensajeError(e, 'No se pudo crear la sucursal.'));
    }
  }

  Future<Sucursal> actualizar(int id, Sucursal sucursal) async {
    try {
      final response = await _dio.patch('/kache/sucursales/$id/',
          data: sucursal.toJson());
      return Sucursal.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
          _mensajeError(e, 'No se pudo actualizar la sucursal.'));
    }
  }

  Future<void> eliminar(int id) async {
    try {
      await _dio.delete('/kache/sucursales/$id/');
    } on DioException catch (e) {
      throw ApiException(
          _mensajeError(e, 'No se pudo eliminar la sucursal.'));
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
