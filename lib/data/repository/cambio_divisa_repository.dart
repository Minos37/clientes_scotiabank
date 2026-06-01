import '../model/cambio_divisa_model.dart';

abstract class CambioDivisaRepository {
  Future<void> realizarCambio(CambioDivisa cambio, {String? cuentaDestinoId});
  Future<List<CambioDivisa>> getHistorialCambios();
}
