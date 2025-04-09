class EstadoCita {
  final int id;
  final String Estado;

  EstadoCita({required this.id, required this.Estado});

  factory EstadoCita.fromJson(Map<String, dynamic> json) {
    return EstadoCita(id: json['id'], Estado: json['Estado']);
  }
}
