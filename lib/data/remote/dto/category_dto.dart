// lib/features/catalog/data/datasources/categoria_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:kache/data/remote/api/dio_client.dart';
import 'package:kache/core/error/api_exception.dart';
import 'package:kache/domain/model/categoria.dart';

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
