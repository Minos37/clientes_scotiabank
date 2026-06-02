import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/login_screen.dart';
import '../ui/screens/register_screen.dart';
import '../ui/screens/movimientos_screen.dart';
import '../ui/screens/tarjetas_screen.dart';
import '../ui/screens/tarjeta_detalle_screen.dart';
import '../ui/screens/operaciones_screen.dart';
import '../ui/screens/mas_screen.dart';
import '../ui/screens/perfil_screen.dart';
import '../ui/screens/pagos_screen.dart';
import '../ui/screens/transferencias_screen.dart';
import '../ui/screens/cambio_divisas_screen.dart';
import '../ui/screens/prestamos_screen.dart';
import '../ui/screens/prestamo_detalle_screen.dart';
import '../ui/screens/notificaciones_screen.dart';
import '../ui/screens/ahorro_screen.dart';
import '../ui/screens/seguros_screen.dart';
import '../ui/screens/inversiones_screen.dart';
import '../ui/screens/scotia_puntos_screen.dart';
import '../ui/screens/meses_sin_intereses_screen.dart';
import '../data/model/tarjeta_model.dart';
import '../data/model/prestamo_model.dart';
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
      GoRoute(
        path: '/operaciones',
        builder: (context, state) => const OperacionesScreen(),
      ),
      GoRoute(
        path: '/mas',
        builder: (context, state) => const MasScreen(),
      ),
      GoRoute(
        path: '/perfil',
        builder: (context, state) => const PerfilScreen(),
      ),
      GoRoute(
        path: '/notificaciones',
        builder: (context, state) => const NotificacionesScreen(),
      ),
      GoRoute(
        path: '/ahorro',
        builder: (context, state) => const AhorroScreen(),
      ),
      GoRoute(
        path: '/seguros',
        builder: (context, state) => const SegurosScreen(),
      ),
      GoRoute(
        path: '/inversiones',
        builder: (context, state) => const InversionesScreen(),
      ),
      GoRoute(
        path: '/puntos',
        builder: (context, state) => const ScotiaPuntosScreen(),
      ),
      GoRoute(
        path: '/msi',
        builder: (context, state) => const MesesSinInteresesScreen(),
      ),
      GoRoute(
        path: '/pagos',
        builder: (context, state) => const PagosScreen(),
      ),
      GoRoute(
        path: '/transferencias',
        builder: (context, state) => const TransferenciasScreen(),
      ),
      GoRoute(
        path: '/divisas',
        builder: (context, state) => const CambioDivisasScreen(),
      ),
      GoRoute(
        path: '/prestamos',
        builder: (context, state) => const PrestamosScreen(),
      ),
      GoRoute(
        path: '/prestamo-detalle',
        builder: (context, state) {
          final prestamo = state.extra as Prestamo;
          return PrestamoDetalleScreen(prestamo: prestamo);
        },
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
