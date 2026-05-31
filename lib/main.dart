import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clientes_scotiabank/ui/theme/app_theme.dart';
import 'package:clientes_scotiabank/navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Cargar variables de entorno (no fallará si el archivo no existe en producción)
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("No se encontró el archivo .env, usando variables del sistema o hardcodeadas.");
  }

  String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (supabaseUrl.isEmpty || supabaseUrl.contains('\\n')) {
    supabaseUrl = 'https://tbhodzszudfnhrvwwmyb.supabase.co';
  }
  if (supabaseAnonKey.isEmpty) {
    supabaseAnonKey = 'sb_publishable_7FSnuZ0iI1LGP2v2pWGG5Q_S6lcqHuv';
  }

  // Inicializar Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // ¡AQUÍ ESTÁ LA SOLUCIÓN AL ERROR! Envolvemos la app en ProviderScope
  runApp(const ProviderScope(child: MyApp()));
}

// MyApp debe ser ConsumerWidget para poder leer el router de Riverpod
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el router que configuramos previamente
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Clientes Scotiabank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter, // Usamos GoRouter para la navegación
    );
  }
}
