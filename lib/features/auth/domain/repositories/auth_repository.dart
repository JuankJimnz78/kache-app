// lib/features/auth/domain/repositories/auth_repository.dart

import '../models/auth_models.dart';

abstract class AuthRepository {
  Future<LoggedUser> login(String username, String password);
  Future<LoggedUser> register({
    required String username,
    required String email,
    required String password,
    required String password2,
  });
  Future<void> logout();
  Future<LoggedUser?> getStoredUser();
}
