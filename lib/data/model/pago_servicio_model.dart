class PagoServicio {
  final String id;
  final String userId;
  final String? cuentaId;
  final String? tarjetaId;
  final String servicio; // 'agua','luz','gas','telefono','cable','internet','colegio','universidad','municipalidad','otro'
  final String proveedor;
  final String numeroContrato;
  final double monto;
  final String estado; // 'pendiente','completado','fallido'
  final String canal; // 'app','web','agencia'
  final DateTime? fecha;

  PagoServicio({
    required this.id,
    required this.userId,
    this.cuentaId,
    this.tarjetaId,
    required this.servicio,
    required this.proveedor,
    required this.numeroContrato,
    required this.monto,
    required this.estado,
    required this.canal,
    this.fecha,
  });

  factory PagoServicio.fromJson(Map<String, dynamic> json) {
    return PagoServicio(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cuentaId: json['cuenta_id']?.toString(),
      tarjetaId: json['tarjeta_id']?.toString(),
      servicio: json['servicio']?.toString() ?? 'otro',
      proveedor: json['proveedor']?.toString() ?? '',
      numeroContrato: json['numero_contrato']?.toString() ?? '',
      monto: (json['monto'] as num?)?.toDouble() ?? 0.0,
      estado: json['estado']?.toString() ?? 'completado',
      canal: json['canal']?.toString() ?? 'app',
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'cuenta_id': cuentaId,
      'tarjeta_id': tarjetaId,
      'servicio': servicio,
      'proveedor': proveedor,
      'numero_contrato': numeroContrato,
      'monto': monto,
      'estado': estado,
      'canal': canal,
      'fecha': fecha?.toIso8601String(),
    };
  }
}
