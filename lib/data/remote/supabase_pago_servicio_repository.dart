import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/pago_servicio_model.dart';
import '../repository/pago_servicio_repository.dart';

class SupabasePagoServicioRepository implements PagoServicioRepository {
  final SupabaseClient _client;

  SupabasePagoServicioRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<void> pagarServicio(PagoServicio pago) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Insertar el registro de pago de servicio
      await _client.from('pagos_servicios').insert({
        'user_id': userId,
        'cuenta_id': pago.cuentaId,
        'tarjeta_id': pago.tarjetaId,
        'servicio': pago.servicio,
        'proveedor': pago.proveedor,
        'numero_contrato': pago.numeroContrato,
        'monto': pago.monto,
        'estado': pago.estado,
        'canal': pago.canal,
      });

      // 2. Si se pagó con una cuenta de ahorro, descontar el saldo
      if (pago.cuentaId != null) {
        final cuentaResponse = await _client
            .from('cuentas')
            .select('saldo, numero_cuenta')
            .eq('id', pago.cuentaId!)
            .single();

        final saldoActual = (cuentaResponse['saldo'] as num).toDouble();
        final nuevoSaldo = saldoActual - pago.monto;

        if (nuevoSaldo < 0) {
          throw Exception('Saldo insuficiente en la cuenta de ahorros seleccionada.');
        }

        await _client
            .from('cuentas')
            .update({'saldo': nuevoSaldo})
            .eq('id', pago.cuentaId!);

        // Registrar en historial de transacciones
        await _client.from('transacciones').insert({
          'user_id': userId,
          'cuenta_id': pago.cuentaId,
          'tipo': 'debito',
          'descripcion': 'Pago de ${pago.servicio.toUpperCase()} - ${pago.proveedor}',
          'monto': -pago.monto,
          'moneda': 'PEN',
        });
      }

      // 3. Si se pagó con una tarjeta de crédito, actualizar su saldo disponible
      if (pago.tarjetaId != null) {
        final tarjetaResponse = await _client
            .from('tarjetas')
            .select('tipo, saldo_disponible, numero_enmascarado')
            .eq('id', pago.tarjetaId!)
            .single();

        final tipo = tarjetaResponse['tipo']?.toString();
        
        if (tipo == 'credito') {
          final saldoDisp = (tarjetaResponse['saldo_disponible'] as num?)?.toDouble() ?? 0.0;
          final nuevoSaldoDisp = saldoDisp - pago.monto;

          if (nuevoSaldoDisp < 0) {
            throw Exception('Línea de crédito insuficiente en la tarjeta seleccionada.');
          }

          await _client
              .from('tarjetas')
              .update({'saldo_disponible': nuevoSaldoDisp})
              .eq('id', pago.tarjetaId!);
        } else {
          // Si es débito y está vinculada a una cuenta, la UI nos debe haber mandado la cuentaId.
          // Si no, podríamos fallar o buscar la cuenta vinculada, pero por seguridad asumimos que es crédito.
        }
      }
    } catch (e) {
      throw Exception('Fallo al procesar el pago de servicio: $e');
    }
  }

  @override
  Future<List<PagoServicio>> getPagosServicios() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('pagos_servicios')
          .select()
          .eq('user_id', userId)
          .order('fecha', ascending: false);

      return (response as List<dynamic>)
          .map((json) => PagoServicio.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener pagos de servicios: $e');
    }
  }
}
