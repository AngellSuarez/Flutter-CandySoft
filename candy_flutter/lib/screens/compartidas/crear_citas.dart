import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

import '../../../models/cliente_model.dart';
import '../../../models/manicurista_model.dart';
import '../../../models/estado_cita_model.dart';
import '../../../models/servicio_model.dart';
import '../../../services/api_service.dart';

class CrearCitaPage extends StatefulWidget {
  const CrearCitaPage({super.key});

  @override
  State<CrearCitaPage> createState() => _CrearCitaPageState();
}

class _CrearCitaPageState extends State<CrearCitaPage> {
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _horaController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

  final _citasApi = CitasApi();
  final _clientesApi = ClientesApi();
  final _manicuristasApi = ManicuristasApi();
  final _estadosApi = EstadosCitasApi();
  final _serviciosApi = ServicioAPi();

  int _currentStep = 0;
  int? _userId;
  String? _rol;

  List<Cliente> _clientes = [];
  List<Manicurista> _manicuristas = [];
  List<EstadoCita> _estados = [];
  List<Servicio> _servicios = [];
  final List<Servicio> _serviciosSeleccionados = [];

  Cliente? _selectedCliente;
  Manicurista? _selectedManicurista;
  EstadoCita? _selectedEstado;

  @override
  void initState() {
    super.initState();
    _cargarUsuarioSesion();
    _cargarDatos();
  }

  Future<void> _cargarUsuarioSesion() async {
    final rol = await _secureStorage.read(key: 'rol');
    final userIdStr = await _secureStorage.read(key: 'user_id');

    setState(() {
      _rol = rol;
      _userId = int.tryParse(userIdStr ?? '');
    });
  }

  Future<void> _cargarDatos() async {
    final dataClientes = await _clientesApi.obtenerClientesActivos();
    final clientes =
        dataClientes.map((json) => Cliente.fromJson(json)).toList();

    final dataManicuristas =
        await _manicuristasApi.obtenerManicuristasActivos();
    final manicuristas =
        dataManicuristas.map((json) => Manicurista.fromJson(json)).toList();

    final dataEstados = await _estadosApi.obtenerEstadosCita();
    final estados =
        dataEstados.map((json) => EstadoCita.fromJson(json)).toList();

    final dataServicios = await _serviciosApi.obtenerServicios();
    final servicios =
        dataServicios.map((json) => Servicio.fromJson(json)).toList();

    setState(() {
      _clientes = clientes;
      _manicuristas = manicuristas;
      _estados = estados;
      _servicios = servicios;

      if (_estados.isNotEmpty) {
        _selectedEstado = _estados.first;
      }
    });
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _fechaController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  TimeOfDay minTime = TimeOfDay(hour: 8, minute: 0);
  TimeOfDay maxTime = TimeOfDay(hour: 18, minute: 0);

  Future<void> _seleccionarHora() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final horaSeleccionada = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );
      final horaMin = DateTime(
        now.year,
        now.month,
        now.day,
        minTime.hour,
        minTime.minute,
      );
      final horaMax = DateTime(
        now.year,
        now.month,
        now.day,
        maxTime.hour,
        maxTime.minute,
      );

