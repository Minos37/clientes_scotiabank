class Seguro {
  final String id;
  final String userId;
  final String tipo; // 'oncologico_oncomax', 'oncologico_plus', 'desgravamen', 'soat', 'vehicular_totalmax', 'incendio', 'hogar_protegido', 'proteccion_pagos', 'tarjeta_segura'
  final String? prestamoId;
  final String? tarjetaId;
  final String numeroPoliza;
  final double primaMensual;
  final double? sumaAsegurada;
  final String moneda; // 'PEN', 'USD'
  final String estado; // 'vigente', 'vencido', 'cancelado', 'siniestro'
  final DateTime fechaInicio;
  final DateTime? fechaVenc;
  final DateTime? createdAt;

  Seguro({
    required this.id,
    required this.userId,
    required this.tipo,
    this.prestamoId,
    this.tarjetaId,
    required this.numeroPoliza,
    required this.primaMensual,
    this.sumaAsegurada,
    required this.moneda,
    required this.estado,
    required this.fechaInicio,
    this.fechaVenc,
    this.createdAt,
  });

  String get tipoFormateado {
    switch (tipo) {
      case 'oncologico_oncomax':
        return 'Seguro Oncológico Oncomax';
      case 'oncologico_plus':
        return 'Seguro Oncológico Plus';
      case 'desgravamen':
        return 'Seguro de Desgravamen';
      case 'soat':
        return 'SOAT Digital';
      case 'vehicular_totalmax':
        return 'Seguro Vehicular TotalMax 2.0';
      case 'incendio':
        return 'Seguro contra Incendios';
      case 'hogar_protegido':
        return 'Seguro Hogar Protegido';
      case 'proteccion_pagos':
        return 'Seguro de Protección de Pagos';
      case 'tarjeta_segura':
        return 'Seguro Tarjeta Segura';
      default:
        return 'Seguro Scotiabank';
    }
  }

  factory Seguro.fromJson(Map<String, dynamic> json) {
    return Seguro(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      prestamoId: json['prestamo_id']?.toString(),
      tarjetaId: json['tarjeta_id']?.toString(),
      numeroPoliza: json['numero_poliza']?.toString() ?? '',
      primaMensual: (json['prima_mensual'] as num?)?.toDouble() ?? 0.0,
      sumaAsegurada: (json['suma_asegurada'] as num?)?.toDouble(),
      moneda: json['moneda']?.toString() ?? 'PEN',
      estado: json['estado']?.toString() ?? 'vigente',
      fechaInicio: json['fecha_inicio'] != null
          ? DateTime.parse(json['fecha_inicio'])
          : DateTime.now(),
      fechaVenc: json['fecha_venc'] != null
          ? DateTime.tryParse(json['fecha_venc'].toString())
          : null,
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
      if (prestamoId != null) 'prestamo_id': prestamoId,
      if (tarjetaId != null) 'tarjeta_id': tarjetaId,
      'numero_poliza': numeroPoliza,
      'prima_mensual': primaMensual,
      if (sumaAsegurada != null) 'suma_asegurada': sumaAsegurada,
      'moneda': moneda,
      'estado': estado,
      'fecha_inicio': fechaInicio.toIso8601String().substring(0, 10),
      if (fechaVenc != null) 'fecha_venc': fechaVenc?.toIso8601String().substring(0, 10),
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
    };
  }
}
