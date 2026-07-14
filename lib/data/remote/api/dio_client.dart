// lib/core/api/dio_client.dart

import 'package:dio/dio.dart';
import 'package:kache/core/config/app_config.dart';
import 'package:kache/data/local/secure_storage.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _build();
    return _dio!;
  }

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final esRutaPublica = options.path.contains('/auth/login') ||
            options.path.contains('/auth/register') ||
            options.path.contains('/auth/token/refresh') ||
            options.path.contains('/auth/password-reset');

        if (!esRutaPublica) {
          final token = await SecureStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final esRefreshFallido = error.requestOptions.path.contains('/auth/token/refresh');

        if (error.response?.statusCode == 401 && !esRefreshFallido) {
          final refreshToken = await SecureStorage.getRefreshToken();

          if (refreshToken != null) {
            try {
              final refreshDio = Dio(BaseOptions(baseUrl: AppConfig.baseUrl));
              final response = await refreshDio.post(
                '/auth/token/refresh/',
                data: {'refresh': refreshToken},
              );

              final newAccess = response.data['access'] as String;
              final newRefresh = response.data['refresh'] as String?;
              await SecureStorage.updateTokens(newAccess, newRefresh);

              final retryOptions = error.requestOptions;
              retryOptions.headers['Authorization'] = 'Bearer $newAccess';
              final retryResponse =
                  await Dio(BaseOptions(baseUrl: AppConfig.baseUrl)).fetch(retryOptions);
              return handler.resolve(retryResponse);
            } catch (_) {
              await SecureStorage.clear();
            }
          } else {
            await SecureStorage.clear();
          }
        }
        handler.next(error);
      },
    ));

    return dio;
  }
}
