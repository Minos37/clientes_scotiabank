import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/model/user_model.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/remote/supabase_auth_repository.dart';

// 1. Proveedor del repositorio: Inyectamos SupabaseAuthRepository.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return SupabaseAuthRepository();
});

// 2. Estado de la autenticación
class AuthState {
  final bool isLoading;
  final UserModel? user;
  final String? error;

  AuthState({this.isLoading = false, this.user, this.error});

  AuthState copyWith({
    bool? isLoading,
    UserModel? user,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// 3. ViewModel: Migrado a Notifier (Sintaxis moderna de Riverpod 2.0 y 3.0)
class AuthViewModel extends Notifier<AuthState> {
  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);

    // Escuchamos los cambios de sesión en tiempo real
    final sub = repository.authStateChanges.listen((user) {
      state = AuthState(user: user);
    });

    // Limpiamos la suscripción cuando el ViewModel se destruya
    ref.onDispose(() {
      sub.cancel();
    });

    // Retornamos el estado inicial verificando si ya hay usuario logueado
    return AuthState(user: repository.getCurrentUser());
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> register(String email, String password, {String? nombre, String? dni}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref.read(authRepositoryProvider).register(email, password, nombre: nombre, dni: dni);
      state = state.copyWith(isLoading: false, user: user);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> recoverPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).recoverPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(authRepositoryProvider).logout();
      state = AuthState(user: null, isLoading: false); // Reseteo completo en logout
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// 4. Proveedor del Notifier para usarlo en la UI
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthState>(() {
  return AuthViewModel();
});
