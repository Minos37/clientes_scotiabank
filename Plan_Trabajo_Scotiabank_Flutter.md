# Plan de Trabajo Meticuloso - App Financiera Scotiabank (Flutter + VS Code)

## 1. Objetivo General
Desarrollar una aplicación financiera basada en la base de datos `db_scotiabank.sql` utilizando Flutter, VS Code y Supabase, siguiendo la arquitectura:

```text
lib/
├── data
│   ├── local
│   ├── model
│   ├── remote
│   └── repository
├── main.dart
├── navigation
└── ui
    ├── components
    ├── screens
    ├── theme
    └── viewmodel
```

---

# FASE 1 - ANÁLISIS Y PLANIFICACIÓN

## Paso 1.1 - Revisar el modelo de negocio
Módulos identificados:

1. Cuentas y ahorro
2. Tarjetas y medios de pago
3. Préstamos y créditos
4. Inversiones
5. Seguros
6. Servicios digitales
7. Solicitudes
8. Notificaciones

---

## Paso 1.2 - Analizar la base de datos

### Tablas detectadas

### Cuentas y Ahorro
- cuentas
- cuentas_ahorro
- transacciones

### Tarjetas
- tarjetas
- scotia_puntos
- meses_sin_intereses
- pagos_servicios
- transferencias
- cambio_divisas

### Préstamos
- prestamos
- cuotas_prestamo

### Inversiones
- depositos_plazo
- fondos_mutuos
- scotia_bolsa

### Seguros
- seguros
- siniestros

### Sistema
- solicitudes
- notificaciones

---

# FASE 2 - CONFIGURACIÓN DEL PROYECTO

## Paso 2.1 - Crear proyecto

```bash
flutter create scotiabank_app
```

---

## Paso 2.2 - Dependencias

```yaml
supabase_flutter:
flutter_riverpod:
go_router:
freezed_annotation:
json_annotation:
dio:
connectivity_plus:
shared_preferences:
flutter_secure_storage:
intl:
cached_network_image:
flutter_svg:
```

Dev dependencies:

```yaml
build_runner:
freezed:
json_serializable:
```

---

## Paso 2.3 - Crear estructura base

```text
lib/
├── data
│   ├── local
│   ├── model
│   ├── remote
│   └── repository
├── navigation
├── ui
│   ├── components
│   ├── screens
│   ├── theme
│   └── viewmodel
└── main.dart
```

---

# FASE 3 - CONFIGURACIÓN DE SUPABASE

## Paso 3.1
Crear proyecto Supabase.

## Paso 3.2
Ejecutar script db_scotiabank.sql.

## Paso 3.3
Configurar Auth.

Métodos:

- Email
- Google
- Apple

---

## Paso 3.4

Crear:

```text
data/remote/supabase_client.dart
```

Responsabilidad:

- Singleton
- Inicialización
- Manejo de sesión

---

# FASE 4 - CAPA DATA

# MODELS

Crear modelos para cada tabla.

## Accounts

```text
cuenta_model.dart
cuenta_ahorro_model.dart
transaccion_model.dart
```

## Cards

```text
tarjeta_model.dart
scotia_puntos_model.dart
meses_sin_intereses_model.dart
```

## Payments

```text
pago_servicio_model.dart
transferencia_model.dart
cambio_divisa_model.dart
```

## Loans

```text
prestamo_model.dart
cuota_prestamo_model.dart
```

## Investments

```text
deposito_plazo_model.dart
fondo_mutuo_model.dart
scotia_bolsa_model.dart
```

## Insurance

```text
seguro_model.dart
siniestro_model.dart
```

## System

```text
solicitud_model.dart
notificacion_model.dart
```

---

# FASE 5 - REMOTE DATASOURCES

Crear datasource por módulo.

```text
data/remote/
```

### auth_remote_datasource.dart
- login
- register
- logout

### cuentas_remote_datasource.dart
- obtener cuentas
- movimientos
- ahorro

### tarjetas_remote_datasource.dart
- tarjetas
- puntos
- promociones

### prestamos_remote_datasource.dart
- préstamos
- cuotas

### inversiones_remote_datasource.dart
- fondos
- depósitos

### seguros_remote_datasource.dart
- seguros
- siniestros

### servicios_remote_datasource.dart
- pagos
- transferencias
- cambio divisas

---

# FASE 6 - REPOSITORIES

## Repositories

```text
auth_repository.dart
cuentas_repository.dart
tarjetas_repository.dart
prestamos_repository.dart
inversiones_repository.dart
seguros_repository.dart
servicios_repository.dart
notificaciones_repository.dart
```

