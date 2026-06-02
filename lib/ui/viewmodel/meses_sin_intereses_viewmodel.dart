import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/meses_sin_intereses_model.dart';
import '../../data/repository/meses_sin_intereses_repository.dart';
import '../../data/remote/supabase_meses_sin_intereses_repository.dart';
import 'auth_viewmodel.dart';
import 'tarjeta_viewmodel.dart';

final mesesSinInteresesRepositoryProvider = Provider<MesesSinInteresesRepository>((ref) {
  return SupabaseMesesSinInteresesRepository();
});

final mesesSinInteresesProvider = FutureProvider.autoDispose<List<MesesSinInteresesModel>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(mesesSinInteresesRepositoryProvider);
  return repository.getMesesSinIntereses();
});

class MesesSinInteresesState {
  final bool isLoading;
  final String? error;
  final bool success;

  MesesSinInteresesState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  MesesSinInteresesState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return MesesSinInteresesState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class MesesSinInteresesNotifier extends Notifier<MesesSinInteresesState> {
  @override
  MesesSinInteresesState build() => MesesSinInteresesState();

  Future<bool> registrarCompraMSI({
    required String tarjetaId,
    required String comercio,
    required double montoTotal,
    required int plazoMeses,
  }) async {
    state = MesesSinInteresesState(isLoading: true);
    try {
      final repository = ref.read(mesesSinInteresesRepositoryProvider);
      await repository.registrarCompraMSI(
        tarjetaId: tarjetaId,
        comercio: comercio,
        montoTotal: montoTotal,
        plazoMeses: plazoMeses,
      );

      // Invalidar proveedores relacionados
      ref.invalidate(mesesSinInteresesProvider);
      ref.invalidate(tarjetasProvider);

      state = MesesSinInteresesState(success: true);
      return true;
    } catch (e) {
      state = MesesSinInteresesState(error: e.toString());
      return false;
    }
  }
}

final mesesSinInteresesNotifierProvider = NotifierProvider<MesesSinInteresesNotifier, MesesSinInteresesState>(() {
  return MesesSinInteresesNotifier();
});
