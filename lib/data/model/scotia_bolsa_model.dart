class ScotiaBolsa {
  final String id;
  final String userId;
  final String ticker;
  final String operacion; // 'compra', 'venta'
  final double cantidad;
  final double precioUnitario;
  final double montoTotal;
  final String moneda; // 'USD', 'PEN'
  final double comision;
  final String estado; // 'pendiente', 'ejecutada', 'cancelada'
  final DateTime fecha;

  ScotiaBolsa({
    required this.id,
    required this.userId,
    required this.ticker,
    required this.operacion,
    required this.cantidad,
    required this.precioUnitario,
    required this.montoTotal,
    required this.moneda,
    required this.comision,
    required this.estado,
    required this.fecha,
  });

  factory ScotiaBolsa.fromJson(Map<String, dynamic> json) {
    return ScotiaBolsa(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      ticker: json['ticker']?.toString() ?? '',
      operacion: json['operacion']?.toString() ?? 'compra',
      cantidad: (json['cantidad'] as num?)?.toDouble() ?? 0.0,
      precioUnitario: (json['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      montoTotal: (json['monto_total'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda']?.toString() ?? 'USD',
      comision: (json['comision'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado']?.toString() ?? 'ejecutada',
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'ticker': ticker,
      'operacion': operacion,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'monto_total': montoTotal,
      'moneda': moneda,
      'comision': comision,
      'estado': estado,
      'fecha': fecha.toIso8601String(),
    };
  }
}
