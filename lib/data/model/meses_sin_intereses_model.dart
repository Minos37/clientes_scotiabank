class MesesSinInteresesModel {
  final String id;
  final String userId;
  final String tarjetaId;
  final String comercio;
  final double montoTotal;
  final int plazoMeses;
  final double cuotaMensual;
  final int cuotasPagadas;
  final String estado; // 'activo', 'completado', 'cancelado'
  final DateTime fechaInicio;

  MesesSinInteresesModel({
    required this.id,
    required this.userId,
    required this.tarjetaId,
    required this.comercio,
    required this.montoTotal,
    required this.plazoMeses,
    required this.cuotaMensual,
    required this.cuotasPagadas,
    required this.estado,
    required this.fechaInicio,
  });

  factory MesesSinInteresesModel.fromJson(Map<String, dynamic> json) {
    return MesesSinInteresesModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      tarjetaId: json['tarjeta_id']?.toString() ?? '',
      comercio: json['comercio']?.toString() ?? '',
      montoTotal: json['monto_total'] != null 
          ? double.parse(json['monto_total'].toString()) 
          : 0.0,
      plazoMeses: json['plazo_meses'] as int? ?? 12,
      cuotaMensual: json['cuota_mensual'] != null 
          ? double.parse(json['cuota_mensual'].toString()) 
          : 0.0,
      cuotasPagadas: json['cuotas_pagadas'] as int? ?? 0,
      estado: json['estado']?.toString() ?? 'activo',
      fechaInicio: json['fecha_inicio'] != null 
          ? DateTime.parse(json['fecha_inicio'].toString()) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tarjeta_id': tarjetaId,
      'comercio': comercio,
      'monto_total': montoTotal,
      'plazo_meses': plazoMeses,
      'cuota_mensual': cuotaMensual,
      'cuotas_pagadas': cuotasPagadas,
      'estado': estado,
      'fecha_inicio': fechaInicio.toIso8601String().split('T')[0], // YYYY-MM-DD
    };
  }
}
