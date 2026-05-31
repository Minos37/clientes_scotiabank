import 'package:flutter/material.dart';

class AppTheme {
  // Tema Claro
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      
      // El fondo principal de las pantallas
      scaffoldBackgroundColor: const Color(0xFFF4F4F4), // Gris muy claro para contraste
      
      // Color principal (Rojo Scotiabank)
      primaryColor: const Color(0xFFED0006),
      
      // Configuración de los colores base
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFED0006), // Rojo para elementos interactivos
        surface: Colors.white, // Para tarjetas (Cards) y menús
      ),

      // Estilo de las tarjetas (Cards de cuentas)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Tema Oscuro
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      
      // El fondo principal de las pantallas
      scaffoldBackgroundColor: const Color(0xFF121212), 
      
      // Color principal (Rojo)
      primaryColor: const Color(0xFFED0006),
      
      // Configuración de los colores base
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFFED0006), // Rojo para elementos interactivos
        surface: Color(0xFF1E1E1E), // Para tarjetas (Cards) y menús
      ),

      // Estilo de las tarjetas (Cards de cuentas)
      cardTheme: CardThemeData(
        color: const Color(0xFF1E1E1E),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}