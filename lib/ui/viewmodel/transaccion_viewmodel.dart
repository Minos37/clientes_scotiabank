import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/transaccion_model.dart';
import '../../data/repository/transaccion_repository.dart';
import '../../data/remote/supabase_transaccion_repository.dart';

final transaccionRepositoryProvider = Provider<TransaccionRepository>((ref) {
  return SupabaseTransaccionRepository();
});

final transaccionesProvider = FutureProvider<List<Transaccion>>((ref) async {
  final repository = ref.watch(transaccionRepositoryProvider);
  return repository.getTransacciones(limit: 5);
});

final todasTransaccionesProvider = FutureProvider<List<Transaccion>>((ref) async {
  final repository = ref.watch(transaccionRepositoryProvider);
  return repository.getTransacciones(limit: 100);
});
