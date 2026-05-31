import '../model/user_model.dart';

/// Interfaz que define las operaciones de autenticación.
/// Mantiene la UI desacoplada de Supabase.
abstract class AuthRepository {
  /// Inicia sesión con correo y contraseña. Retorna el usuario si es exitoso.
  Future<UserModel?> login(String email, String password);

  /// Registra un nuevo usuario.
  Future<UserModel?> register(String email, String password, {String? nombre, String? dni});

  /// Cierra la sesión actual.
  Future<void> logout();

  /// Obtiene el usuario actual si hay una sesión activa.
  UserModel? getCurrentUser();

  /// Escucha los cambios de estado de la sesión (login/logout).
  Stream<UserModel?> get authStateChanges;
}
