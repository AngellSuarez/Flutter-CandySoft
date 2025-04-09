class Servicio {
  final int id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String estado;
  final String url_imagen;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.estado,
    required this.url_imagen,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    return Servicio(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      precio: double.tryParse(json['precio'].toString()) ?? 00,
      estado: json['estado'],
      url_imagen: json['url_imagen'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'estado': estado,
      'url_imagen': url_imagen,
    };
  }
}
