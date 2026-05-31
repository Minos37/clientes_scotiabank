import '../model/tarjeta_model.dart';

abstract class TarjetaRepository {
  Future<List<Tarjeta>> getTarjetas();
}
