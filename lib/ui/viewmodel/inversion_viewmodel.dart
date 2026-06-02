import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/deposito_plazo_model.dart';
import '../../data/model/fondo_mutuo_model.dart';
import '../../data/model/scotia_bolsa_model.dart';
import '../../data/repository/inversion_repository.dart';
import '../../data/remote/supabase_inversion_repository.dart';
import 'auth_viewmodel.dart';
import 'cuenta_viewmodel.dart';
import 'transaccion_viewmodel.dart';

final inversionRepositoryProvider = Provider<InversionRepository>((ref) {
  return SupabaseInversionRepository();
});

final depositosPlazoProvider = FutureProvider.autoDispose<List<DepositoPlazo>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(inversionRepositoryProvider);
  return repository.getDepositosPlazo();
});

final fondosMutuosProvider = FutureProvider.autoDispose<List<FondoMutuo>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(inversionRepositoryProvider);
  return repository.getFondosMutuos();
});

final historialBolsaProvider = FutureProvider.autoDispose<List<ScotiaBolsa>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(inversionRepositoryProvider);
  return repository.getHistorialBolsa();
});

class InversionState {
  final bool isLoading;
  final String? error;
  final bool success;

  InversionState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });
}

class InversionNotifier extends Notifier<InversionState> {
  @override
  InversionState build() => InversionState();

  Future<bool> crearDepositoPlazo({
    required double monto,
    required String moneda,
    required int plazoDias,
    required double tasaAnual,
    required String cuentaOrigenId,
    required bool renovacionAuto,
  }) async {
    state = InversionState(isLoading: true);
    try {
      final repository = ref.read(inversionRepositoryProvider);
      
      // Calcular rendimiento estimado simple
      final double rendimiento = monto * (tasaAnual / 100) * (plazoDias / 360);
      final DateTime fechaInicio = DateTime.now();
      final DateTime fechaVenc = fechaInicio.add(Duration(days: plazoDias));

      final deposito = DepositoPlazo(
        id: '',
        userId: '',
        cuentaId: cuentaOrigenId,
        monto: monto,
        moneda: moneda,
        plazoDias: plazoDias,
        tasaAnual: tasaAnual,
        rendimiento: rendimiento,
        fechaInicio: fechaInicio,
        fechaVenc: fechaVenc,
        estado: 'activo',
        renovacionAuto: renovacionAuto,
      );

      await repository.crearDepositoPlazo(deposito, cuentaOrigenId);
      
      ref.invalidate(cuentasProvider);
      ref.invalidate(depositosPlazoProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);

      state = InversionState(success: true);
      return true;
    } catch (e) {
      state = InversionState(error: e.toString());
      return false;
    }
  }

  Future<bool> suscribirFondoMutuo({
    required String fondoNombre,
    required String tipoFondo,
    required String moneda,
    required double monto,
    required double valorCuota,
    required double inversionMin,
    required String cuentaOrigenId,
  }) async {
    state = InversionState(isLoading: true);
    try {
      final repository = ref.read(inversionRepositoryProvider);
      
      final fondo = FondoMutuo(
        id: '',
        userId: '',
        fondo: fondoNombre,
        tipoFondo: tipoFondo,
        moneda: moneda,
        montoInvertido: monto,
        cuotas: monto / valorCuota,
        valorCuota: valorCuota,
        valorActual: monto,
        rentabilidad: 0.0,
        inversionMin: inversionMin,
        estado: 'activo',
      );

      await repository.suscribirFondoMutuo(fondo, monto, cuentaOrigenId);
      
      ref.invalidate(cuentasProvider);
      ref.invalidate(fondosMutuosProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);

      state = InversionState(success: true);
      return true;
    } catch (e) {
      state = InversionState(error: e.toString());
      return false;
    }
  }

  Future<bool> rescatarFondoMutuo({
    required String fondoId,
    required double monto,
    required String cuentaDestinoId,
  }) async {
    state = InversionState(isLoading: true);
    try {
      final repository = ref.read(inversionRepositoryProvider);
      await repository.rescatarFondoMutuo(fondoId, monto, cuentaDestinoId);
      
      ref.invalidate(cuentasProvider);
      ref.invalidate(fondosMutuosProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);

      state = InversionState(success: true);
      return true;
    } catch (e) {
      state = InversionState(error: e.toString());
      return false;
    }
  }

  Future<bool> comprarAccion({
    required String ticker,
    required double cantidad,
    required double precioUnitario,
    required String moneda,
    required double comision,
    required String cuentaOrigenId,
  }) async {
    state = InversionState(isLoading: true);
    try {
      final repository = ref.read(inversionRepositoryProvider);
      final transaccion = ScotiaBolsa(
        id: '',
        userId: '',
        ticker: ticker,
        operacion: 'compra',
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        montoTotal: cantidad * precioUnitario,
        moneda: moneda,
        comision: comision,
        estado: 'ejecutada',
        fecha: DateTime.now(),
      );

      await repository.comprarAccion(transaccion, cuentaOrigenId);

      ref.invalidate(cuentasProvider);
      ref.invalidate(historialBolsaProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);

      state = InversionState(success: true);
      return true;
    } catch (e) {
      state = InversionState(error: e.toString());
      return false;
    }
  }

  Future<bool> venderAccion({
    required String ticker,
    required double cantidad,
    required double precioUnitario,
    required String moneda,
    required double comision,
    required String cuentaDestinoId,
  }) async {
    state = InversionState(isLoading: true);
    try {
      final repository = ref.read(inversionRepositoryProvider);
      final transaccion = ScotiaBolsa(
        id: '',
        userId: '',
        ticker: ticker,
        operacion: 'venta',
        cantidad: cantidad,
        precioUnitario: precioUnitario,
        montoTotal: cantidad * precioUnitario,
        moneda: moneda,
        comision: comision,
        estado: 'ejecutada',
        fecha: DateTime.now(),
      );

      await repository.venderAccion(transaccion, cuentaDestinoId);

      ref.invalidate(cuentasProvider);
      ref.invalidate(historialBolsaProvider);
      ref.invalidate(transaccionesProvider);
      ref.invalidate(todasTransaccionesProvider);

      state = InversionState(success: true);
      return true;
    } catch (e) {
      state = InversionState(error: e.toString());
      return false;
    }
  }
}

final inversionNotifierProvider = NotifierProvider<InversionNotifier, InversionState>(() {
  return InversionNotifier();
});
