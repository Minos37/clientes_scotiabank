import '../model/notificacion_model.dart';

abstract class NotificacionRepository {
  /// Obtiene la lista histórica de notificaciones del usuario.
  Future<List<Notificacion>> getNotificaciones();

  /// Marca una notificación como leída en la base de datos.
  Future<void> marcarComoLeida(String id);

  /// Marca todas las notificaciones del usuario como leídas.
  Future<void> marcarTodasComoLeidas();

  /// Escucha notificaciones en tiempo real (Stream) utilizando Supabase Realtime.
  Stream<List<Notificacion>> escucharNotificaciones();
}
