import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import '../compartidas/citas_detalles.dart'; // Asegúrate de que esta ruta sea correcta

class MisCitasManicuristaPage extends StatefulWidget {
  const MisCitasManicuristaPage({super.key});

  @override
  State<MisCitasManicuristaPage> createState() =>
      _MisCitasManicuristaPageState();
}

class _MisCitasManicuristaPageState extends State<MisCitasManicuristaPage> {
  final _storage = const FlutterSecureStorage();
  final _citasApi = CitasApi();

  List<Map<String, dynamic>> _citas = [];
  List<Map<String, dynamic>> _citasFiltradas = [];
  bool _cargando = true;

  String _busquedaCliente = '';
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarCitasManicurista();
  }

  Future<void> _cargarCitasManicurista() async {
    final userIdStr = await _storage.read(key: 'user_id');
    final userId = int.tryParse(userIdStr ?? '');

    if (userId != null) {
      try {
        final citas = await _citasApi.obtenerCitasPorManicurista(userId);
        setState(() {
          _citas = citas;
          _citasFiltradas = citas;
          _cargando = false;
        });
      } catch (e) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Error al cargar citas')));
      }
    }
  }

  void _filtrarCitas() {
    setState(() {
      _citasFiltradas =
          _citas.where((cita) {
            final clienteNombre = cita['cliente_nombre']?.toLowerCase() ?? '';
            final fecha = cita['Fecha'];

            final coincideCliente = clienteNombre.contains(
              _busquedaCliente.toLowerCase(),
            );
            final coincideFecha =
                _fechaSeleccionada == null ||
                fecha == DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);

            return coincideCliente && coincideFecha;
          }).toList();
    });
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
      });
      _filtrarCitas();
    }
  }

  void _limpiarFecha() {
    setState(() {
      _fechaSeleccionada = null;
    });
    _filtrarCitas();
  }

  void _verDetallesCita(Map<String, dynamic> cita) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetalleCitaPage(cita: cita)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis citas'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF1A7B0), Color(0xFFE88798)],
            ),
          ),
        ),
        backgroundColor:
            Colors
                .transparent, // Asegúrate de que el backgroundColor sea transparente para que se vea el degradado del flexibleSpace
        elevation:
            0, // Opcional: Elimina la sombra debajo del AppBar si lo deseas
      ),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Nombre del cliente',
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
                      onChanged: (value) {
                        _busquedaCliente = value;
                        _filtrarCitas();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _seleccionarFecha(context),
                          icon: const Icon(
                            Icons.date_range,
                            color: Colors.white,
                          ),
                          label: Text(
                            _fechaSeleccionada != null
                                ? DateFormat(
                                  'yyyy-MM-dd',
                                ).format(_fechaSeleccionada!)
                                : 'Seleccionar fecha',
                            style: const TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(
                              249,
                              132,
                              255,
                              1,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            elevation: 2,
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_fechaSeleccionada != null)
                          IconButton(
                            onPressed: _limpiarFecha,
                            icon: const Icon(
                              Icons.clear,
                              color: Color.fromRGBO(249, 132, 255, 1),
                              size: 20.0,
                            ),
                            tooltip: 'Quitar filtro de fecha',
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _citasFiltradas.isEmpty
                            ? const Center(
                              child: Text('No hay citas que coincidan'),
                            )
                            : ListView.builder(
                              itemCount: _citasFiltradas.length,
                              itemBuilder: (context, index) {
                                final cita = _citasFiltradas[index];
                                final estadoCita =
                                    cita['estado_nombre']?.toLowerCase() ?? '';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Card(
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      side: BorderSide(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    color: Colors.grey.shade50,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            color: const Color.fromARGB(
                                              255,
                                              243,
                                              125,
                                              166,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Fecha: ${cita['Fecha']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                                Text(
                                                  'Hora: ${cita['Hora']}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                Text(
                                                  'Estado: ${cita['estado_nombre']}',
                                                  style: TextStyle(
                                                    color:
                                                        estadoCita ==
                                                                'cancelada'
                                                            ? const Color.fromARGB(
                                                              255,
                                                              255,
                                                              0,
                                                              0,
                                                            )
                                                            : estadoCita ==
                                                                'pendiente'
                                                            ? const Color.fromARGB(
                                                              255,
                                                              247,
                                                              2,
                                                              255,
                                                            )
                                                            : Colors
                                                                .grey
                                                                .shade700, // Mantiene el color original para otros estados
                                                  ),
                                                ),
                                                Text(
                                                  'Cliente: ${cita['cliente_nombre']}',
                                                  style: TextStyle(
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                '\$${cita['Total']}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.info,
                                                  color: const Color.fromARGB(
                                                    255,
                                                    233,
                                                    61,
                                                    118,
                                                  ),
                                                ),
                                                tooltip: 'Ver detalles',
                                                onPressed:
                                                    () =>
                                                        _verDetallesCita(cita),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