Responsabilidad:

- Consumir datasource
- Mapear modelos
- Manejar errores

---

# FASE 7 - VIEWMODELS

```text
ui/viewmodel/
```

## Auth

```text
auth_viewmodel.dart
```

## Dashboard

```text
home_viewmodel.dart
```

## Cuentas

```text
cuentas_viewmodel.dart
transacciones_viewmodel.dart
ahorro_viewmodel.dart
```

## Tarjetas

```text
tarjetas_viewmodel.dart
scotia_puntos_viewmodel.dart
```

## Préstamos

```text
prestamos_viewmodel.dart
```

## Inversiones

```text
inversiones_viewmodel.dart
```

## Seguros

```text
seguros_viewmodel.dart
```

## Servicios

```text
pagos_viewmodel.dart
transferencias_viewmodel.dart
divisas_viewmodel.dart
```

---

# FASE 8 - NAVEGACIÓN

Implementar GoRouter.

```text
navigation/
```

Rutas:

```text
/
/login
/register
/home
/cuentas
/cuenta-detalle
/transacciones
/tarjetas
/puntos
/prestamos
/prestamo-detalle
/inversiones
/fondos-mutuos
/depositos
/seguros
/transferencias
/pagos
/divisas
/notificaciones
/perfil
```

---

# FASE 9 - UI SCREENS

## Autenticación

```text
login_screen.dart
register_screen.dart
splash_screen.dart
```

## Home

```text
home_screen.dart
```

Widgets:

- saldo total
- resumen financiero
- accesos rápidos
- notificaciones

---

## Cuentas

```text
cuentas_screen.dart
cuenta_detalle_screen.dart
transacciones_screen.dart
ahorro_screen.dart
```

Funciones:

- visualizar cuentas
- movimientos
- ahorro programado

---

## Tarjetas

```text
tarjetas_screen.dart
scotia_puntos_screen.dart
beneficios_screen.dart
```

Funciones:

- ver tarjetas
- puntos acumulados
- promociones

---

## Préstamos

```text
prestamos_screen.dart
prestamo_detalle_screen.dart
cuotas_screen.dart
```

---

## Inversiones

```text
inversiones_screen.dart
depositos_screen.dart
fondos_mutuos_screen.dart
bolsa_screen.dart
```

---

## Seguros

```text
seguros_screen.dart
siniestros_screen.dart
```

---

## Servicios

```text
pagos_screen.dart
transferencias_screen.dart
cambio_divisas_screen.dart
```

---

# FASE 10 - COMPONENTES REUTILIZABLES

```text
ui/components/
```

## Cards

```text
account_card.dart
credit_card_widget.dart
loan_card.dart
investment_card.dart
insurance_card.dart
```

## Inputs

```text
custom_textfield.dart
currency_input.dart
```

## Botones

```text
primary_button.dart
secondary_button.dart
```

## Estados

```text
loading_widget.dart
error_widget.dart
empty_widget.dart
```

---

# FASE 11 - FUNCIONALIDADES PRIORITARIAS MVP

## Sprint 1
- Login
- Registro
- Home
- Cuentas
- Transacciones

## Sprint 2
- Tarjetas
- Scotia Puntos
- Pagos

## Sprint 3
- Transferencias
- Cambio de divisas
- Notificaciones

## Sprint 4
- Préstamos
- Cuotas

## Sprint 5
- Inversiones

## Sprint 6
- Seguros

---

# FASE 12 - SEGURIDAD

Implementar:

- JWT Supabase
- Secure Storage
- Refresh Token
- Control de sesión
- Biometría
- Validación de formularios
- Manejo de permisos

---

# FASE 13 - TESTING

## Unit Tests

Repositories
ViewModels
Helpers

## Widget Tests

Pantallas críticas

## Integration Tests

Login
Transferencias
Pagos
Préstamos

---

# FASE 14 - DESPLIEGUE

## Android

```bash
flutter build apk --release
```

## App Bundle

```bash
flutter build appbundle
```

## iOS

```bash
flutter build ios --release
```

---

# ORDEN RECOMENDADO DE DESARROLLO

1. Supabase
2. Auth
3. Models
4. Datasources
5. Repositories
6. Home Dashboard
7. Cuentas
8. Transacciones
9. Tarjetas
10. Pagos
11. Transferencias
12. Divisas
13. Préstamos
14. Inversiones
15. Seguros
16. Notificaciones
17. Testing
18. Release

Este orden minimiza dependencias y permite tener un MVP funcional desde las primeras iteraciones.
