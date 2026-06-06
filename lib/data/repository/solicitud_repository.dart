import '../model/solicitud_model.dart';

abstract class SolicitudRepository {
  /// Obtiene la lista de solicitudes del usuario actual.
  Future<List<Solicitud>> getSolicitudes();

  /// Crea/envía una nueva solicitud de producto.
  Future<void> crearSolicitud(Solicitud solicitud);
}
