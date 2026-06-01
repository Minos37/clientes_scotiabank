import '../model/prestamo_model.dart';
import '../model/cuota_prestamo_model.dart';

abstract class PrestamoRepository {
  Future<List<Prestamo>> getPrestamos();
  Future<List<CuotaPrestamo>> getCuotas(String prestamoId);
  Future<void> pagarCuota(String cuotaId, String cuentaId);
}
