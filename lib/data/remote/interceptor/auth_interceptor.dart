// lib/data/remote/interceptor/auth_interceptor.dart

import 'package:dio/dio.dart';
import 'package:kache/data/local/secure_storage.dart';

/// Interceptor de autenticación JWT.
/// Agrega el token de acceso a cada petición y maneja
/// el refresco automático cuando el token expira (401).
class AuthInterceptor extends Interceptor {
  final Dio _dio;

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        final refresh = await SecureStorage.getRefreshToken();
        if (refresh == null) return handler.next(err);

        final response =
            await _dio.post('/auth/token/refresh/', data: {'refresh': refresh});
        final newAccess = response.data['access'] as String;
        await SecureStorage.updateAccessToken(newAccess);

        // Reintentar la petición original con el nuevo token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccess';
        final retryResponse = await _dio.fetch(opts);
        return handler.resolve(retryResponse);
      } catch (_) {
        await SecureStorage.clear();
      }
    }
    handler.next(err);
  }
}
