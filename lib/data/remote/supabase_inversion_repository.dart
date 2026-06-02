import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/deposito_plazo_model.dart';
import '../model/fondo_mutuo_model.dart';
import '../model/scotia_bolsa_model.dart';
import '../repository/inversion_repository.dart';

class SupabaseInversionRepository implements InversionRepository {
  final SupabaseClient _client;

  SupabaseInversionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  // ── Plazo Fijo ───────
  @override
  Future<List<DepositoPlazo>> getDepositosPlazo() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('depositos_plazo')
          .select()
          .eq('user_id', userId)
          .order('fecha_inicio', ascending: false);

      return (response as List<dynamic>)
          .map((json) => DepositoPlazo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener depósitos a plazo de Supabase: $e');
    }
  }

  @override
  Future<void> crearDepositoPlazo(DepositoPlazo deposito, String cuentaOrigenId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Obtener saldo de la cuenta de origen
      final cuentaResponse = await _client
          .from('cuentas')
          .select('saldo')
          .eq('id', cuentaOrigenId)
          .single();
      final saldoActual = (cuentaResponse['saldo'] as num).toDouble();
      final nuevoSaldo = saldoActual - deposito.monto;

      if (nuevoSaldo < 0) {
        throw Exception('Saldo insuficiente en la cuenta seleccionada.');
      }

      // 2. Descontar el saldo de la cuenta origen
      await _client
          .from('cuentas')
          .update({'saldo': nuevoSaldo})
          .eq('id', cuentaOrigenId);

      // 3. Crear el depósito a plazo fijo
      await _client.from('depositos_plazo').insert({
        'user_id': userId,
        'cuenta_id': cuentaOrigenId,
        'monto': deposito.monto,
        'moneda': deposito.moneda,
        'plazo_dias': deposito.plazoDias,
        'tasa_anual': deposito.tasaAnual,
        'rendimiento': deposito.rendimiento,
        'fecha_inicio': deposito.fechaInicio.toIso8601String().substring(0, 10),
        'fecha_venc': deposito.fechaVenc.toIso8601String().substring(0, 10),
        'estado': 'activo',
        'renovacion_auto': deposito.renovacionAuto,
      });

      // 4. Registrar transacción
      await _client.from('transacciones').insert({
        'user_id': userId,
        'cuenta_id': cuentaOrigenId,
        'tipo': 'debito',
        'descripcion': 'Constitución Plazo Fijo ${deposito.plazoDias} días',
        'monto': -deposito.monto,
        'moneda': deposito.moneda,
      });

    } catch (e) {
      throw Exception('Error al constituir depósito a plazo: $e');
    }
  }

  // ── Fondos Mutuos ───────
  @override
  Future<List<FondoMutuo>> getFondosMutuos() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('fondos_mutuos')
          .select()
          .eq('user_id', userId)
          .order('fecha_inicio', ascending: false);

      return (response as List<dynamic>)
          .map((json) => FondoMutuo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener fondos mutuos de Supabase: $e');
    }
  }

  @override
  Future<void> suscribirFondoMutuo(FondoMutuo fondo, double monto, String cuentaOrigenId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Obtener saldo de la cuenta de origen
      final cuentaResponse = await _client
          .from('cuentas')
          .select('saldo')
          .eq('id', cuentaOrigenId)
          .single();
      final saldoActual = (cuentaResponse['saldo'] as num).toDouble();
      final nuevoSaldo = saldoActual - monto;

      if (nuevoSaldo < 0) {
        throw Exception('Saldo insuficiente para la suscripción del fondo.');
      }

      // 2. Descontar saldo
      await _client
          .from('cuentas')
          .update({'saldo': nuevoSaldo})
          .eq('id', cuentaOrigenId);

      // 3. Verificar si el usuario ya tiene este fondo
      final existResponse = await _client
          .from('fondos_mutuos')
          .select()
          .eq('user_id', userId)
          .eq('fondo', fondo.fondo)
          .eq('moneda', fondo.moneda)
          .eq('estado', 'activo')
          .maybeSingle();

      final double nuevasCuotas = monto / fondo.valorCuota;

      if (existResponse != null) {
        // Actualizar fondo existente
        final double saldoInvertido = (existResponse['monto_invertido'] as num).toDouble();
        final double cuotasActuales = (existResponse['cuotas'] as num).toDouble();

        await _client
            .from('fondos_mutuos')
            .update({
              'monto_invertido': saldoInvertido + monto,
              'cuotas': cuotasActuales + nuevasCuotas,
              'valor_actual': (cuotasActuales + nuevasCuotas) * fondo.valorCuota,
            })
            .eq('id', existResponse['id']);
      } else {
        // Suscribir fondo nuevo
        await _client.from('fondos_mutuos').insert({
          'user_id': userId,
          'fondo': fondo.fondo,
          'tipo_fondo': fondo.tipoFondo,
          'moneda': fondo.moneda,
          'monto_invertido': monto,
          'cuotas': nuevasCuotas,
          'valor_cuota': fondo.valorCuota,
          'valor_actual': monto,
          'rentabilidad': 0.0,
          'inversion_min': fondo.inversionMin,
          'estado': 'activo',
        });
      }

      // 4. Registrar transacción
      await _client.from('transacciones').insert({
        'user_id': userId,
        'cuenta_id': cuentaOrigenId,
        'tipo': 'debito',
        'descripcion': 'Suscripción Fondo: ${fondo.fondo}',
        'monto': -monto,
        'moneda': fondo.moneda,
      });

    } catch (e) {
      throw Exception('Fallo al suscribir fondo mutuo: $e');
    }
  }

  @override
  Future<void> rescatarFondoMutuo(String fondoId, double monto, String cuentaDestinoId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Obtener la posición del fondo
      final fondoResponse = await _client
          .from('fondos_mutuos')
          .select()
          .eq('id', fondoId)
          .single();
      final fondo = FondoMutuo.fromJson(fondoResponse as Map<String, dynamic>);

      final double valorPosicion = fondo.valorActual ?? (fondo.cuotas * fondo.valorCuota);
      if (valorPosicion < monto) {
        throw Exception('El monto a rescatar excede el valor actual de tu fondo.');
      }

      final double cuotasARescatar = monto / fondo.valorCuota;
      final double nuevasCuotas = fondo.cuotas - cuotasARescatar;
      final double nuevoMontoInvertido = fondo.montoInvertido - monto;
      final String nuevoEstado = nuevasCuotas <= 0.01 ? 'rescatado' : 'activo';

      // 2. Actualizar o cerrar la posición del fondo
      await _client
          .from('fondos_mutuos')
          .update({
            'cuotas': nuevasCuotas < 0 ? 0.0 : nuevasCuotas,
            'monto_invertido': nuevoMontoInvertido < 0 ? 0.0 : nuevoMontoInvertido,
            'valor_actual': nuevasCuotas * fondo.valorCuota,
            'estado': nuevoEstado,
          })
          .eq('id', fondoId);

      // 3. Incrementar el saldo de la cuenta destino
      final cuentaResponse = await _client
          .from('cuentas')
          .select('saldo')
          .eq('id', cuentaDestinoId)
          .single();
      final saldoActual = (cuentaResponse['saldo'] as num).toDouble();

      await _client
          .from('cuentas')
          .update({'saldo': saldoActual + monto})
          .eq('id', cuentaDestinoId);

      // 4. Registrar transacción
      await _client.from('transacciones').insert({
        'user_id': userId,
        'cuenta_id': cuentaDestinoId,
        'tipo': 'credito',
        'descripcion': 'Rescate Fondo: ${fondo.fondo}',
        'monto': monto,
        'moneda': fondo.moneda,
      });

    } catch (e) {
      throw Exception('Fallo al rescatar fondos mutuos: $e');
    }
  }

  // ── Scotia Bolsa ───────
  @override
  Future<List<ScotiaBolsa>> getHistorialBolsa() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('scotia_bolsa')
          .select()
          .eq('user_id', userId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((json) => ScotiaBolsa.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener operaciones bursátiles de Supabase: $e');
    }
  }

  @override
  Future<void> comprarAccion(ScotiaBolsa transaccion, String cuentaOrigenId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    final double costoTotal = transaccion.montoTotal + transaccion.comision;

    try {
      // 1. Obtener saldo cuenta origen
      final cuentaResponse = await _client
          .from('cuentas')
          .select('saldo')
          .eq('id', cuentaOrigenId)
          .single();
      final saldoActual = (cuentaResponse['saldo'] as num).toDouble();
      final nuevoSaldo = saldoActual - costoTotal;

      if (nuevoSaldo < 0) {
        throw Exception('Saldo insuficiente en la cuenta seleccionada.');
      }

      // 2. Descontar saldo
      await _client
          .from('cuentas')
          .update({'saldo': nuevoSaldo})
          .eq('id', cuentaOrigenId);

      // 3. Registrar compra bursátil
      await _client.from('scotia_bolsa').insert({
        'user_id': userId,
        'ticker': transaccion.ticker.toUpperCase(),
        'operacion': 'compra',
        'cantidad': transaccion.cantidad,
        'precio_unitario': transaccion.precioUnitario,
        'monto_total': transaccion.montoTotal,
        'moneda': transaccion.moneda,
        'comision': transaccion.comision,
        'estado': 'ejecutada',
      });

      // 4. Registrar transacción bancaria
      await _client.from('transacciones').insert({
        'user_id': userId,
        'cuenta_id': cuentaOrigenId,
        'tipo': 'debito',
        'descripcion': 'Scotia Bolsa: Compra ${transaccion.ticker}',
        'monto': -costoTotal,
        'moneda': transaccion.moneda,
      });

    } catch (e) {
      throw Exception('Error al realizar compra en Scotia Bolsa: $e');
    }
  }

  @override
  Future<void> venderAccion(ScotiaBolsa transaccion, String cuentaDestinoId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    final double netoRecibido = transaccion.montoTotal - transaccion.comision;

    try {
      // 1. Registrar venta bursátil
      await _client.from('scotia_bolsa').insert({
        'user_id': userId,
        'ticker': transaccion.ticker.toUpperCase(),
        'operacion': 'venta',
        'cantidad': transaccion.cantidad,
        'precio_unitario': transaccion.precioUnitario,
        'monto_total': transaccion.montoTotal,
        'moneda': transaccion.moneda,
        'comision': transaccion.comision,
        'estado': 'ejecutada',
      });

      // 2. Incrementar saldo cuenta destino
      final cuentaResponse = await _client
          .from('cuentas')
          .select('saldo')
          .eq('id', cuentaDestinoId)
          .single();
      final saldoActual = (cuentaResponse['saldo'] as num).toDouble();

      await _client
          .from('cuentas')
          .update({'saldo': saldoActual + netoRecibido})
          .eq('id', cuentaDestinoId);

      // 3. Registrar transacción bancaria
      await _client.from('transacciones').insert({
        'user_id': userId,
        'cuenta_id': cuentaDestinoId,
        'tipo': 'credito',
        'descripcion': 'Scotia Bolsa: Venta ${transaccion.ticker}',
        'monto': netoRecibido,
        'moneda': transaccion.moneda,
      });

    } catch (e) {
      throw Exception('Error al realizar venta en Scotia Bolsa: $e');
    }
  }
}
