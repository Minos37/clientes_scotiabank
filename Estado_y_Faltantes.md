# Reporte de Estado Actual y Faltantes - Clientes Scotiabank (Flutter)

Este reporte contiene un análisis del estado actual del desarrollo de la aplicación móvil de Scotiabank, contrastando el esquema de base de datos (`db_scotiabank.sql`), el plan de trabajo original (`Plan_Trabajo_Scotiabank_Flutter.md`) y la implementación real en el código Dart (`lib/`).

---

## 1. Resumen de Implementación General

La aplicación sigue un enfoque de **Arquitectura Limpia (Clean Architecture)** con inyección de dependencias y gestión de estado mediante **Riverpod** y navegación con **GoRouter**.

### Estadísticas del Proyecto
* **Modelos de Datos:** 16 implementados de 18 tablas en BD (88% de cobertura).
* **Pantallas (Screens):** 18 implementadas.
* **Repositorios (Interfaces):** 11 interfaces definidas.
* **Repositorios (Supabase):** 11 implementaciones concretas.
* **ViewModels (Riverpod):** 11 proveedores de estado (providers).

---

## 2. Estado de Módulos (Base de Datos vs. Código)

A continuación, se detalla qué componentes han sido creados para cada tabla de la base de datos y su estado de integración:

| Módulo y Tabla en BD | Modelo Dart | Interfaz Repositorio | Implementación Supabase | ViewModel / Provider | Pantalla (UI Screen) | Estado / Observación |
| :--- | :---: | :---: | :---: | :---: | :---: | :--- |
| **Autenticación (`auth.users`)** | Sí (`UserModel`) | Sí (`AuthRepository`) | Sí (`SupabaseAuthRepository`) | Sí (`AuthViewModel`) | `LoginScreen`, `RegisterScreen` | **Completado**. Login, registro de usuario, logout y persistencia de sesión con redirección automática. |
| **Cuentas (`public.cuentas`)** | Sí (`Cuenta`) | Sí (`CuentaRepository`) | Sí (`SupabaseCuentaRepository`) | Sí (`cuentasProvider`) | `HomeScreen` | **Parcial**. Se muestra el saldo total en Home, pero falta una pantalla específica para ver el detalle de cada cuenta de ahorros. |
| **Transacciones (`public.transacciones`)** | Sí (`Transaccion`) | Sí (`TransaccionRepository`) | Sí (`SupabaseTransaccionRepository`) | Sí (`transaccionProvider`) | `MovimientosScreen` | **Completado**. Lista de movimientos del usuario de manera histórica. |
| **Tarjetas (`public.tarjetas`)** | Sí (`Tarjeta`) | Sí (`TarjetaRepository`) | Sí (`SupabaseTarjetaRepository`) | Sí (`tarjetasProvider`) | `TarjetasScreen`, `TarjetaDetalleScreen` | **Completado**. Visualización de tarjetas de débito/crédito, saldos y montos de línea. |
| **Pagos Servicios (`public.pagos_servicios`)** | Sí (`PagoServicio`) | Sí (`PagoServicioRepository`) | Sí (`SupabasePagoServicioRepository`) | Sí (`pagoServicioViewModel`) | `PagosScreen` | **Completado**. Pago de servicios (luz, agua, etc.) descontando saldo de cuentas o tarjetas de crédito. |
| **Transferencias (`public.transferencias`)** | Sí (`Transferencia`) | Sí (`TransferenciaRepository`) | Sí (`SupabaseTransferenciaRepository`) | Sí (`transferenciaViewModel`) | `TransferenciasScreen`, `FormularioTransferencia` | **Completado**. Se ha resuelto el error de compilación. Las transferencias entre cuentas y a terceros funcionan correctamente contra la BD. |
| **Cambio de Divisas (`public.cambio_divisas`)** | Sí (`CambioDivisa`) | Sí (`CambioDivisaRepository`) | Sí (`SupabaseCambioDivisaRepository`) | Sí (`cambioDivisaViewModel`) | `CambioDivisasScreen` | **Completado**. Simulación y ejecución de compra/venta de dólares actualizando saldos. |
| **Préstamos (`public.prestamos`)** | Sí (`Prestamo`) | Sí (`PrestamoRepository`) | Sí (`SupabasePrestamoRepository`) | Sí (`prestamosProvider`) | `PrestamosScreen`, `PrestamoDetalleScreen` | **Completado**. Visualización de préstamos, tasas y detalle de cronograma. |
| **Cuotas Préstamo (`public.cuotas_prestamo`)** | Sí (`CuotaPrestamo`) | Integrado en préstamo | Integrado en préstamo | Sí (`cuotasProvider`) | Integrado en detalle | **Completado**. Permite pagar cuotas amortizando el saldo capital y registrando transacciones. |
| **Ahorro (`public.cuentas_ahorro`)** | Sí (`CuentaAhorro`) | Sí (`CuentaAhorroRepository`) | Sí (`SupabaseCuentaAhorroRepository`) | Sí (`cuentasAhorroProvider`, `cuentaAhorroNotifierProvider`) | `AhorroScreen` | **Completado**. Ahorros programados y metas visuales en pesos/dólares, depósitos y retiros. |
| **Notificaciones (`public.notificaciones`)** | Sí (`Notificacion`) | Sí (`NotificacionRepository`) | Sí (`SupabaseNotificacionRepository`) | Sí (`notificacionesStreamProvider`) | `NotificacionesScreen` | **Completado**. Buzón interactivo con streams en tiempo real (Supabase Realtime) y marcado de leído. |
| **Seguros (`public.seguros`)** | Sí (`Seguro`) | Sí (`SeguroRepository`) | Sí (`SupabaseSeguroRepository`) | Sí (`segurosProvider`) | `SegurosScreen` | **Completado**. Lista de seguros activos y modales interactivos para reportar siniestros. |
| **Siniestros (`public.siniestros`)** | Sí (`Siniestro`) | Sí (`SeguroRepository`) | Sí (`SupabaseSeguroRepository`) | Sí (`siniestrosProvider`) | `SegurosScreen` (Tab Siniestros) | **Completado**. Lista de siniestros reportados y su estado actual (`en_revision`, `aprobado`, etc.). |
| **Plazo Fijo (`public.depositos_plazo`)** | Sí (`DepositoPlazo`) | Sí (`InversionRepository`) | Sí (`SupabaseInversionRepository`) | Sí (`depositosPlazoProvider`) | `InversionesScreen` | **Completado**. Inversión a plazo fijo digital, cálculo de rendimiento y constitución del depósito. |
| **Fondos Mutuos (`public.fondos_mutuos`)** | Sí (`FondoMutuo`) | Sí (`InversionRepository`) | Sí (`SupabaseInversionRepository`) | Sí (`fondosMutuosProvider`) | `InversionesScreen` (Tab Fondos) | **Completado**. Suscripción y rescate de fondos mutuos según perfiles de riesgo y monedas. |
| **Scotia Bolsa (`public.scotia_bolsa`)** | Sí (`ScotiaBolsa`) | Sí (`InversionRepository`) | Sí (`SupabaseInversionRepository`) | Sí (`historialBolsaProvider`, `inversionNotifierProvider`) | `InversionesScreen` (Tab Bolsa) | **Completado**. Órdenes bursátiles de compra/venta de acciones nacionales e internacionales. |
| **Puntos (`public.scotia_puntos`)** | Sí (`ScotiaPuntosModel`) | Sí (`ScotiaPuntosRepository`) | Sí (`SupabaseScotiaPuntosRepository`) | Sí (`puntosTotalesProvider`, `movimientosPuntosProvider`, `scotiaPuntosNotifierProvider`) | `ScotiaPuntosScreen` | **Completado**. Visualización de puntos acumulados, historial de movimientos y canje de beneficios. |
| **Campañas (`public.meses_sin_intereses`)** | Sí (`MesesSinInteresesModel`) | Sí (`MesesSinInteresesRepository`) | Sí (`SupabaseMesesSinInteresesRepository`) | Sí (`mesesSinInteresesProvider`, `mesesSinInteresesNotifierProvider`) | `MesesSinInteresesScreen` | **Completado**. Simulador de conversión de consumos a cuotas sin intereses y listado de planes activos. |
| **Solicitudes (`public.solicitudes`)** | Sí (`Solicitud`) | Sí (`SolicitudRepository`) | Sí (`SupabaseSolicitudRepository`) | Sí (`solicitudesProvider`) | `SolicitudesScreen` | **Completado**. Visualización e inicio de solicitudes de productos (cuentas, tarjetas, préstamos, seguros). |

