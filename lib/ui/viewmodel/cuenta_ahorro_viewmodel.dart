import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/cuenta_ahorro_model.dart';
import '../../data/repository/cuenta_ahorro_repository.dart';
import '../../data/remote/supabase_cuenta_ahorro_repository.dart';
import 'auth_viewmodel.dart';
import 'cuenta_viewmodel.dart';
import 'transaccion_viewmodel.dart';

final cuentaAhorroRepositoryProvider = Provider<CuentaAhorroRepository>((ref) {
  return SupabaseCuentaAhorroRepository();
});

final cuentasAhorroProvider = FutureProvider.autoDispose<List<CuentaAhorro>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(cuentaAhorroRepositoryProvider);
  return repository.getCuentasAhorro();
});

class CuentaAhorroState {
  final bool isLoading;
  final String? error;
  final bool success;

  CuentaAhorroState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  CuentaAhorroState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return CuentaAhorroState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class CuentaAhorroNotifier extends Notifier<CuentaAhorroState> {
  @override
  CuentaAhorroState build() => CuentaAhorroState();

  Future<bool> crearMeta({
    required double metaAhorro,
    required double tasaInteres,
    required String moneda,
    String? cuentaId,
  }) async {
    state = CuentaAhorroState(isLoading: true);
    try {
      final repository = ref.read(cuentaAhorroRepositoryProvider);
      final cuenta = CuentaAhorro(
        id: '',
        userId: '',
        cuentaId: cuentaId,
        saldo: 0.0,
        metaAhorro: metaAhorro,
        tasaInteres: tasaInteres,
        moneda: moneda,
      );

      await repository.crearCuentaAhorro(cuenta);
      ref.invalidate(cuentasAhorroProvider);
      state = CuentaAhorroState(success: true);
      return true;
    } catch (e) {
      state = CuentaAhorroState(error: e.toString());
      return false;
    }
  }

  Future<bool> ahorrar({
    required String cuentaAhorroId,
    required double monto,
    required String cuentaOrigenId,
  }) async {
    state = CuentaAhorroState(isLoading: true);
    try {
      final repository = ref.read(cuentaAhorroRepositoryProvider);
      await repository.ahorrarMonto(cuentaAhorroId, monto, cuentaOrigenId);
      
      ref.invalidate(cuentasProvider);
      ref.invalidate(cuentasAhorroProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);
      
      state = CuentaAhorroState(success: true);
      return true;
    } catch (e) {
      state = CuentaAhorroState(error: e.toString());
      return false;
    }
  }

  Future<bool> retirar({
    required String cuentaAhorroId,
    required double monto,
    required String cuentaDestinoId,
  }) async {
    state = CuentaAhorroState(isLoading: true);
    try {
      final repository = ref.read(cuentaAhorroRepositoryProvider);
      await repository.retirarMonto(cuentaAhorroId, monto, cuentaDestinoId);
      
      ref.invalidate(cuentasProvider);
      ref.invalidate(cuentasAhorroProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);
      
      state = CuentaAhorroState(success: true);
      return true;
    } catch (e) {
      state = CuentaAhorroState(error: e.toString());
      return false;
    }
  }
}

final cuentaAhorroNotifierProvider =
    NotifierProvider<CuentaAhorroNotifier, CuentaAhorroState>(() {
  return CuentaAhorroNotifier();
});
