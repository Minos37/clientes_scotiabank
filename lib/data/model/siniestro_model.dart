class Siniestro {
  final String id;
  final String userId;
  final String seguroId;
  final String descripcion;
  final double? montoReclamado;
  final double? montoLiquidado;
  final String estado; // 'en_revision', 'aprobado', 'rechazado', 'pagado'
  final DateTime fechaOcurrencia;
  final DateTime? fechaReporte;

  Siniestro({
    required this.id,
    required this.userId,
    required this.seguroId,
    required this.descripcion,
    this.montoReclamado,
    this.montoLiquidado,
    required this.estado,
    required this.fechaOcurrencia,
    this.fechaReporte,
  });

  String get estadoFormateado {
    switch (estado) {
      case 'en_revision':
        return 'En Revisión';
      case 'aprobado':
        return 'Aprobado';
      case 'rechazado':
        return 'Rechazado';
      case 'pagado':
        return 'Liquidado / Pagado';
      default:
        return 'Pendiente';
    }
  }

  factory Siniestro.fromJson(Map<String, dynamic> json) {
    return Siniestro(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      seguroId: json['seguro_id']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      montoReclamado: (json['monto_reclamado'] as num?)?.toDouble(),
      montoLiquidado: (json['monto_liquidado'] as num?)?.toDouble(),
      estado: json['estado']?.toString() ?? 'en_revision',
      fechaOcurrencia: json['fecha_ocurrencia'] != null
          ? DateTime.parse(json['fecha_ocurrencia'])
          : DateTime.now(),
      fechaReporte: json['fecha_reporte'] != null
          ? DateTime.tryParse(json['fecha_reporte'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'seguro_id': seguroId,
      'descripcion': descripcion,
      if (montoReclamado != null) 'monto_reclamado': montoReclamado,
      if (montoLiquidado != null) 'monto_liquidado': montoLiquidado,
      'estado': estado,
      'fecha_ocurrencia': fechaOcurrencia.toIso8601String().substring(0, 10),
      if (fechaReporte != null) 'fecha_reporte': fechaReporte?.toIso8601String(),
    };
  }
}
