import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/prestamo_model.dart';
import '../../data/model/cuota_prestamo_model.dart';
import '../../data/repository/prestamo_repository.dart';
import '../../data/remote/supabase_prestamo_repository.dart';
import 'auth_viewmodel.dart';
import 'cuenta_viewmodel.dart';
import 'transaccion_viewmodel.dart';

final prestamoRepositoryProvider = Provider<PrestamoRepository>((ref) {
  return SupabasePrestamoRepository();
});

final prestamosListProvider = FutureProvider.autoDispose<List<Prestamo>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(prestamoRepositoryProvider);
  return repository.getPrestamos();
});

final cuotasListProvider = FutureProvider.family.autoDispose<List<CuotaPrestamo>, String>((ref, prestamoId) async {
  final repository = ref.watch(prestamoRepositoryProvider);
  return repository.getCuotas(prestamoId);
});

class PrestamoPaymentState {
  final bool isLoading;
  final String? error;
  final bool success;

  PrestamoPaymentState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  PrestamoPaymentState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return PrestamoPaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class PrestamoPaymentViewModel extends Notifier<PrestamoPaymentState> {
  @override
  PrestamoPaymentState build() => PrestamoPaymentState();

  Future<bool> pagarCuota({
    required String cuotaId,
    required String cuentaId,
    required String prestamoId,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final repository = ref.read(prestamoRepositoryProvider);
      await repository.pagarCuota(cuotaId, cuentaId);

      // Invalidar proveedores para refrescar saldos de cuentas, movimientos, préstamos y cuotas
      ref.invalidate(cuentasProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);
      ref.invalidate(prestamosListProvider);
      ref.invalidate(cuotasListProvider(prestamoId));

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final prestamoPaymentViewModelProvider =
    NotifierProvider<PrestamoPaymentViewModel, PrestamoPaymentState>(() {
  return PrestamoPaymentViewModel();
});
