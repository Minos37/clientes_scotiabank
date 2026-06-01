class Tarjeta {
  final String id;
  final String? cuentaId;
  final String tipo; // 'credito' o 'debito'
  final String? subtipo; // 'clasica', 'oro', 'platinum', etc.
  final String numeroEnmascarado;
  final String marca; // 'Visa', 'Mastercard', 'Amex'
  final DateTime fechaVencimiento;
  final double? lineaCredito;
  final double? saldoDisponible;
  final bool activa;
  final int puntosAcumulados;

  Tarjeta({
    required this.id,
    this.cuentaId,
    required this.tipo,
    this.subtipo,
    required this.numeroEnmascarado,
    required this.marca,
    required this.fechaVencimiento,
    this.lineaCredito,
    this.saldoDisponible,
    required this.activa,
    required this.puntosAcumulados,
  });

  factory Tarjeta.fromJson(Map<String, dynamic> json) {
    return Tarjeta(
      id: json['id'] as String,
      cuentaId: json['cuenta_id'] as String?,
      tipo: json['tipo'] as String,
      subtipo: json['subtipo'] as String?,
      numeroEnmascarado: json['numero_enmascarado'] as String,
      marca: json['marca'] as String,
      fechaVencimiento: DateTime.parse(json['fecha_vencimiento'] as String),
      lineaCredito: json['linea_credito'] != null
          ? double.parse(json['linea_credito'].toString())
          : null,
      saldoDisponible: json['saldo_disponible'] != null
          ? double.parse(json['saldo_disponible'].toString())
          : null,
      activa: json['activa'] as bool? ?? true,
      puntosAcumulados: json['puntos_acumulados'] as int? ?? 0,
    );
  }

  // Getter de ayuda para mostrar texto formateado
  String get tipoFormateado {
    if (tipo == 'credito') {
      if (subtipo != null) {
        final nombres = {
          'visa_sin_membresia': 'Visa Sin Membresía',
          'visa_smart': 'Visa Smart',
          'clasica': 'Tarjeta Clásica',
          'oro': 'Tarjeta Oro',
          'platinum': 'Tarjeta Platinum',
        };
        return nombres[subtipo] ?? 'Tarjeta de Crédito';
      }
      return 'Tarjeta de Crédito';
    }
    return 'Tarjeta de Débito';
  }
}