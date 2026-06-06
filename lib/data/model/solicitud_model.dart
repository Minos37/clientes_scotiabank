class Solicitud {
  final String id;
  final String userId;
  final String producto; // e.g. 'cuenta_digital', 'tarjeta_credito', etc.
  final Map<String, dynamic>? datosSolicitud;
  final String estado; // 'pendiente', 'en_revision', 'aprobada', 'rechazada', 'desembolsada'
  final String? comentario;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Solicitud({
    required this.id,
    required this.userId,
    required this.producto,
    this.datosSolicitud,
    required this.estado,
    this.comentario,
    this.createdAt,
    this.updatedAt,
  });

  String get productoFormateado {
    switch (producto) {
      case 'cuenta_digital':
        return 'Cuenta Digital';
      case 'cuenta_sueldo':
        return 'Cuenta Sueldo';
      case 'cuenta_power':
        return 'Cuenta Power';
      case 'tarjeta_credito':
        return 'Tarjeta de Crédito';
      case 'tarjeta_debito':
        return 'Tarjeta de Débito';
      case 'prestamo_personal':
        return 'Préstamo Personal';
      case 'adelanto_sueldo':
        return 'Adelanto de Sueldo';
      case 'prestamo_convenio':
        return 'Préstamo por Convenio';
      case 'credito_vehicular':
        return 'Crédito Vehicular';
      case 'credito_hipotecario':
        return 'Crédito Hipotecario';
      case 'mi_vivienda':
        return 'Crédito Mivivienda';
      case 'libre_garantia':
        return 'Préstamo Libre Garantía';
      case 'deposito_plazo':
        return 'Depósito a Plazo Fijo';
      case 'fondo_mutuo':
        return 'Fondo Mutuo';
      case 'scotia_bolsa':
        return 'Inversión Scotia Bolsa';
      case 'seguro_oncologico':
        return 'Seguro Oncológico';
      case 'seguro_vehicular':
        return 'Seguro Vehicular';
      case 'seguro_hogar':
        return 'Seguro de Hogar';
      case 'proteccion_pagos':
        return 'Seguro Protección de Pagos';
      default:
        return producto;
    }
  }

  String get estadoFormateado {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_revision':
        return 'En Revisión';
      case 'aprobada':
        return 'Aprobada';
      case 'rechazada':
        return 'Rechazada';
      case 'desembolsada':
        return 'Desembolsada / Activada';
      default:
        return estado;
    }
  }

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      producto: json['producto']?.toString() ?? '',
      datosSolicitud: json['datos_solicitud'] is Map
          ? Map<String, dynamic>.from(json['datos_solicitud'] as Map)
          : null,
      estado: json['estado']?.toString() ?? 'pendiente',
      comentario: json['comentario']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'producto': producto,
      if (datosSolicitud != null) 'datos_solicitud': datosSolicitud,
      'estado': estado,
      if (comentario != null) 'comentario': comentario,
      if (createdAt != null) 'created_at': createdAt?.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
