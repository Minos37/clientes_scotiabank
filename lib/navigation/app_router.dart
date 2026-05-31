import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/movimientos_screen.dart';
import '../ui/screens/tarjetas_screen.dart';
import '../ui/viewmodel/auth_viewmodel.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Escuchamos el estado de autenticación para redireccionar automáticamente
  final authState = ref.watch(authViewModelProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/movimientos',
        builder: (context, state) => const MovimientosScreen(),
      ),
      GoRoute(
        path: '/tarjetas',
        builder: (context, state) => const TarjetasScreen(),
      ),
    ],
    // Lógica de redirección basada en si el usuario está logueado o no
    redirect: (context, state) {
      final isAuth = authState.user != null;
      final isGoingToLogin = state.uri.path == '/login';

      if (!isAuth && !isGoingToLogin) {
        return '/login'; // Si no está logueado y trata de ir a otra pantalla, lo mandamos al login
      }
      
      if (isAuth && isGoingToLogin) {
        return '/home'; // Si está logueado y trata de ir al login, lo mandamos al home
      }
      
      return null; // Ninguna redirección necesaria
    },
  );
});
