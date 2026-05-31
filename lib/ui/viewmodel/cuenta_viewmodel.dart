import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/cuenta_model.dart';
import '../../data/repository/cuenta_repository.dart';
import '../../data/remote/supabase_cuenta_repository.dart';

final cuentaRepositoryProvider = Provider<CuentaRepository>((ref) {
  return SupabaseCuentaRepository();
});

final cuentasProvider = FutureProvider<List<Cuenta>>((ref) async {
  final repository = ref.watch(cuentaRepositoryProvider);
  return repository.getCuentas();
});