      if (horaSeleccionada.isBefore(horaMin) ||
          horaSeleccionada.isAfter(horaMax)) {
        // Hora fuera del rango permitido
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: Text('Hora no válida'),
                content: Text('Selecciona una hora entre 08:00 y 18:00.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Aceptar'),
                  ),
                ],
              ),
        );
        return;
      }

      // Hora válida, actualizar el controlador
      _horaController.text = DateFormat('HH:mm:ss').format(horaSeleccionada);
    }
  }

  void _onStepContinue() {
    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
    } else {
      _guardarCitaYServicios();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() => _currentStep -= 1);
    }
  }

  Future<void> _guardarCitaYServicios() async {
    if (!_formKey.currentState!.validate()) return;

    final cita = {
      'Fecha': _fechaController.text,
      'Hora': _horaController.text,
      'cliente_id': _rol == 'Cliente' ? _userId : _selectedCliente!.usuarioId,
      'manicurista_id': _selectedManicurista!.usuarioId,
      'estado_id': _selectedEstado!.id,
      'Total': 1,
      'Descripcion': _descripcionController.text,
    };

    // Imprime la cita antes de enviarla
    print('📝 Datos de la cita a enviar:');
    print(cita);

    try {
      final citaCreada = await _citasApi.crearCitaYRetornar(cita);

      // Debug print to check what's coming back
      print('Respuesta de crearCitaYRetornar:');
      print(citaCreada);

      // Get the ID from the nested data object
      if (citaCreada == null ||
          citaCreada['data'] == null ||
          citaCreada['data']['id'] == null) {
        throw Exception('No se recibió un ID de cita válido');
      }

      final citaId = citaCreada['data']['id'];

      final serviciosBody =
          _serviciosSeleccionados.map((servicio) {
            return {
              'cita_id': citaId,
              'servicio_id': servicio.id,
              'subtotal': servicio.precio,
            };
          }).toList();

      // More debug information
      print('🧾 Servicios seleccionados para la cita:');
      for (var servicio in serviciosBody) {
        print(servicio);
      }

      await _citasApi.agregarServiciosCita(serviciosBody);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Error al crear cita: $e');
      // Show more detailed error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al crear cita: ${e.toString()}')),
      );
    }
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Información'),
        content: _buildStepInfoCita(),
        isActive: _currentStep >= 0,
      ),
      Step(
        title: const Text('Servicios'),
        content: _buildStepServicios(),
        isActive: _currentStep >= 1,
      ),
      Step(
        title: const Text('Resumen'),
        content: _buildStepResumen(),
        isActive: _currentStep >= 2,
      ),
    ];
  }

  Widget _buildStepInfoCita() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_rol != 'Cliente') // Ocultar selector si es cliente
            Column(
              children: [
                DropdownButtonFormField<Cliente>(
                  decoration: InputDecoration(
                    labelText: 'Cliente',
                    fillColor: Colors.white,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.pinkAccent,
                        width: 2.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.pinkAccent,
                        width: 2.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.pinkAccent,
                        width: 2.5,
                      ),
                    ),
                  ),
                  value: _selectedCliente,
                  items:
                      _clientes.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c.nombreCompleto),
                        );
                      }).toList(),
                  onChanged: (val) => setState(() => _selectedCliente = val),
                  validator:
                      (val) => val == null ? 'Seleccione un cliente' : null,
                ),
                const SizedBox(height: 16.0), // Espacio vertical
              ],
            ),
          Column(
            children: [
              DropdownButtonFormField<Manicurista>(
                decoration: InputDecoration(
                  labelText: 'Manicurista',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                ),
                value: _selectedManicurista,
                items:
                    _manicuristas.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(m.nombreCompleto),
                      );
                    }).toList(),
                onChanged: (val) => setState(() => _selectedManicurista = val),
                validator:
                    (val) => val == null ? 'Seleccione una manicurista' : null,
              ),
              const SizedBox(height: 16.0), // Espacio vertical
            ],
          ),
          Column(
            children: [
              DropdownButtonFormField<EstadoCita>(
                decoration: InputDecoration(
                  labelText: 'Estado',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                ),
                value: _selectedEstado,
                items:
                    _estados.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e.Estado));
                    }).toList(),
                onChanged: null,
                disabledHint:
                    _selectedEstado != null
                        ? Text(_selectedEstado!.Estado)
                        : const Text('Cargando...'),
              ),
              const SizedBox(height: 16.0), // Espacio vertical
            ],
          ),
          Column(
            children: [
              TextFormField(
                controller: _fechaController,
                readOnly: true,
                onTap: _seleccionarFecha,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                ),
                validator:
                    (val) => val!.isEmpty ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 16.0), // Espacio vertical
            ],
          ),
          Column(
            children: [
              TextFormField(
                controller: _horaController,
                readOnly: true,
                onTap: _seleccionarHora,
                decoration: InputDecoration(
                  labelText: 'Hora',
                  fillColor: Colors.white,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.pinkAccent,
                      width: 2.5,
                    ),
                  ),
                ),
                validator: (val) => val!.isEmpty ? 'Seleccione una hora' : null,
              ),
              const SizedBox(height: 16.0), // Espacio vertical
            ],
          ),
          TextFormField(
            controller: _descripcionController,
            decoration: InputDecoration(
              labelText: 'Descripcion',
              fillColor: Colors.white,
              filled: true,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.pinkAccent,
                  width: 2.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.pinkAccent,
                  width: 2.5,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Colors.pinkAccent,
                  width: 2.5,
                ),
              ),
            ),
            validator: (val) => val!.isEmpty ? 'Escriba la descripción' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildStepServicios() {
    return Column(
      children:
          _servicios.map((servicio) {
            final isSelected = _serviciosSeleccionados.contains(servicio);
            return Card(
              child: ListTile(
                leading: Image.network(
                  servicio.url_imagen,
                  width: 50,
                  height: 50,
                ),
                title: Text(servicio.nombre),
                subtitle: Text(
                  'Precio: \$${servicio.precio.toStringAsFixed(2)}',
                ),
                trailing: Checkbox(
                  value: isSelected,
                  onChanged: (_) {
                    setState(() {
                      if (isSelected) {
                        _serviciosSeleccionados.remove(servicio);
                      } else {
                        _serviciosSeleccionados.add(servicio);
                      }
                    });
                  },
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildStepResumen() {
    final total = _serviciosSeleccionados.fold<double>(
      0,
      (sum, item) => sum + item.precio,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Servicios seleccionados:'),
        ..._serviciosSeleccionados.map(
          (servicio) => ListTile(
            title: Text(servicio.nombre),
            subtitle: Text('Precio: \$${servicio.precio.toStringAsFixed(2)}'),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Total estimado: \$${total.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cita')),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        steps: _buildSteps(),
      ),
    );
  }
}
