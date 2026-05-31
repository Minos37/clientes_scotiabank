import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/transaccion_model.dart';
import '../repository/transaccion_repository.dart';

class SupabaseTransaccionRepository implements TransaccionRepository {
  final SupabaseClient _client;

  SupabaseTransaccionRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Transaccion>> getTransacciones({int limit = 5}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('transacciones')
          .select()
          .eq('user_id', userId)
          .order('fecha', ascending: false)
          .limit(limit);
          
      return (response as List<dynamic>)
          .map((json) => Transaccion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener transacciones: $e');
    }
  }
}
