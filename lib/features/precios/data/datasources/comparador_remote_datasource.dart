// lib/features/precios/data/datasources/comparador_remote_datasource.dart

import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../domain/models/lista_comparacion.dart';

class ComparadorRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<List<ListaComparacionResumen>> listarListas() async {
    final response = await _dio.get('/kache/listas-comparacion/');
    final data = response.data as Map<String, dynamic>;
    return (data['results'] as List)
        .map((e) => ListaComparacionResumen.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ListaComparacionDetalle> crearLista(
      {String nombre = 'Mi comparación'}) async {
    final response =
        await _dio.post('/kache/listas-comparacion/', data: {'nombre': nombre});
    return ListaComparacionDetalle.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<ListaComparacionDetalle> obtenerLista(int id) async {
    final response = await _dio.get('/kache/listas-comparacion/$id/');
    return ListaComparacionDetalle.fromJson(
        response.data as Map<String, dynamic>);
  }

  Future<void> agregarItem(int listaId, int idProducto, int idComercio) async {
    await _dio.post('/kache/listas-comparacion/$listaId/items/', data: {
      'id_producto': idProducto,
      'id_comercio': idComercio,
    });
  }

  Future<void> eliminarItem(int itemId) async {
    await _dio.delete('/kache/items-comparacion/$itemId/');
  }
}
