import '../model/cuenta_ahorro_model.dart';

abstract class CuentaAhorroRepository {
  /// Obtiene los planes o cuentas de ahorro del usuario.
  Future<List<CuentaAhorro>> getCuentasAhorro();

  /// Crea una nueva meta de ahorro programado.
  Future<void> crearCuentaAhorro(CuentaAhorro cuenta);

  /// Deposita o ahorra dinero desde una cuenta regular (origen) hacia la cuenta de ahorro programado.
  Future<void> ahorrarMonto(String cuentaAhorroId, double monto, String cuentaOrigenId);

  /// Retira o libera dinero de la cuenta de ahorro programado de regreso a una cuenta regular (destino).
  Future<void> retirarMonto(String cuentaAhorroId, double monto, String cuentaDestinoId);
}
