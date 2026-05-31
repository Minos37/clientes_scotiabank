import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/tarjeta_model.dart';
import '../repository/tarjeta_repository.dart';

class SupabaseTarjetaRepository implements TarjetaRepository {
  final SupabaseClient _client;

  SupabaseTarjetaRepository({SupabaseClient? client}) 
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Tarjeta>> getTarjetas() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('tarjetas')
          .select()
          .eq('user_id', userId)
          .eq('activa', true)
          .order('created_at', ascending: true);
          
      return (response as List<dynamic>)
          .map((json) => Tarjeta.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener tarjetas: $e');
    }
  }
}
