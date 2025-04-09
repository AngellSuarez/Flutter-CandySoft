import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class Manicurista {
  final int id;
  final String nombre;
  final String apellido;

  Manicurista({required this.id, required this.nombre, required this.apellido});

  factory Manicurista.fromJson(Map<String, dynamic> json) {
    return Manicurista(
      id: json['usuario_id'],
      nombre: json['nombre'],
      apellido: json['apellido'],
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}

class CrearNovedadPage extends StatefulWidget {
  const CrearNovedadPage({super.key});

  @override
  State<CrearNovedadPage> createState() => _CrearNovedadPageState();
}

class _CrearNovedadPageState extends State<CrearNovedadPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = NovedadesApi();
  final _manicuristasApi = ManicuristasApi();

  List<Manicurista> _manicuristas = [];
  Manicurista? _selectedManicurista;

  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _horaEntradaController = TextEditingController();
  final TextEditingController _horaSalidaController = TextEditingController();
  final TextEditingController _motivoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarManicuristas();
  }

  Future<void> _cargarManicuristas() async {
    final data = await _manicuristasApi.obtenerManicuristasActivos();
    setState(() {
      _manicuristas = List<Manicurista>.from(
        data.map((json) => Manicurista.fromJson(json)),
      );
    });
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _seleccionarHora(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      controller.text = DateFormat('HH:mm:ss').format(selectedTime);
    }
  }

  Future<void> _crearNovedad() async {
    if (_formKey.currentState!.validate()) {
      final datos = {
        'manicurista_id': _selectedManicurista?.id,
        'Fecha': _fechaController.text,
        'HoraEntrada': _horaEntradaController.text,
        'HoraSalida': _horaSalidaController.text,
        'Motivo': _motivoController.text,
      };
      await _api.crearNovedad(datos);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Novedad')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<Manicurista>(
                value: _selectedManicurista,
                items:
                    _manicuristas.map((manicurista) {
                      return DropdownMenuItem<Manicurista>(
                        value: manicurista,
                        child: Text(manicurista.nombreCompleto),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedManicurista = value;
                  });
                },
                decoration: const InputDecoration(labelText: 'Manicurista'),
                validator:
                    (value) =>
                        value == null ? 'Seleccione una manicurista' : null,
              ),
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                onTap: _seleccionarFecha,
                decoration: const InputDecoration(labelText: 'Fecha'),
                validator:
                    (value) => value!.isEmpty ? 'Seleccione una fecha' : null,
              ),
              TextFormField(
                controller: _horaEntradaController,
                readOnly: true,
                onTap: () => _seleccionarHora(_horaEntradaController),
                decoration: const InputDecoration(labelText: 'Hora Entrada'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Seleccione la hora de entrada' : null,
              ),
              TextFormField(
                controller: _horaSalidaController,
                readOnly: true,
                onTap: () => _seleccionarHora(_horaSalidaController),
                decoration: const InputDecoration(labelText: 'Hora Salida'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Seleccione la hora de salida' : null,
              ),
              TextFormField(
                controller: _motivoController,
                decoration: const InputDecoration(labelText: 'Motivo'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Ingrese una observación' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _crearNovedad,
                child: const Text('Crear'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
