class Manicurista {
  final String nombre;
  final String apellido;
  final String numeroDocumento;
  final String correo;
  final String celular;
  final String estado;
  final String fechaNacimiento;
  final String fechaContratacion;
  final String username;
  final int rolId;
  final int usuarioId; // 👈 Nuevo campo

  Manicurista({
    required this.nombre,
    required this.apellido,
    required this.numeroDocumento,
    required this.correo,
    required this.celular,
    required this.estado,
    required this.fechaNacimiento,
    required this.fechaContratacion,
    required this.username,
    required this.rolId,
    required this.usuarioId, // 👈 Aquí también
  });

  factory Manicurista.fromJson(Map<String, dynamic> json) {
    return Manicurista(
      nombre: json['nombre'],
      apellido: json['apellido'],
      numeroDocumento: json['numero_documento'],
      correo: json['correo'],
      celular: json['celular'],
      estado: json['estado'],
      fechaNacimiento: json['fecha_nacimiento'],
      fechaContratacion: json['fecha_contratacion'],
      username: json['username_out'],
      rolId: json['rol_id_out'],
      usuarioId: json['usuario_id'], // 👈 Aquí lo tomamos
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}
