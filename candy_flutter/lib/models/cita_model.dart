class Cita {
  final int id;
  final int clienteId;
  final String clienteNombre;
  final int manicuristaId;
  final String manicuristaNombre;
  final String fecha;
  final String hora;
  final int estadoId;
  final String estadoNombre;
  final double total;

  Cita({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.manicuristaId,
    required this.manicuristaNombre,
    required this.fecha,
    required this.hora,
    required this.estadoId,
    required this.estadoNombre,
    required this.total,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
      id: json['id'],
      clienteId: json['cliente_id'],
      clienteNombre: json['cliente_nombre'],
      manicuristaId: json['manicurista_id'],
      manicuristaNombre: json['manicurista_nombre'],
      fecha: json['Fecha'],
      hora: json['Hora'],
      estadoId: json['estado_id'],
      estadoNombre: json['estado_nombre'],
      total: double.parse(json['Total'].toString()),
    );
  }
}
