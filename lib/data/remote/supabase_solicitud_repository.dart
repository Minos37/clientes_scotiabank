import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/solicitud_model.dart';
import '../repository/solicitud_repository.dart';

class SupabaseSolicitudRepository implements SolicitudRepository {
  final SupabaseClient _client;

  SupabaseSolicitudRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Solicitud>> getSolicitudes() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('solicitudes')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Solicitud.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener solicitudes de Supabase: $e');
    }
  }

  @override
  Future<void> crearSolicitud(Solicitud solicitud) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      await _client.from('solicitudes').insert({
        'user_id': userId,
        'producto': solicitud.producto,
        'datos_solicitud': solicitud.datosSolicitud,
        'estado': 'pendiente',
      });
    } catch (e) {
      throw Exception('Fallo al crear la solicitud en Supabase: $e');
    }
  }
}
