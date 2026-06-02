import '../model/deposito_plazo_model.dart';
import '../model/fondo_mutuo_model.dart';
import '../model/scotia_bolsa_model.dart';

abstract class InversionRepository {
  // ── Plazo Fijo ───────
  Future<List<DepositoPlazo>> getDepositosPlazo();
  Future<void> crearDepositoPlazo(DepositoPlazo deposito, String cuentaOrigenId);

  // ── Fondos Mutuos ───────
  Future<List<FondoMutuo>> getFondosMutuos();
  Future<void> suscribirFondoMutuo(FondoMutuo fondo, double monto, String cuentaOrigenId);
  Future<void> rescatarFondoMutuo(String fondoId, double monto, String cuentaDestinoId);

  // ── Scotia Bolsa ───────
  Future<List<ScotiaBolsa>> getHistorialBolsa();
  Future<void> comprarAccion(ScotiaBolsa transaccion, String cuentaOrigenId);
  Future<void> venderAccion(ScotiaBolsa transaccion, String cuentaDestinoId);
}
