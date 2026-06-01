import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/transferencia_model.dart';
import '../../data/repository/transferencia_repository.dart';
import '../../data/remote/supabase_transferencia_repository.dart';
import 'auth_viewmodel.dart';
import 'cuenta_viewmodel.dart';
import 'transaccion_viewmodel.dart';

final transferenciaRepositoryProvider = Provider<TransferenciaRepository>((ref) {
  return SupabaseTransferenciaRepository();
});

final transferenciasListProvider = FutureProvider.autoDispose<List<Transferencia>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];
  
  final repository = ref.watch(transferenciaRepositoryProvider);
  return repository.getTransferencias();
});

class TransferenciaState {
  final bool isLoading;
  final String? error;
  final bool success;

  TransferenciaState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  TransferenciaState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return TransferenciaState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class TransferenciaViewModel extends Notifier<TransferenciaState> {
  @override
  TransferenciaState build() => TransferenciaState();

  Future<bool> realizarTransferencia({
    required String? cuentaOrigenId,
    required String tipo,
    required String? bancoDestino,
    required String? cuentaDestino,
    required String nombreDestino,
    required double monto,
    required String moneda,
    String? referencia,
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final repository = ref.read(transferenciaRepositoryProvider);
      
      final transferencia = Transferencia(
        id: '',
        userId: '',
        cuentaOrigenId: cuentaOrigenId,
        tipo: tipo,
        bancoDestino: bancoDestino,
        cuentaDestino: cuentaDestino,
        nombreDestino: nombreDestino,
        monto: monto,
        moneda: moneda,
        comision: 0.0,
        estado: 'completado',
        referencia: referencia,
      );

      await repository.realizarTransferencia(transferencia);
      
      // Forzar recarga automática de las pantallas de cuentas y movimientos
      ref.invalidate(cuentasProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);
      ref.invalidate(transferenciasListProvider);

      state = state.copyWith(isLoading: false, success: true);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final transferenciaViewModelProvider =
    NotifierProvider<TransferenciaViewModel, TransferenciaState>(() {
  return TransferenciaViewModel();
});
