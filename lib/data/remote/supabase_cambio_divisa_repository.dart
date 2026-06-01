import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/cambio_divisa_model.dart';
import '../repository/cambio_divisa_repository.dart';

class SupabaseCambioDivisaRepository implements CambioDivisaRepository {
  final SupabaseClient _client;

  SupabaseCambioDivisaRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<void> realizarCambio(CambioDivisa cambio, {String? cuentaDestinoId}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Insertar el registro del cambio de divisas
      await _client.from('cambio_divisas').insert({
        'user_id': userId,
        'cuenta_id': cambio.cuentaId,
        'operacion': cambio.operacion,
        'monto_origen': cambio.montoOrigen,
        'moneda_origen': cambio.monedaOrigen,
        'tipo_cambio': cambio.tipoCambio,
        'monto_destino': cambio.montoDestino,
        'moneda_destino': cambio.monedaDestino,
        'canal': cambio.canal,
      });

      // 2. Si hay cuenta origen, descontar el monto de origen
      if (cambio.cuentaId != null) {
        final cuentaResponse = await _client
            .from('cuentas')
            .select('saldo, moneda')
            .eq('id', cambio.cuentaId!)
            .single();

        final saldoActual = (cuentaResponse['saldo'] as num).toDouble();
        final nuevoSaldo = saldoActual - cambio.montoOrigen;

        if (nuevoSaldo < 0) {
          throw Exception('Saldo insuficiente en la cuenta de origen.');
        }

        // Actualizar cuenta origen
        await _client
            .from('cuentas')
            .update({'saldo': nuevoSaldo})
            .eq('id', cambio.cuentaId!);

        // Registrar transacción de egreso
        await _client.from('transacciones').insert({
          'user_id': userId,
          'cuenta_id': cambio.cuentaId,
          'tipo': 'debito',
          'descripcion': 'Cambio Divisas: Venta de ${cambio.monedaOrigen}',
          'monto': -cambio.montoOrigen,
          'moneda': cambio.monedaOrigen,
        });
      }

      // 3. Si hay cuenta destino, abonar el monto de destino
      if (cuentaDestinoId != null) {
        final cuentaResponse = await _client
            .from('cuentas')
            .select('saldo, moneda')
            .eq('id', cuentaDestinoId)
            .single();

        final saldoActual = (cuentaResponse['saldo'] as num).toDouble();
        final nuevoSaldo = saldoActual + cambio.montoDestino;

        // Actualizar cuenta destino
        await _client
            .from('cuentas')
            .update({'saldo': nuevoSaldo})
            .eq('id', cuentaDestinoId);

        // Registrar transacción de ingreso
        await _client.from('transacciones').insert({
          'user_id': userId,
          'cuenta_id': cuentaDestinoId,
          'tipo': 'credito',
          'descripcion': 'Cambio Divisas: Compra de ${cambio.monedaDestino}',
          'monto': cambio.montoDestino,
          'moneda': cambio.monedaDestino,
        });
      }
    } catch (e) {
      throw Exception('Fallo al procesar el cambio de divisas: $e');
    }
  }

  @override
  Future<List<CambioDivisa>> getHistorialCambios() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('cambio_divisas')
          .select()
          .eq('user_id', userId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((json) => CambioDivisa.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener historial de cambios: $e');
    }
  }
}
