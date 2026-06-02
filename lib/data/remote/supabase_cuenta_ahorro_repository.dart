import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/cuenta_ahorro_model.dart';
import '../repository/cuenta_ahorro_repository.dart';

class SupabaseCuentaAhorroRepository implements CuentaAhorroRepository {
  final SupabaseClient _client;

  SupabaseCuentaAhorroRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<CuentaAhorro>> getCuentasAhorro() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('cuentas_ahorro')
          .select()
          .eq('user_id', userId);

      return (response as List<dynamic>)
          .map((json) => CuentaAhorro.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener cuentas de ahorro: $e');
    }
  }

  @override
  Future<void> crearCuentaAhorro(CuentaAhorro cuenta) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      await _client.from('cuentas_ahorro').insert({
        'user_id': userId,
        if (cuenta.cuentaId != null) 'cuenta_id': cuenta.cuentaId,
        'saldo': cuenta.saldo,
        'meta_ahorro': cuenta.metaAhorro,
        'tasa_interes': cuenta.tasaInteres,
        'moneda': cuenta.moneda,
      });
    } catch (e) {
      throw Exception('Error al crear cuenta de ahorro programado: $e');
    }
  }

  @override
  Future<void> ahorrarMonto(String cuentaAhorroId, double monto, String cuentaOrigenId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Obtener saldo de la cuenta de origen
      final cuentaOrigenResponse = await _client
          .from('cuentas')
          .select('saldo, moneda')
          .eq('id', cuentaOrigenId)
          .single();
      final saldoOrigen = (cuentaOrigenResponse['saldo'] as num).toDouble();
      final moneda = cuentaOrigenResponse['moneda']?.toString() ?? 'PEN';

      if (saldoOrigen < monto) {
        throw Exception('Saldo insuficiente en la cuenta de origen.');
      }

      // 2. Obtener saldo de la cuenta de ahorro
      final cuentaAhorroResponse = await _client
          .from('cuentas_ahorro')
          .select('saldo')
          .eq('id', cuentaAhorroId)
          .single();
      final saldoAhorro = (cuentaAhorroResponse['saldo'] as num).toDouble();

      // 3. Actualizar saldo origen
      await _client
          .from('cuentas')
          .update({'saldo': saldoOrigen - monto})
          .eq('id', cuentaOrigenId);

      // 4. Actualizar saldo ahorro
      await _client
          .from('cuentas_ahorro')
          .update({'saldo': saldoAhorro + monto})
          .eq('id', cuentaAhorroId);

      // 5. Registrar transacción en la cuenta origen
      await _client.from('transacciones').insert({
        'user_id': userId,
        'cuenta_id': cuentaOrigenId,
        'tipo': 'debito',
        'descripcion': 'Ahorro programado - Envío a Meta',
        'monto': -monto,
        'moneda': moneda,
      });

    } catch (e) {
      throw Exception('Fallo al ahorrar dinero: $e');
    }
  }

  @override
  Future<void> retirarMonto(String cuentaAhorroId, double monto, String cuentaDestinoId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Obtener saldo de la cuenta de ahorro
      final cuentaAhorroResponse = await _client
          .from('cuentas_ahorro')
          .select('saldo')
          .eq('id', cuentaAhorroId)
          .single();
      final saldoAhorro = (cuentaAhorroResponse['saldo'] as num).toDouble();

      if (saldoAhorro < monto) {
        throw Exception('Saldo insuficiente en tu cuenta de ahorro programado.');
      }

      // 2. Obtener saldo de la cuenta de destino
      final cuentaDestinoResponse = await _client
          .from('cuentas')
          .select('saldo, moneda')
          .eq('id', cuentaDestinoId)
          .single();
      final saldoDestino = (cuentaDestinoResponse['saldo'] as num).toDouble();
      final moneda = cuentaDestinoResponse['moneda']?.toString() ?? 'PEN';

      // 3. Actualizar saldo ahorro
      await _client
          .from('cuentas_ahorro')
          .update({'saldo': saldoAhorro - monto})
          .eq('id', cuentaAhorroId);

      // 4. Actualizar saldo destino
      await _client
          .from('cuentas')
          .update({'saldo': saldoDestino + monto})
          .eq('id', cuentaDestinoId);

      // 5. Registrar transacción en la cuenta destino
      await _client.from('transacciones').insert({
        'user_id': userId,
        'cuenta_id': cuentaDestinoId,
        'tipo': 'credito',
        'descripcion': 'Retiro de Ahorro programado - Liberar Meta',
        'monto': monto,
        'moneda': moneda,
      });

    } catch (e) {
      throw Exception('Fallo al retirar dinero: $e');
    }
  }
}
