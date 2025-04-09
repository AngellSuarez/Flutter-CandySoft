class Cliente {
  final int usuarioId;
  final String nombre;
  final String apellido;
  final String tipoDocumento;
  final String numeroDocumento;
  final String correo;
  final String celular;
  final String estado;
  final String username;
  final int rolId;

  Cliente({
    required this.usuarioId,
    required this.nombre,
    required this.apellido,
    required this.tipoDocumento,
    required this.numeroDocumento,
    required this.correo,
    required this.celular,
    required this.estado,
    required this.username,
    required this.rolId,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    return Cliente(
      usuarioId: json['usuario_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      tipoDocumento: json['tipo_documento'],
      numeroDocumento: json['numero_documento'],
      correo: json['correo'],
      celular: json['celular'],
      estado: json['estado'],
      username: json['username_out'],
      rolId: json['rol_id_out'],
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}
