import '../model/pago_servicio_model.dart';

abstract class PagoServicioRepository {
  Future<void> pagarServicio(PagoServicio pago);
  Future<List<PagoServicio>> getPagosServicios();
}
