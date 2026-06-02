class CuentaAhorro {
  final String id;
  final String userId;
  final String? cuentaId;
  final double saldo;
  final double metaAhorro;
  final double tasaInteres;
  final String moneda; // 'PEN', 'USD'
  final DateTime? fechaApertura;

  CuentaAhorro({
    required this.id,
    required this.userId,
    this.cuentaId,
    required this.saldo,
    required this.metaAhorro,
    required this.tasaInteres,
    required this.moneda,
    this.fechaApertura,
  });

  factory CuentaAhorro.fromJson(Map<String, dynamic> json) {
    return CuentaAhorro(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cuentaId: json['cuenta_id']?.toString(),
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      metaAhorro: (json['meta_ahorro'] as num?)?.toDouble() ?? 10000.0,
      tasaInteres: (json['tasa_interes'] as num?)?.toDouble() ?? 3.5,
      moneda: json['moneda']?.toString() ?? 'PEN',
      fechaApertura: json['fecha_apertura'] != null 
          ? DateTime.tryParse(json['fecha_apertura'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      'saldo': saldo,
      'meta_ahorro': metaAhorro,
      'tasa_interes': tasaInteres,
      'moneda': moneda,
      if (fechaApertura != null) 'fecha_apertura': fechaApertura?.toIso8601String().substring(0, 10),
    };
  }
}
