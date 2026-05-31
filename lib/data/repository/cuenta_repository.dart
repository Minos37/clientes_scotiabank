import '../model/cuenta_model.dart';

/// Interfaz abstracta que define los métodos que cualquier base de datos 
/// o fuente de datos debe cumplir para manejar "Cuentas".
abstract class CuentaRepository {
  Future<List<Cuenta>> getCuentas();
}
