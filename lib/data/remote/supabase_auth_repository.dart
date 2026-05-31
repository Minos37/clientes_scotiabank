import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/user_model.dart';
import '../repository/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  @override
  Future<UserModel?> login(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _mapUser(response.user);
    } catch (e) {
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  @override
  Future<UserModel?> register(String email, String password, {String? nombre, String? dni}) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          // ignore: use_null_aware_elements
          if (nombre != null) 'nombre': nombre,
          // ignore: use_null_aware_elements
          if (dni != null) 'dni': dni,
        },
      );
      return _mapUser(response.user);
    } catch (e) {
      throw Exception('Error al registrar usuario: $e');
    }
  }

  @override
  Future<void> logout() async {
    await _client.auth.signOut();
  }

  @override
  UserModel? getCurrentUser() {
    return _mapUser(_client.auth.currentUser);
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      return _mapUser(event.session?.user);
    });
  }

  /// Convierte el usuario de Supabase a nuestro UserModel independiente
  UserModel? _mapUser(User? supabaseUser) {
    if (supabaseUser == null) return null;
    
    return UserModel(
      id: supabaseUser.id,
      email: supabaseUser.email ?? '',
      nombre: supabaseUser.userMetadata?['nombre']?.toString(),
      dni: supabaseUser.userMetadata?['dni']?.toString(),
    );
  }
}
