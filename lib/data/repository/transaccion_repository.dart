import '../model/transaccion_model.dart';

abstract class TransaccionRepository {
  Future<List<Transaccion>> getTransacciones({int limit = 5});
}
