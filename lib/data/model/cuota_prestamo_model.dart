class CuotaPrestamo {
  final String id;
  final String prestamoId;
  final String userId;
  final int numeroCuota;
  final double montoCuota;
  final double capital;
  final double intereses;
  final DateTime fechaVenc;
  final DateTime? fechaPago;
  final String estado; // 'pendiente','pagada','mora'

  CuotaPrestamo({
    required this.id,
    required this.prestamoId,
    required this.userId,
    required this.numeroCuota,
    required this.montoCuota,
    required this.capital,
    required this.intereses,
    required this.fechaVenc,
    this.fechaPago,
    required this.estado,
  });

  factory CuotaPrestamo.fromJson(Map<String, dynamic> json) {
    return CuotaPrestamo(
      id: json['id']?.toString() ?? '',
      prestamoId: json['prestamo_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      numeroCuota: (json['numero_cuota'] as num?)?.toInt() ?? 1,
      montoCuota: (json['monto_cuota'] as num?)?.toDouble() ?? 0.0,
      capital: (json['capital'] as num?)?.toDouble() ?? 0.0,
      intereses: (json['intereses'] as num?)?.toDouble() ?? 0.0,
      fechaVenc: DateTime.parse(json['fecha_venc'].toString()),
      fechaPago: json['fecha_pago'] != null
          ? DateTime.tryParse(json['fecha_pago'].toString())
          : null,
      estado: json['estado']?.toString() ?? 'pendiente',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prestamo_id': prestamoId,
      'user_id': userId,
      'numero_cuota': numeroCuota,
      'monto_cuota': montoCuota,
      'capital': capital,
      'intereses': intereses,
      'fecha_venc': fechaVenc.toIso8601String(),
      'fecha_pago': fechaPago?.toIso8601String(),
      'estado': estado,
    };
  }
}