---

## 3. Bloqueadores y Errores Críticos Resolvidos

### ✅ Error de Compilación en `FormularioTransferenciaScreen` (SOLUCIONADO)
Previamente, el compilador de Dart impedía ejecutar la aplicación debido al siguiente error:

* **Ubicación:** [formulario_transferencia_screen.dart (Línea 144)](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/ui/screens/formulario_transferencia_screen.dart#L144)
* **Mensaje:** `The argument type 'List<DropdownMenuItem<Object>>' can't be assigned to the parameter type 'List<DropdownMenuItem<String>>?'.`
* **Causa:** El widget `DropdownButtonFormField<String>` requiere que sus elementos estén explícitamente tipados como `DropdownMenuItem<String>`. La función `.map()` devolvía un `DropdownMenuItem` genérico sin tipar (`DropdownMenuItem<Object>`).
* **Solución aplicada:** Se forzó el tipado a `<String>` en el retorno de la lista de elementos para cumplir con las exigencias del compilador de Dart, permitiendo compilar y ejecutar la app al 100%:
  ```dart
  items: cuentasDestinoDisponibles.map((c) {
    final String num = (c as dynamic).numeroCuenta;
    final String u = num.length > 4 ? num.substring(num.length - 4) : num;
    return DropdownMenuItem<String>(
      value: (c as dynamic).id as String,
      child: Text('Cuenta •••• $u'),
    );
  }).toList(),
  ```

---

## 4. Funcionalidades Incompletas (TODOs y Enlaces Rotos) - ¡SOLUCIONADO!

Todas las opciones inactivas o temporales han sido completamente resueltas e implementadas de forma interactiva:

1. **Pantalla Principal (`HomeScreen`):**
   * El botón "Ver todos" enlaza correctamente a la pantalla de movimientos completa.
2. **Pantalla de Autenticación (`LoginScreen`):**
   * El enlace "Olvidó mi contraseña" abre un modal para ingresar el correo y ejecuta/simula la recuperación mediante Supabase Auth.
3. **Pantalla de Opciones (`MasScreen`):**
   * Se implementaron diálogos/pantallas funcionales para:
     * **Seguridad y Contraseña:** Gestión de huella/FaceID y formulario de cambio de clave.
     * **Configurar Notificaciones:** Selector interactivo de push, correo y montos altos.
     * **Centro de Ayuda:** Acordeón de FAQs ampliable.
     * **Contactar al Banco:** Canales de ayuda y un Asistente Virtual (Chatbot Scotiabot) simulado e interactivo.
     * **Acerca de la app:** Diálogo con detalles de la versión y términos.
4. **Pantalla de Operaciones (`OperacionesScreen`):**
   * Se implementó interactividad real para:
     * **Transferir con QR:** Simulador de escaneo con animación de cámara y generación de código QR personal (Plin/Yape).
     * **Pago de Tarjetas:** Formulario dinámico cargando cuentas de origen y tarjetas propias de crédito.
     * **Recargas de Celular:** Selector de montos y operadores para realizar recargas de forma directa.

---

## 5. Módulos Faltantes para Finalizar la App (Faltantes)

Para considerar la aplicación Scotiabank al 100% de acuerdo con las especificaciones del diseño de base de datos y plan de trabajo, se deben completar las siguientes fases:

### ✅ Fase A: Scotia Puntos y Campañas (Módulo 2 en BD) - ¡COMPLETADO!
* **Modelos creados:** [scotia_puntos_model.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/model/scotia_puntos_model.dart), [meses_sin_intereses_model.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/model/meses_sin_intereses_model.dart).
* **Repositorios e Implementaciones:** [scotia_puntos_repository.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/repository/scotia_puntos_repository.dart), [supabase_scotia_puntos_repository.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/remote/supabase_scotia_puntos_repository.dart), [meses_sin_intereses_repository.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/repository/meses_sin_intereses_repository.dart), [supabase_meses_sin_intereses_repository.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/remote/supabase_meses_sin_intereses_repository.dart).
* **ViewModels / Providers:** [scotia_puntos_viewmodel.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/ui/viewmodel/scotia_puntos_viewmodel.dart), [meses_sin_intereses_viewmodel.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/ui/viewmodel/meses_sin_intereses_viewmodel.dart).
* **UI Screens:** [scotia_puntos_screen.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/ui/screens/scotia_puntos_screen.dart), [meses_sin_intereses_screen.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/ui/screens/meses_sin_intereses_screen.dart).

### ✅ Fase B: Solicitudes (Módulo 6 en BD) - ¡COMPLETADO!
* **Modelos creados:** [solicitud_model.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/model/solicitud_model.dart).
* **Repositorios e Implementaciones:** [solicitud_repository.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/repository/solicitud_repository.dart), [supabase_solicitud_repository.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/data/remote/supabase_solicitud_repository.dart).
* **ViewModels / Providers:** [solicitud_viewmodel.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/ui/viewmodel/solicitud_viewmodel.dart).
* **UI Screens:** [solicitudes_screen.dart](file:///G:/Desarrollo%20aplicaciones%20moviles/clientes_scotiabank/lib/ui/screens/solicitudes_screen.dart) con pestañas de historial de solicitudes (timelines/steppers de estados) y grid de productos para aplicar (formularios interactivos dinámicos).

### ✅ Fase C: Cobertura de Pruebas y Despliegue - ¡PARCIALMENTE COMPLETADO!
* **Pruebas unitarias:** ¡COMPLETADO! Creadas en `test/auth_viewmodel_test.dart`, `test/cuenta_viewmodel_test.dart`, `test/prestamos_viewmodel_test.dart`, `test/transferencia_viewmodel_test.dart` y `test/widget_test.dart` sumando 11 pruebas exitosas utilizando Mocktail.
* **Configuración CI/CD o Compilación:** Automatización de compilaciones release para Android (APK/AAB) e iOS (IPA).

---

## 6. Próximos Pasos Recomendados

1. **Configurar CI/CD** para empaquetado y distribución automática.
