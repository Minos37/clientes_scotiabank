class Prestamo {
  final String id;
  final String userId;
  final String tipo; // 'personal', 'adelanto_sueldo', 'convenio', 'vehicular', 'hipotecario', 'mi_vivienda', 'libre_garantia'
  final double monto;
  final String moneda; // 'PEN', 'USD'
  final int plazoMeses;
  final double tasaAnual;
  final double cuotaMensual;
  final int cuotasPagadas;
  final double saldoCapital;
  final String? proposito;
  final String? garantia;
  final String estado; // 'pendiente','activo','pagado','mora','cancelado'
  final DateTime? fechaDesembolso;
  final DateTime? createdAt;

  Prestamo({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.monto,
    required this.moneda,
    required this.plazoMeses,
    required this.tasaAnual,
    required this.cuotaMensual,
    required this.cuotasPagadas,
    required this.saldoCapital,
    this.proposito,
    this.garantia,
    required this.estado,
    this.fechaDesembolso,
    this.createdAt,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) {
    return Prestamo(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'personal',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda']?.toString() ?? 'PEN',
      plazoMeses: (json['plazo_meses'] as num?)?.toInt() ?? 12,
      tasaAnual: (json['tasa_anual'] as num?)?.toDouble() ?? 0.0,
      cuotaMensual: (json['cuota_mensual'] as num?)?.toDouble() ?? 0.0,
      cuotasPagadas: (json['cuotas_pagadas'] as num?)?.toInt() ?? 0,
      saldoCapital: (json['saldo_capital'] as num?)?.toDouble() ?? 0.0,
      proposito: json['proposito']?.toString(),
      garantia: json['garantia']?.toString(),
      estado: json['estado']?.toString() ?? 'activo',
      fechaDesembolso: json['fecha_desembolso'] != null
          ? DateTime.tryParse(json['fecha_desembolso'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tipo': tipo,
      'monto': monto,
      'moneda': moneda,
      'plazo_meses': plazoMeses,
      'tasa_anual': tasaAnual,
      'cuota_mensual': cuotaMensual,
      'cuotas_pagadas': cuotasPagadas,
      'saldo_capital': saldoCapital,
      'proposito': proposito,
      'garantia': garantia,
      'estado': estado,
      'fecha_desembolso': fechaDesembolso?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  String get tipoFormateado {
    final nombres = {
      'personal': 'Préstamo Personal',
      'adelanto_sueldo': 'Adelanto de Sueldo',
      'convenio': 'Préstamo por Convenio',
      'vehicular': 'Crédito Vehicular',
      'hipotecario': 'Crédito Hipotecario',
      'mi_vivienda': 'Programa Mi Vivienda',
      'libre_garantia': 'Libre Disponibilidad con Garantía'
    };
    return nombres[tipo] ?? 'Préstamo Bancario';
  }
}
