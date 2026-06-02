import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/notificacion_model.dart';
import '../repository/notificacion_repository.dart';

class SupabaseNotificacionRepository implements NotificacionRepository {
  final SupabaseClient _client;

  SupabaseNotificacionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Notificacion>> getNotificaciones() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('notificaciones')
          .select()
          .eq('user_id', userId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Notificacion.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener notificaciones: $e');
    }
  }

  @override
  Future<void> marcarComoLeida(String id) async {
    try {
      await _client
          .from('notificaciones')
          .update({'leida': true})
          .eq('id', id);
    } catch (e) {
      throw Exception('Error al marcar notificación como leída: $e');
    }
  }

  @override
  Future<void> marcarTodasComoLeidas() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await _client
          .from('notificaciones')
          .update({'leida': true})
          .eq('user_id', userId)
          .eq('leida', false);
    } catch (e) {
      throw Exception('Error al marcar todas las notificaciones como leídas: $e');
    }
  }

  @override
  Stream<List<Notificacion>> escucharNotificaciones() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return _client
        .from('notificaciones')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('fecha', ascending: false)
        .map((maps) {
          return maps
              .map((json) => Notificacion.fromJson(json))
              .toList();
        });
  }
}
