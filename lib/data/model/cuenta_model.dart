class Cuenta {
  final String id;
  final String userId;
  final String tipo; // 'digital', 'sueldo', 'power'
  final String numeroCuenta;
  final String? cci;
  final double saldo;
  final String moneda; // 'PEN', 'USD'
  final double costoMant;
  final DateTime? fechaApertura;
  final bool activa;
  final DateTime? createdAt;

  Cuenta({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.numeroCuenta,
    this.cci,
    required this.saldo,
    required this.moneda,
    required this.costoMant,
    this.fechaApertura,
    required this.activa,
    this.createdAt,
  });

  factory Cuenta.fromJson(Map<String, dynamic> json) {
    return Cuenta(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'digital',
      numeroCuenta: json['numero_cuenta']?.toString() ?? '',
      cci: json['cci']?.toString(),
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda']?.toString() ?? 'PEN',
      costoMant: (json['costo_mant'] as num?)?.toDouble() ?? 0.0,
      fechaApertura: json['fecha_apertura'] != null 
          ? DateTime.tryParse(json['fecha_apertura'].toString()) 
          : null,
      activa: json['activa'] as bool? ?? true,
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
      'numero_cuenta': numeroCuenta,
      'cci': cci,
      'saldo': saldo,
      'moneda': moneda,
      'costo_mant': costoMant,
      'fecha_apertura': fechaApertura?.toIso8601String(),
      'activa': activa,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}
