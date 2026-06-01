import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/pago_servicio_model.dart';
import '../../data/repository/pago_servicio_repository.dart';
import '../../data/remote/supabase_pago_servicio_repository.dart';
import 'auth_viewmodel.dart';
import 'cuenta_viewmodel.dart';
import 'tarjeta_viewmodel.dart';
import 'transaccion_viewmodel.dart';

final pagoServicioRepositoryProvider = Provider<PagoServicioRepository>((ref) {
  return SupabasePagoServicioRepository();
});

final pagosServiciosListProvider = FutureProvider.autoDispose<List<PagoServicio>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(pagoServicioRepositoryProvider);
  return repository.getPagosServicios();
});

class PagoServicioState {
  final bool isLoading;
  final String? error;
  final bool success;

  PagoServicioState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  PagoServicioState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return PagoServicioState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class PagoServicioViewModel extends Notifier<PagoServicioState> {
  @override
  PagoServicioState build() => PagoServicioState();

  Future<bool> pagarServicio({
    required String? cuentaId,
    required String? tarjetaId,
    required String servicio,
    required String proveedor,
    required String numeroContrato,
    required double monto,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final repository = ref.read(pagoServicioRepositoryProvider);

      final pago = PagoServicio(
        id: '',
        userId: '',
        cuentaId: cuentaId,
        tarjetaId: tarjetaId,
        servicio: servicio,
        proveedor: proveedor,
        numeroContrato: numeroContrato,
        monto: monto,
        estado: 'completado',
        canal: 'app',
      );

      await repository.pagarServicio(pago);

      // Invalidar proveedores para refrescar UI de saldos, movimientos y pagos
      ref.invalidate(cuentasProvider);
      ref.invalidate(tarjetasProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);
      ref.invalidate(pagosServiciosListProvider);

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final pagoServicioViewModelProvider =
    NotifierProvider<PagoServicioViewModel, PagoServicioState>(() {
  return PagoServicioViewModel();
});
