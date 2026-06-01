class Transferencia {
  final String id;
  final String userId;
  final String? cuentaOrigenId;
  final String tipo; // 'interna','cci','plin','qr','swift','cheque_exterior'
  final String? bancoDestino;
  final String? cuentaDestino;
  final String nombreDestino;
  final double monto;
  final String moneda; // 'PEN','USD'
  final double? tipoCambio;
  final double comision;
  final String estado; // 'pendiente','completado','fallido','reversado'
  final String? referencia;
  final DateTime? fecha;

  Transferencia({
    required this.id,
    required this.userId,
    this.cuentaOrigenId,
    required this.tipo,
    this.bancoDestino,
    this.cuentaDestino,
    required this.nombreDestino,
    required this.monto,
    required this.moneda,
    this.tipoCambio,
    required this.comision,
    required this.estado,
    this.referencia,
    this.fecha,
  });

  factory Transferencia.fromJson(Map<String, dynamic> json) {
    return Transferencia(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cuentaOrigenId: json['cuenta_origen_id']?.toString(),
      tipo: json['tipo']?.toString() ?? 'interna',
      bancoDestino: json['banco_destino']?.toString(),
      cuentaDestino: json['cuenta_destino']?.toString(),
      nombreDestino: json['nombre_destino']?.toString() ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      moneda: json['moneda']?.toString() ?? 'PEN',
      tipoCambio: (json['tipo_cambio'] as num?)?.toDouble(),
      comision: (json['comision'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado']?.toString() ?? 'completado',
      referencia: json['referencia']?.toString(),
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cuenta_origen_id': cuentaOrigenId,
      'tipo': tipo,
      'banco_destino': bancoDestino,
      'cuenta_destino': cuentaDestino,
      'nombre_destino': nombreDestino,
      'monto': monto,
      'moneda': moneda,
      'tipo_cambio': tipoCambio,
      'comision': comision,
      'estado': estado,
      'referencia': referencia,
      'fecha': fecha?.toIso8601String(),
    };
  }
}
