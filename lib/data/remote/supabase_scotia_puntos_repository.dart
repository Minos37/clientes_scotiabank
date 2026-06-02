import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/scotia_puntos_model.dart';
import '../repository/scotia_puntos_repository.dart';

class SupabaseScotiaPuntosRepository implements ScotiaPuntosRepository {
  final SupabaseClient _client;

  SupabaseScotiaPuntosRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<ScotiaPuntosModel>> getMovimientosPuntos() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('scotia_puntos')
          .select()
          .eq('user_id', userId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((json) => ScotiaPuntosModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener movimientos de puntos: $e');
    }
  }

  @override
  Future<int> getPuntosTotales() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return 0;

    try {
      // Sumar los puntos de todas las tarjetas de crédito activas del usuario
      final response = await _client
          .from('tarjetas')
          .select('puntos_acumulados')
          .eq('user_id', userId)
          .eq('activa', true)
          .eq('tipo', 'credito');

      int total = 0;
      for (var card in response as List<dynamic>) {
        total += (card['puntos_acumulados'] as num?)?.toInt() ?? 0;
      }
      return total;
    } catch (e) {
      throw Exception('Error al obtener puntos totales: $e');
    }
  }

  @override
  Future<void> canjearPuntos({
    required String tarjetaId,
    required int puntos,
    required String descripcion,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    try {
      // 1. Obtener los puntos acumulados de la tarjeta
      final tarjetaResponse = await _client
          .from('tarjetas')
          .select('puntos_acumulados')
          .eq('id', tarjetaId)
          .single();

      final puntosActuales = (tarjetaResponse['puntos_acumulados'] as num?)?.toInt() ?? 0;

      if (puntosActuales < puntos) {
        throw Exception('Puntos insuficientes en esta tarjeta');
      }

      // 2. Insertar movimiento de canje (negativo)
      await _client.from('scotia_puntos').insert({
        'user_id': userId,
        'tarjeta_id': tarjetaId,
        'tipo_movimiento': 'canje',
        'puntos': -puntos,
        'descripcion': descripcion,
        'fecha': DateTime.now().toIso8601String(),
      });

      // 3. Actualizar la tarjeta descontando los puntos
      await _client
          .from('tarjetas')
          .update({'puntos_acumulados': puntosActuales - puntos})
          .eq('id', tarjetaId);

    } catch (e) {
      throw Exception('Error al canjear puntos: $e');
    }
  }
}
