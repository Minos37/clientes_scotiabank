import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/seguro_model.dart';
import '../model/siniestro_model.dart';
import '../repository/seguro_repository.dart';

class SupabaseSeguroRepository implements SeguroRepository {
  final SupabaseClient _client;

  SupabaseSeguroRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Seguro>> getSeguros() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('seguros')
          .select()
          .eq('user_id', userId);

      return (response as List<dynamic>)
          .map((json) => Seguro.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener seguros de Supabase: $e');
    }
  }

  @override
  Future<List<Siniestro>> getSiniestros() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('siniestros')
          .select()
          .eq('user_id', userId)
          .order('fecha_reporte', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Siniestro.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener siniestros de Supabase: $e');
    }
  }

  @override
  Future<void> reportarSiniestro(Siniestro siniestro) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Insertar el siniestro
      await _client.from('siniestros').insert({
        'user_id': userId,
        'seguro_id': siniestro.seguroId,
        'descripcion': siniestro.descripcion,
        'monto_reclamado': siniestro.montoReclamado,
        'estado': 'en_revision',
        'fecha_ocurrencia': siniestro.fechaOcurrencia.toIso8601String().substring(0, 10),
      });

      // 2. Actualizar el estado del seguro a 'siniestro'
      await _client
          .from('seguros')
          .update({'estado': 'siniestro'})
          .eq('id', siniestro.seguroId);

    } catch (e) {
      throw Exception('Fallo al reportar el siniestro en Supabase: $e');
    }
  }
}
