import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/cuenta_model.dart';
import '../repository/cuenta_repository.dart';

/// Implementación concreta del repositorio usando Supabase.
/// Si mañana cambias a Firebase o una API REST, solo creas un nuevo
/// repositorio que implemente CuentaRepository y no tocas el resto de la app.
class SupabaseCuentaRepository implements CuentaRepository {
  final SupabaseClient _client;

  // Inyección de dependencias: permite pasar un cliente mock para tests
  SupabaseCuentaRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Cuenta>> getCuentas() async {
    final userId = _client.auth.currentUser?.id;
    
    // Si no hay usuario logueado, retornamos lista vacía
    if (userId == null) return [];

    try {
      final response = await _client
          .from('cuentas')
          .select()
          .eq('user_id', userId);
          
      return (response as List<dynamic>)
          .map((json) => Cuenta.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener cuentas desde Supabase: $e');
    }
  }
}
