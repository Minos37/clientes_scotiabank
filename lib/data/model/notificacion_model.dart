class Notificacion {
  final String id;
  final String userId;
  final String tipo; // 'pago_vencido','cuota_proxima','movimiento','oferta','seguridad','aprobacion','rechazo','otro'
  final String titulo;
  final String mensaje;
  final bool leida;
  final DateTime fecha;

  Notificacion({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leida,
    required this.fecha,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? 'otro',
      titulo: json['titulo']?.toString() ?? '',
      mensaje: json['mensaje']?.toString() ?? '',
      leida: json['leida'] as bool? ?? false,
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tipo': tipo,
      'titulo': titulo,
      'mensaje': mensaje,
      'leida': leida,
      'fecha': fecha.toIso8601String(),
    };
  }
}
