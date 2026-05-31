class Transaccion {
  final String id;
  final String userId;
  final String cuentaId;
  final String tipo;
  final String descripcion;
  final double monto;
  final String moneda;
  final DateTime fecha;

  Transaccion({
    required this.id,
    required this.userId,
    required this.cuentaId,
    required this.tipo,
    required this.descripcion,
    required this.monto,
    required this.moneda,
    required this.fecha,
  });

  factory Transaccion.fromJson(Map<String, dynamic> json) {
    return Transaccion(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cuentaId: json['cuenta_id']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda']?.toString() ?? 'PEN',
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    );
  }
}
