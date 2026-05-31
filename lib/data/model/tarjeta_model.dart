class Tarjeta {
  final String id;
  final String userId;
  final String? cuentaId;
  final String tipo;
  final String numeroEnmascarado;
  final String marca;
  final DateTime fechaVencimiento;
  final double? lineaCredito;
  final double? saldoDisponible;
  final bool activa;
  final int puntosAcumulados;

  Tarjeta({
    required this.id,
    required this.userId,
    this.cuentaId,
    required this.tipo,
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
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      cuentaId: json['cuenta_id']?.toString(),
      tipo: json['tipo']?.toString() ?? 'debito',
      numeroEnmascarado: json['numero_enmascarado']?.toString() ?? '',
      marca: json['marca']?.toString() ?? '',
      fechaVencimiento: json['fecha_vencimiento'] != null 
          ? DateTime.parse(json['fecha_vencimiento']) 
          : DateTime.now(),
      lineaCredito: (json['linea_credito'] as num?)?.toDouble(),
      saldoDisponible: (json['saldo_disponible'] as num?)?.toDouble(),
      activa: json['activa'] == true,
      puntosAcumulados: (json['puntos_acumulados'] as num?)?.toInt() ?? 0,
    );
  }
}
