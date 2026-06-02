import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/seguro_model.dart';
import '../../data/model/siniestro_model.dart';
import '../../data/repository/seguro_repository.dart';
import '../../data/remote/supabase_seguro_repository.dart';
import 'auth_viewmodel.dart';

final seguroRepositoryProvider = Provider<SeguroRepository>((ref) {
  return SupabaseSeguroRepository();
});

final segurosProvider = FutureProvider.autoDispose<List<Seguro>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(seguroRepositoryProvider);
  return repository.getSeguros();
});

final siniestrosProvider = FutureProvider.autoDispose<List<Siniestro>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(seguroRepositoryProvider);
  return repository.getSiniestros();
});

class SeguroState {
  final bool isLoading;
  final String? error;
  final bool success;

  SeguroState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  SeguroState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return SeguroState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class SeguroNotifier extends Notifier<SeguroState> {
  @override
  SeguroState build() => SeguroState();

  Future<bool> reportarSiniestro({
    required String seguroId,
    required String descripcion,
    required double montoReclamado,
    required DateTime fechaOcurrencia,
  }) async {
    state = SeguroState(isLoading: true);
    try {
      final repository = ref.read(seguroRepositoryProvider);
      
      final siniestro = Siniestro(
        id: '',
        userId: '',
        seguroId: seguroId,
        descripcion: descripcion,
        montoReclamado: montoReclamado,
        estado: 'en_revision',
        fechaOcurrencia: fechaOcurrencia,
      );

      await repository.reportarSiniestro(siniestro);
      
      ref.invalidate(segurosProvider);
      ref.invalidate(siniestrosProvider);
      
      state = SeguroState(success: true);
      return true;
    } catch (e) {
      state = SeguroState(error: e.toString());
      return false;
    }
  }
}

final seguroNotifierProvider = NotifierProvider<SeguroNotifier, SeguroState>(() {
  return SeguroNotifier();
});
