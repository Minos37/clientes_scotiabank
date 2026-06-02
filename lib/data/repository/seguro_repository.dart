import '../model/seguro_model.dart';
import '../model/siniestro_model.dart';

abstract class SeguroRepository {
  /// Obtiene la lista de seguros contratados por el usuario.
  Future<List<Seguro>> getSeguros();

  /// Obtiene el historial de siniestros/reclamos reportados por el usuario.
  Future<List<Siniestro>> getSiniestros();

  /// Reporta un siniestro o solicita cobertura para una póliza.
  Future<void> reportarSiniestro(Siniestro siniestro);
}
