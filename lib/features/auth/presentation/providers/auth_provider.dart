// lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/auth_models.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/api/api_exception.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final LoggedUser? user;
  final String? errorMessage;

  const AuthState({required this.status, this.user, this.errorMessage});

  const AuthState.checking() : this(status: AuthStatus.checking);
  const AuthState.authenticated(LoggedUser user)
      : this(status: AuthStatus.authenticated, user: user);
  const AuthState.unauthenticated({String? errorMessage})
      : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(AuthRemoteDatasource());
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.checking()) {
    _checkStoredSession();
  }

  Future<void> _checkStoredSession() async {
    final user = await _repository.getStoredUser();
    state = user != null
        ? AuthState.authenticated(user)
        : const AuthState.unauthenticated();
  }

  Future<void> login(String username, String password) async {
    state = const AuthState.checking();
    try {
      final user = await _repository.login(username, password);
      state = AuthState.authenticated(user);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.message);
    } catch (_) {
      state = const AuthState.unauthenticated(
        errorMessage: 'No se pudo conectar con el servidor.',
      );
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String password2,
  }) async {
    state = const AuthState.checking();
    try {
      final user = await _repository.register(
        username: username,
        email: email,
        password: password,
        password2: password2,
      );
      state = AuthState.authenticated(user);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(errorMessage: e.message);
    } catch (_) {
      state = const AuthState.unauthenticated(
        errorMessage: 'No se pudo conectar con el servidor.',
      );
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
