import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/notificacion_model.dart';
import '../../data/repository/notificacion_repository.dart';
import '../../data/remote/supabase_notificacion_repository.dart';
import 'auth_viewmodel.dart';

final notificacionRepositoryProvider = Provider<NotificacionRepository>((ref) {
  return SupabaseNotificacionRepository();
});

// StreamProvider para las notificaciones en tiempo real
final notificacionesStreamProvider = StreamProvider.autoDispose<List<Notificacion>>((ref) {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return Stream.value([]);

  final repository = ref.watch(notificacionRepositoryProvider);
  return repository.escucharNotificaciones();
});

// Contador de notificaciones no leídas
final notificacionesNoLeidasCountProvider = Provider.autoDispose<int>((ref) {
  final notificacionesAsync = ref.watch(notificacionesStreamProvider);
  return notificacionesAsync.maybeWhen(
    data: (list) => list.where((n) => !n.leida).length,
    orElse: () => 0,
  );
});

class NotificacionNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> marcarComoLeida(String id) async {
    try {
      final repository = ref.read(notificacionRepositoryProvider);
      await repository.marcarComoLeida(id);
    } catch (e) {
      // Registrar error
    }
  }

  Future<void> marcarTodasComoLeidas() async {
    try {
      final repository = ref.read(notificacionRepositoryProvider);
      await repository.marcarTodasComoLeidas();
    } catch (e) {
      // Registrar error
    }
  }
}

final notificacionNotifierProvider = NotifierProvider<NotificacionNotifier, void>(() {
  return NotificacionNotifier();
});
