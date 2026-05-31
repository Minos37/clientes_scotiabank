class Cuenta {
  final String id;
  final String userId;
  final String numeroCuenta;
  final double saldo;

  Cuenta({
    required this.id,
    required this.userId,
    required this.numeroCuenta,
    required this.saldo,
  });

  factory Cuenta.fromJson(Map<String, dynamic> json) {
    return Cuenta(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      numeroCuenta: json['numero_cuenta']?.toString() ?? '',
      saldo: (json['saldo'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'numero_cuenta': numeroCuenta,
      'saldo': saldo,
    };
  }
}
