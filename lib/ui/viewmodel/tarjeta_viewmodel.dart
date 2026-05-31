import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/tarjeta_model.dart';
import '../../data/repository/tarjeta_repository.dart';
import '../../data/remote/supabase_tarjeta_repository.dart';
import 'auth_viewmodel.dart';

final tarjetaRepositoryProvider = Provider<TarjetaRepository>((ref) {
  return SupabaseTarjetaRepository();
});

final tarjetasProvider = FutureProvider.autoDispose<List<Tarjeta>>((ref) async {
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];

  final repository = ref.watch(tarjetaRepositoryProvider);
  return repository.getTarjetas();
});
