class FondoMutuo {
  final String id;
  final String userId;
  final String fondo;
  final String tipoFondo; // 'conservador', 'moderado', 'agresivo', 'exterior'
  final String moneda; // 'PEN', 'USD'
  final double montoInvertido;
  final double cuotas;
  final double valorCuota;
  final double? valorActual;
  final double? rentabilidad;
  final double inversionMin;
  final String estado; // 'activo', 'rescatado', 'suspendido'
  final DateTime? fechaInicio;

  FondoMutuo({
    required this.id,
    required this.userId,
    required this.fondo,
    required this.tipoFondo,
    required this.moneda,
    required this.montoInvertido,
    required this.cuotas,
    required this.valorCuota,
    this.valorActual,
    this.rentabilidad,
    required this.inversionMin,
    required this.estado,
    this.fechaInicio,
  });

  String get tipoFondoFormateado {
    switch (tipoFondo) {
      case 'conservador':
        return 'Conservador (Bajo Riesgo)';
      case 'moderado':
        return 'Moderado (Medio Riesgo)';
      case 'agresivo':
        return 'Agresivo (Alto Riesgo)';
      case 'exterior':
        return 'Fondo Mutuo del Exterior';
      default:
        return 'Fondo Mutuo';
    }
  }

  factory FondoMutuo.fromJson(Map<String, dynamic> json) {
    return FondoMutuo(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      fondo: json['fondo']?.toString() ?? '',
      tipoFondo: json['tipo_fondo']?.toString() ?? 'conservador',
      moneda: json['moneda']?.toString() ?? 'USD',
      montoInvertido: (json['monto_invertido'] as num?)?.toDouble() ?? 0.0,
      cuotas: (json['cuotas'] as num?)?.toDouble() ?? 0.0,
      valorCuota: (json['valor_cuota'] as num?)?.toDouble() ?? 1.0,
      valorActual: (json['valor_actual'] as num?)?.toDouble(),
      rentabilidad: (json['rentabilidad'] as num?)?.toDouble(),
      inversionMin: (json['inversion_min'] as num?)?.toDouble() ?? 100.0,
      estado: json['estado']?.toString() ?? 'activo',
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.tryParse(json['fecha_inicio'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'fondo': fondo,
      'tipo_fondo': tipoFondo,
      'moneda': moneda,
      'monto_invertido': montoInvertido,
      'cuotas': cuotas,
      'valor_cuota': valorCuota,
      if (valorActual != null) 'valor_actual': valorActual,
      if (rentabilidad != null) 'rentabilidad': rentabilidad,
      'inversion_min': inversionMin,
      'estado': estado,
      if (fechaInicio != null) 'fecha_inicio': fechaInicio?.toIso8601String().substring(0, 10),
    };
  }
}
