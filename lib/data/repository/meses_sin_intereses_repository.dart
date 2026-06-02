import '../model/meses_sin_intereses_model.dart';

abstract class MesesSinInteresesRepository {
  Future<List<MesesSinInteresesModel>> getMesesSinIntereses();
  Future<void> registrarCompraMSI({
    required String tarjetaId,
    required String comercio,
    required double montoTotal,
    required int plazoMeses,
  });
}
