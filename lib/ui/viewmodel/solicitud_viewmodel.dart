import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/solicitud_model.dart';
import '../../data/repository/solicitud_repository.dart';
import '../../data/remote/supabase_solicitud_repository.dart';
import 'auth_viewmodel.dart';

final solicitudRepositoryProvider = Provider<SolicitudRepository>((ref) {
  return SupabaseSolicitudRepository();
});

final solicitudesProvider = FutureProvider.autoDispose<List<Solicitud>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(solicitudRepositoryProvider);
  return repository.getSolicitudes();
});

class SolicitudState {
  final bool isLoading;
  final String? error;
  final bool success;

  SolicitudState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  SolicitudState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return SolicitudState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

class SolicitudNotifier extends Notifier<SolicitudState> {
  @override
  SolicitudState build() => SolicitudState();

  Future<bool> crearSolicitud({
    required String producto,
    required Map<String, dynamic> datosSolicitud,
  }) async {
    state = SolicitudState(isLoading: true);
    try {
      final repository = ref.read(solicitudRepositoryProvider);
      
      final solicitud = Solicitud(
        id: '',
        userId: '',
        producto: producto,
        datosSolicitud: datosSolicitud,
        estado: 'pendiente',
      );

      await repository.crearSolicitud(solicitud);
      
      // Invalidar para volver a cargar la lista actualizada de solicitudes
      ref.invalidate(solicitudesProvider);
      
      state = SolicitudState(success: true);
      return true;
    } catch (e) {
      state = SolicitudState(error: e.toString());
      return false;
    }
  }
}

final solicitudNotifierProvider = NotifierProvider<SolicitudNotifier, SolicitudState>(() {
  return SolicitudNotifier();
});
