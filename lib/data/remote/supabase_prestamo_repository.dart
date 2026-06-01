import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/prestamo_model.dart';
import '../model/cuota_prestamo_model.dart';
import '../repository/prestamo_repository.dart';

class SupabasePrestamoRepository implements PrestamoRepository {
  final SupabaseClient _client;

  SupabasePrestamoRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<Prestamo>> getPrestamos() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('prestamos')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => Prestamo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener préstamos de Supabase: $e');
    }
  }

  @override
  Future<List<CuotaPrestamo>> getCuotas(String prestamoId) async {
    try {
      final response = await _client
          .from('cuotas_prestamo')
          .select()
          .eq('prestamo_id', prestamoId)
          .order('numero_cuota', ascending: true);

      return (response as List<dynamic>)
          .map((json) => CuotaPrestamo.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener cuotas del préstamo: $e');
    }
  }

  @override
  Future<void> pagarCuota(String cuotaId, String cuentaId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado.');

    try {
      // 1. Obtener la cuota
      final cuotaResponse = await _client
          .from('cuotas_prestamo')
          .select()
          .eq('id', cuotaId)
          .single();
      final cuota = CuotaPrestamo.fromJson(cuotaResponse as Map<String, dynamic>);

      if (cuota.estado == 'pagada') {
        throw Exception('Esta cuota ya ha sido pagada.');
      }

      // 2. Obtener el saldo de la cuenta de ahorros
      final cuentaResponse = await _client
          .from('cuentas')
          .select('saldo, numero_cuenta')
          .eq('id', cuentaId)
          .single();
      final saldoActual = (cuentaResponse['saldo'] as num).toDouble();
      final nuevoSaldo = saldoActual - cuota.montoCuota;

      if (nuevoSaldo < 0) {
        throw Exception('Saldo insuficiente en la cuenta de ahorros seleccionada.');
      }

      // 3. Descontar el dinero de la cuenta de ahorros
      await _client
          .from('cuentas')
          .update({'saldo': nuevoSaldo})
          .eq('id', cuentaId);

      // 4. Actualizar la cuota a pagada
      await _client
          .from('cuotas_prestamo')
          .update({
            'estado': 'pagada',
            'fecha_pago': DateTime.now().toIso8601String().substring(0, 10), // AAAA-MM-DD
          })
          .eq('id', cuotaId);

      // 5. Actualizar el saldo capital del préstamo y la cantidad de cuotas pagadas
      final prestamoResponse = await _client
          .from('prestamos')
          .select()
          .eq('id', cuota.prestamoId)
          .single();
      final prestamo = Prestamo.fromJson(prestamoResponse as Map<String, dynamic>);

      final nuevasCuotasPagadas = prestamo.cuotasPagadas + 1;
      final nuevoSaldoCapital = prestamo.saldoCapital - cuota.capital;
      final nuevoEstado = nuevasCuotasPagadas >= prestamo.plazoMeses ? 'pagado' : 'activo';

      await _client
          .from('prestamos')
          .update({
            'cuotas_pagadas': nuevasCuotasPagadas,
            'saldo_capital': nuevoSaldoCapital < 0 ? 0.0 : nuevoSaldoCapital,
            'estado': nuevoEstado,
          })
          .eq('id', cuota.prestamoId);

      // 6. Registrar en el historial de transacciones de la cuenta
      await _client.from('transacciones').insert({
        'user_id': userId,
        'cuenta_id': cuentaId,
        'tipo': 'debito',
        'descripcion': 'Pago Cuota ${cuota.numeroCuota} - ${prestamo.tipoFormateado}',
        'monto': -cuota.montoCuota,
        'moneda': prestamo.moneda,
      });

    } catch (e) {
      throw Exception('Fallo al procesar el pago de la cuota: $e');
    }
  }
}
