import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/meses_sin_intereses_model.dart';
import '../repository/meses_sin_intereses_repository.dart';

class SupabaseMesesSinInteresesRepository implements MesesSinInteresesRepository {
  final SupabaseClient _client;

  SupabaseMesesSinInteresesRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<List<MesesSinInteresesModel>> getMesesSinIntereses() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('meses_sin_intereses')
          .select()
          .eq('user_id', userId)
          .order('fecha_inicio', ascending: false);

      return (response as List<dynamic>)
          .map((json) => MesesSinInteresesModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener compras de meses sin intereses: $e');
    }
  }

  @override
  Future<void> registrarCompraMSI({
    required String tarjetaId,
    required String comercio,
    required double montoTotal,
    required int plazoMeses,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Usuario no autenticado');

    try {
      // 1. Obtener los datos de la tarjeta de crédito
      final tarjetaResponse = await _client
          .from('tarjetas')
          .select()
          .eq('id', tarjetaId)
          .single();

      final tipo = tarjetaResponse['tipo']?.toString();
      if (tipo != 'credito') {
        throw Exception('La tarjeta seleccionada debe ser de crédito');
      }

      final double saldoDisponible = tarjetaResponse['saldo_disponible'] != null
          ? double.parse(tarjetaResponse['saldo_disponible'].toString())
          : 0.0;

      if (saldoDisponible < montoTotal) {
        throw Exception('Línea de crédito disponible insuficiente');
      }

      final cuotaMensual = double.parse((montoTotal / plazoMeses).toStringAsFixed(2));

      // 2. Insertar compra MSI
      await _client.from('meses_sin_intereses').insert({
        'user_id': userId,
        'tarjeta_id': tarjetaId,
        'comercio': comercio,
        'monto_total': montoTotal,
        'plazo_meses': plazoMeses,
        'cuota_mensual': cuotaMensual,
        'cuotas_pagadas': 0,
        'estado': 'activo',
        'fecha_inicio': DateTime.now().toIso8601String().split('T')[0],
      });

      // 3. Actualizar el saldo disponible de la tarjeta de crédito
      await _client
          .from('tarjetas')
          .update({'saldo_disponible': saldoDisponible - montoTotal})
          .eq('id', tarjetaId);

    } catch (e) {
      throw Exception('Error al registrar compra con meses sin intereses: $e');
    }
  }
}
