// lib/features/precios/data/datasources/precio_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:kache/data/remote/api/dio_client.dart';
import 'package:kache/core/error/api_exception.dart';
import 'package:kache/domain/model/precio.dart';

class PrecioRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<PaginatedPrecios> listarPorProducto(int idProducto) async {
    try {
      final response = await _dio.get('/kache/precios/', queryParameters: {
        'producto': idProducto,
      });
      return PaginatedPrecios.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (_) {
      throw const ApiException('No se pudieron cargar los precios.');
    }
  }
}
