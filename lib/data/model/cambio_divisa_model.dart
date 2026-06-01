class CambioDivisa {
  final String id;
  final String userId;
  final String? cuentaId;
  final String operacion; // 'compra' o 'venta'
  final double montoOrigen;
  final String monedaOrigen; // 'PEN' o 'USD'
  final double tipoCambio;
  final double montoDestino;
  final String monedaDestino; // 'PEN' o 'USD'
  final String canal; // 'app', 'web', 'agencia'
  final DateTime? fecha;

  CambioDivisa({
    required this.id,
    required this.userId,
    this.cuentaId,
    required this.operacion,
    required this.montoOrigen,
    required this.monedaOrigen,
    required this.tipoCambio,
    required this.montoDestino,
    required this.monedaDestino,
    required this.canal,
    this.fecha,
  });

  factory CambioDivisa.fromJson(Map<String, dynamic> json) {
    return CambioDivisa(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cuentaId: json['cuenta_id']?.toString(),
      operacion: json['operacion']?.toString() ?? 'compra',
      montoOrigen: (json['monto_origen'] as num?)?.toDouble() ?? 0.0,
      monedaOrigen: json['moneda_origen']?.toString() ?? 'PEN',
      tipoCambio: (json['tipo_cambio'] as num?)?.toDouble() ?? 0.0,
      montoDestino: (json['monto_destino'] as num?)?.toDouble() ?? 0.0,
      monedaDestino: json['moneda_destino']?.toString() ?? 'USD',
      canal: json['canal']?.toString() ?? 'app',
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cuenta_id': cuentaId,
      'operacion': operacion,
      'monto_origen': montoOrigen,
      'moneda_origen': monedaOrigen,
      'tipo_cambio': tipoCambio,
      'monto_destino': montoDestino,
      'moneda_destino': monedaDestino,
      'canal': canal,
      'fecha': fecha?.toIso8601String(),
    };
  }
}
