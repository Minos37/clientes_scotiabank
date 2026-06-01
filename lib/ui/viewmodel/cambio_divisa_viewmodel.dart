import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/cambio_divisa_model.dart';
import '../../data/repository/cambio_divisa_repository.dart';
import '../../data/remote/supabase_cambio_divisa_repository.dart';
import 'auth_viewmodel.dart';
import 'cuenta_viewmodel.dart';
import 'transaccion_viewmodel.dart';

final cambioDivisaRepositoryProvider = Provider<CambioDivisaRepository>((ref) {
  return SupabaseCambioDivisaRepository();
});

final cambiosHistorialProvider = FutureProvider.autoDispose<List<CambioDivisa>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(cambioDivisaRepositoryProvider);
  return repository.getHistorialCambios();
});

class CambioDivisaState {
  final bool isLoading;
  final String? error;
  final bool success;
  
  // Tipos de cambio preferenciales Scotiabank
  final double tcCompra; // Ej: S/ 3.72
  final double tcVenta;  // Ej: S/ 3.75

  CambioDivisaState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.tcCompra = 3.7250,
    this.tcVenta = 3.7580,
  });

  CambioDivisaState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    double? tcCompra,
    double? tcVenta,
  }) {
    return CambioDivisaState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
      tcCompra: tcCompra ?? this.tcCompra,
      tcVenta: tcVenta ?? this.tcVenta,
    );
  }
}

class CambioDivisaViewModel extends Notifier<CambioDivisaState> {
  @override
  CambioDivisaState build() => CambioDivisaState();

  double calcularMontoDestino({
    required double montoOrigen,
    required String operacion, // 'compra' (Vendes USD / Recibes PEN) o 'venta' (Vendes PEN / Recibes USD)
  }) {
    if (operacion == 'compra') {
      // Vendes USD a Scotiabank -> Te dan PEN
      // Monto PEN = Monto USD * tcCompra
      return montoOrigen * state.tcCompra;
    } else {
      // Compras USD de Scotiabank (Vendes PEN) -> Te dan USD
      // Monto USD = Monto PEN / tcVenta
      return montoOrigen / state.tcVenta;
    }
  }

  Future<bool> realizarCambio({
    required String cuentaOrigenId,
    required String cuentaDestinoId,
    required String operacion,
    required double montoOrigen,
    required double montoDestino,
    required String monedaOrigen,
    required String monedaDestino,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final repository = ref.read(cambioDivisaRepositoryProvider);
      
      final tc = operacion == 'compra' ? state.tcCompra : state.tcVenta;

      final cambio = CambioDivisa(
        id: '',
        userId: '',
        cuentaId: cuentaOrigenId,
        operacion: operacion,
        montoOrigen: montoOrigen,
        monedaOrigen: monedaOrigen,
        tipoCambio: tc,
        montoDestino: montoDestino,
        monedaDestino: monedaDestino,
        canal: 'app',
      );

      await repository.realizarCambio(cambio, cuentaDestinoId: cuentaDestinoId);

      // Invalidar saldos y movimientos
      ref.invalidate(cuentasProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);
      ref.invalidate(cambiosHistorialProvider);

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final cambioDivisaViewModelProvider =
    NotifierProvider<CambioDivisaViewModel, CambioDivisaState>(() {
  return CambioDivisaViewModel();
});
