import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/scotia_puntos_model.dart';
import '../../data/repository/scotia_puntos_repository.dart';
import '../../data/remote/supabase_scotia_puntos_repository.dart';
import 'auth_viewmodel.dart';
import 'tarjeta_viewmodel.dart';

final scotiaPuntosRepositoryProvider = Provider<ScotiaPuntosRepository>((ref) {
  return SupabaseScotiaPuntosRepository();
});

final movimientosPuntosProvider = FutureProvider.autoDispose<List<ScotiaPuntosModel>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(scotiaPuntosRepositoryProvider);
  return repository.getMovimientosPuntos();
});

final puntosTotalesProvider = FutureProvider.autoDispose<int>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return 0;

  final repository = ref.watch(scotiaPuntosRepositoryProvider);
  return repository.getPuntosTotales();
});

class ScotiaPuntosState {
  final bool isLoading;
  final String? error;
  final bool success;

  ScotiaPuntosState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  ScotiaPuntosState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return ScotiaPuntosState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class ScotiaPuntosNotifier extends Notifier<ScotiaPuntosState> {
  @override
  ScotiaPuntosState build() => ScotiaPuntosState();

  Future<bool> canjearPuntos({
    required String tarjetaId,
    required int puntos,
    required String descripcion,
  }) async {
    state = ScotiaPuntosState(isLoading: true);
    try {
      final repository = ref.read(scotiaPuntosRepositoryProvider);
      await repository.canjearPuntos(
        tarjetaId: tarjetaId,
        puntos: puntos,
        descripcion: descripcion,
      );

      // Invalidar proveedores relacionados
      ref.invalidate(movimientosPuntosProvider);
      ref.invalidate(puntosTotalesProvider);
      ref.invalidate(tarjetasProvider);

      state = ScotiaPuntosState(success: true);
      return true;
    } catch (e) {
      state = ScotiaPuntosState(error: e.toString());
      return false;
    }
  }
}

final scotiaPuntosNotifierProvider = NotifierProvider<ScotiaPuntosNotifier, ScotiaPuntosState>(() {
  return ScotiaPuntosNotifier();
});
