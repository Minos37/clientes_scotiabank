import '../model/scotia_puntos_model.dart';

abstract class ScotiaPuntosRepository {
  Future<List<ScotiaPuntosModel>> getMovimientosPuntos();
  Future<int> getPuntosTotales();
  Future<void> canjearPuntos({
    required String tarjetaId,
    required int puntos,
    required String descripcion,
  });
}
