// lib/features/catalog/data/datasources/producto_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../domain/models/producto.dart';

class ProductoRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<PaginatedProductos> listar(
      {String? tipo, String? buscar, int? categoria}) async {
    try {
      final response = await _dio.get('/kache/productos/', queryParameters: {
        if (tipo != null) 'tipo': tipo,
        if (buscar != null && buscar.isNotEmpty) 'buscar': buscar,
        if (categoria != null) 'categoria': categoria,
      });
      return PaginatedProductos.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        'Error de red: ${e.type} | status: ${e.response?.statusCode} | ${e.message}',
      );
    }
  }
}
