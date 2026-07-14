// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:kache/domain/model/auth_models.dart';
import 'package:kache/domain/repository/auth_repository.dart';
import 'package:kache/data/local/secure_storage.dart';
import 'package:kache/data/remote/dto/auth_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remote;
  AuthRepositoryImpl(this._remote);

  @override
  Future<LoggedUser> login(String username, String password) async {
    final data = await _remote.login(username, password);
    return _guardarSesion(data);
  }

  @override
  Future<LoggedUser> register({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) async {
    final data = await _remote.register(
      username: username,
      email: email,
      password: password,
      password2: password2,
    );
    return _guardarSesion(data);
  }

  Future<LoggedUser> _guardarSesion(Map<String, dynamic> data) async {
    final user = LoggedUser.fromMap(data);
    await SecureStorage.saveSession(
      access: data['access'] as String,
      refresh: data['refresh'] as String,
      user: {
        'user_id': user.id,
        'username': user.username,
        'email': user.email,
        'is_staff': user.isStaff,
      },
    );
    return user;
  }

  @override
  Future<void> logout() async {
    final refresh = await SecureStorage.getRefreshToken();
    if (refresh != null) {
      await _remote.logout(refresh);
    }
    await SecureStorage.clear();
  }

  @override
  Future<LoggedUser?> getStoredUser() async {
    final access = await SecureStorage.getAccessToken();
    final userMap = await SecureStorage.getStoredUser();
    if (access == null || userMap == null) return null;
    return LoggedUser.fromMap(userMap);
  }
}
