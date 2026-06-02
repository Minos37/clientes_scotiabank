class DepositoPlazo {
  final String id;
  final String userId;
  final String? cuentaId;
  final double monto;
  final String moneda; // 'PEN', 'USD'
  final int plazoDias;
  final double tasaAnual;
  final double? rendimiento;
  final DateTime fechaInicio;
  final DateTime fechaVenc;
  final String estado; // 'activo', 'vencido', 'cancelado', 'renovado'
  final bool renovacionAuto;
  final DateTime? createdAt;

  DepositoPlazo({
    required this.id,
    required this.userId,
    this.cuentaId,
    required this.monto,
    required this.moneda,
    required this.plazoDias,
    required this.tasaAnual,
    this.rendimiento,
    required this.fechaInicio,
    required this.fechaVenc,
    required this.estado,
    required this.renovacionAuto,
    this.createdAt,
  });

  factory DepositoPlazo.fromJson(Map<String, dynamic> json) {
    return DepositoPlazo(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cuentaId: json['cuenta_id']?.toString(),
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda']?.toString() ?? 'PEN',
      plazoDias: json['plazo_dias'] as int? ?? 90,
      tasaAnual: (json['tasa_anual'] as num?)?.toDouble() ?? 0.0,
      rendimiento: (json['rendimiento'] as num?)?.toDouble(),
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'])
          : DateTime.now(),
      fechaVenc: json['fecha_venc'] != null
          ? DateTime.parse(json['fecha_venc'])
          : DateTime.now(),
      estado: json['estado']?.toString() ?? 'activo',
      renovacionAuto: json['renovacion_auto'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      'monto': monto,
      'moneda': moneda,
      'plazo_dias': plazoDias,
      'tasa_anual': tasaAnual,
      if (rendimiento != null) 'rendimiento': rendimiento,
      'fecha_inicio': fechaInicio.toIso8601String().substring(0, 10),
      'fecha_venc': fechaVenc.toIso8601String().substring(0, 10),
      'estado': estado,
      'renovacion_auto': renovacionAuto,
    };
  }
}
