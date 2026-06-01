import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/transferencia_model.dart';
import '../repository/transferencia_repository.dart';

class SupabaseTransferenciaRepository implements TransferenciaRepository {
  final SupabaseClient _client;

  SupabaseTransferenciaRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<void> realizarTransferencia(Transferencia transferencia) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Insertar la transferencia en la base de datos
      await _client.from('transferencias').insert({
        'user_id': userId,
        'cuenta_origen_id': transferencia.cuentaOrigenId,
        'tipo': transferencia.tipo,
        'banco_destino': transferencia.bancoDestino,
        'cuenta_destino': transferencia.cuentaDestino,
        'nombre_destino': transferencia.nombreDestino,
        'monto': transferencia.monto,
        'moneda': transferencia.moneda,
        'tipo_cambio': transferencia.tipoCambio,
        'comision': transferencia.comision,
        'estado': transferencia.estado,
        'referencia': transferencia.referencia,
      });

      // 2. Si la transferencia tiene cuenta de origen, descontar el saldo
      if (transferencia.cuentaOrigenId != null) {
        // Obtener cuenta actual
        final cuentaResponse = await _client
            .from('cuentas')
            .select('saldo')
            .eq('id', transferencia.cuentaOrigenId!)
            .single();

        final saldoActual = (cuentaResponse['saldo'] as num).toDouble();
        final nuevoSaldo = saldoActual - transferencia.monto;

        if (nuevoSaldo < 0) {
          throw Exception('Saldo insuficiente en la cuenta de origen.');
        }

        // Actualizar el saldo de la cuenta origen
        await _client
            .from('cuentas')
            .update({'saldo': nuevoSaldo})
            .eq('id', transferencia.cuentaOrigenId!);

        // 3. Registrar en la tabla transacciones de manera histórica para que se visualice en "Últimos Movimientos"
        await _client.from('transacciones').insert({
          'user_id': userId,
          'cuenta_id': transferencia.cuentaOrigenId,
          'tipo': 'debito',
          'descripcion': 'Transf. a ${transferencia.nombreDestino}',
          'monto': -transferencia.monto, // Negativo para egresos
          'moneda': transferencia.moneda,
        });
      }
    } catch (e) {
      throw Exception('Fallo al procesar la transferencia: $e');
    }
  }

  @override
  Future<List<Transferencia>> getTransferencias() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('transferencias')
          .select()
          .eq('user_id', userId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Transferencia.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener transferencias: $e');
    }
  }
}
