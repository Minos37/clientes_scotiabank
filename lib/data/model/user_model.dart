class UserModel {
  final String id;
  final String email;
  final String? nombre;
  final String? dni;

  UserModel({
    required this.id,
    required this.email,
    this.nombre,
    this.dni,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      nombre: json['nombre']?.toString(),
      dni: json['dni']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'dni': dni,
    };
  }
}
