import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/cuenta_model.dart';
import '../../data/repository/cuenta_repository.dart';
import '../../data/remote/supabase_cuenta_repository.dart';
import 'auth_viewmodel.dart';

final cuentaRepositoryProvider = Provider<CuentaRepository>((ref) {
  return SupabaseCuentaRepository();
});

final cuentasProvider = FutureProvider.autoDispose<List<Cuenta>>((ref) async {
  // Observamos solo el ID del usuario para evitar recargas innecesarias y limpiar al hacer logout
  final userId = ref.watch(authViewModelProvider.select((state) => state.user?.id));
  if (userId == null) return [];
  
  final repository = ref.watch(cuentaRepositoryProvider);
  return repository.getCuentas();
});
