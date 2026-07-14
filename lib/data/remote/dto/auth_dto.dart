// lib/features/auth/data/datasources/auth_remote_datasource.dart

import 'package:dio/dio.dart';
import 'package:kache/data/remote/api/dio_client.dart';
import 'package:kache/core/error/api_exception.dart';

class AuthRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login/', data: {
        'username': username,
        'password': password,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      final data = e.response?.data;
      final detail = (data is Map && data['detail'] != null)
          ? data['detail'].toString()
          : 'No se pudo iniciar sesión.';
      throw ApiException(detail, statusCode: e.response?.statusCode);
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await _dio.post('/auth/register/', data: {
        'username': username,
        'email': email,
        'password': password,
        'password2': password2,
      });
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ApiException(_extraerErrorRegistro(e),
          statusCode: e.response?.statusCode);
    }
  }

  /// El backend devuelve errores por campo, ej: {"username": ["Este nombre ya existe."]}
  String _extraerErrorRegistro(DioException e) {
    final data = e.response?.data;
    if (data is Map && data.isNotEmpty) {
      final primerError = data.values.first;
      if (primerError is List && primerError.isNotEmpty) {
        return primerError.first.toString();
      }
      if (data['detail'] != null) return data['detail'].toString();
    }
    return 'No se pudo crear la cuenta.';
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post('/auth/logout/', data: {'refresh': refreshToken});
    } catch (_) {
      // Si falla el logout remoto, igual cerramos sesión localmente.
    }
  }
}
