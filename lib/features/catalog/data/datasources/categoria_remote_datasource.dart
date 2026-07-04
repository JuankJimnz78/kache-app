// lib/features/catalog/data/datasources/categoria_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/api/api_exception.dart';
import '../../domain/models/categoria.dart';

class CategoriaRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<List<Categoria>> listar() async {
    try {
      final response = await _dio.get('/kache/categorias/');
      final data = response.data as Map<String, dynamic>;
      final lista = data['results'] ?? data['resultados'];
      return (lista as List)
          .map((e) => Categoria.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      throw const ApiException('No se pudieron cargar las categorías.');
    }
  }
}
