import '../model/transferencia_model.dart';

abstract class TransferenciaRepository {
  Future<void> realizarTransferencia(Transferencia transferencia);
  Future<List<Transferencia>> getTransferencias();
}
