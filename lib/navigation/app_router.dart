import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/register_screen.dart';
import '../ui/screens/movimientos_screen.dart';
import '../ui/screens/tarjetas_screen.dart';
import '../ui/screens/tarjeta_detalle_screen.dart';
import '../data/model/tarjeta_model.dart';
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
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
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
      // Otras rutas...
      GoRoute(
        path: '/tarjeta-detalle',
        builder: (context, state) {
          final tarjeta = state.extra as Tarjeta;
          return TarjetaDetalleScreen(tarjeta: tarjeta);
        },
      ),
    ],
    // Lógica de redirección basada en si el usuario está logueado o no
    redirect: (context, state) {
      final isAuth = authState.user != null;
      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToRegister = state.uri.path == '/register';

      if (!isAuth && !isGoingToLogin && !isGoingToRegister) {
        return '/login'; // Si no está logueado y trata de ir a otra pantalla, al login
      }
      
      if (isAuth && (isGoingToLogin || isGoingToRegister)) {
        return '/home'; // Si está logueado y va al login/register, lo mandamos al home
      }
      
      return null; // Ninguna redirección necesaria
    },
  );
});
