class ScotiaPuntosModel {
  final String id;
  final String userId;
  final String? tarjetaId;
  final String tipoMovimiento; // 'acumulacion', 'canje', 'expiracion'
  final int puntos;
  final String? descripcion;
  final DateTime fecha;

  ScotiaPuntosModel({
    required this.id,
    required this.userId,
    this.tarjetaId,
    required this.tipoMovimiento,
    required this.puntos,
    this.descripcion,
    required this.fecha,
  });

  factory ScotiaPuntosModel.fromJson(Map<String, dynamic> json) {
    return ScotiaPuntosModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      tarjetaId: json['tarjeta_id']?.toString(),
      tipoMovimiento: json['tipo_movimiento']?.toString() ?? 'acumulacion',
      puntos: json['puntos'] as int? ?? 0,
      descripcion: json['descripcion']?.toString(),
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tarjeta_id': tarjetaId,
      'tipo_movimiento': tipoMovimiento,
      'puntos': puntos,
      'descripcion': descripcion,
      'fecha': fecha.toIso8601String(),
    };
  }
}
