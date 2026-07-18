// lib/features/auth/domain/models/auth_models.dart

class AuthTokens {
  final String access;
  final String refresh;
  const AuthTokens({required this.access, required this.refresh});
}

class LoggedUser {
  final int    id;
  final String username;
  final String email;
  final bool   isStaff;
  final String rol;

  const LoggedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    required this.rol,
  });

  factory LoggedUser.fromMap(Map<String, dynamic> map) => LoggedUser(
    id:       map['user_id'] as int,
    username: map['username'] as String,
    email:    map['email']    as String,
    isStaff:  map['is_staff'] as bool,
    // 'CLIENTE' como valor por defecto: cubre sesiones guardadas antes de
    // que el backend empezara a devolver 'rol'.
    rol:      map['rol'] as String? ?? 'CLIENTE',
  );

  bool get esAdmin => rol == 'ADMIN';
  bool get esOperador => rol == 'OPERADOR';

  /// Puede ver y usar el panel de administración (aunque con permisos
  /// distintos dentro de él según el rol exacto).
  bool get puedeAdministrar => esAdmin || esOperador;
}
