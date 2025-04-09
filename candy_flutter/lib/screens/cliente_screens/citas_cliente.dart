import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../../../services/api_service.dart';
import '../compartidas/citas_detalles.dart'; // Asegúrate de que esta ruta sea correcta

class MisCitasPage extends StatefulWidget {
  const MisCitasPage({super.key});

  @override
  State<MisCitasPage> createState() => _MisCitasPageState();
}

class _MisCitasPageState extends State<MisCitasPage> {
  final _storage = const FlutterSecureStorage();
  final _citasApi = CitasApi();

  List<Map<String, dynamic>> _citas = [];
  List<Map<String, dynamic>> _citasFiltradas = [];
  bool _cargando = true;

  String _busquedaManicurista = '';
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarCitasCliente();
  }

  Future<void> _cargarCitasCliente() async {
    final userIdStr = await _storage.read(key: 'user_id');
    final userId = int.tryParse(userIdStr ?? '');

    if (userId != null) {
      try {
        final citas = await _citasApi.obtenerCitasPorCliente(userId);
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
            final manicuristaNombre =
                cita['manicurista_nombre']?.toLowerCase() ?? '';
            final fecha = cita['Fecha'];

            final coincideNombre = manicuristaNombre.contains(
              _busquedaManicurista.toLowerCase(),
            );
            final coincideFecha =
                _fechaSeleccionada == null ||
                fecha == DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);

            return coincideNombre && coincideFecha;
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

  Future<void> _cancelarCita(Map<String, dynamic> cita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar cancelación'),
            content: const Text('¿Deseas cancelar esta cita?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí'),
              ),
            ],
          ),
    );

    if (confirmar == true) {
      try {
        await _citasApi.eliminarCita(cita['id']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cita cancelada exitosamente')),
        );
        _cargarCitasCliente(); // Recargar la lista de citas
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cancelar la cita')),
        );
      }
    }
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
        title: Text('Mis citas agendadas'),
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
                        labelText: 'Buscar por Manicurista',
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
                        _busquedaManicurista = value;
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
                              child: Text('No tienes citas que coincidan'),
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
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            size: 28,
                                            color: Color.fromRGBO(
                                              249,
                                              132,
                                              255,
                                              1,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Fecha: ${cita['Fecha']}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Hora: ${cita['Hora']}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Estado: ${cita['estado_nombre']}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
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
                                                            ) // Color para pendiente
                                                            : null, // Mantiene el color por defecto si no es pendiente ni cancelada
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Manicurista: ${cita['manicurista_nombre']}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 16),
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
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              // Botón para ver detalles
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.info,
                                                  color: Color.fromARGB(
                                                    255,
                                                    240,
                                                    33,
                                                    243,
                                                  ),
                                                  size: 28,
                                                ),
                                                tooltip: 'Ver detalles',
                                                onPressed:
                                                    () =>
                                                        _verDetallesCita(cita),
                                              ),
                                              // Botón para cancelar cita (solo si no está cancelada)
                                              if (estadoCita != 'cancelada')
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.cancel,
                                                    color: Colors.red,
                                                    size: 28,
                                                  ),
                                                  tooltip: 'Cancelar cita',
                                                  onPressed:
                                                      () => _cancelarCita(cita),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/crear_cita',
          ).then((_) => _cargarCitasCliente());
        },
        tooltip: 'Agregar Cita',
        shape: CircleBorder(),
        child: Material(
          shape: CircleBorder(),
          color: Colors.transparent,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromARGB(255, 255, 117, 133),
                  Color.fromARGB(255, 231, 97, 122),
                ],
              ),
              borderRadius: BorderRadius.circular(90),
            ),
            child: const Padding(
              padding: EdgeInsets.all(11.0),
              child: Icon(Icons.add, color: Colors.white, size: 30),
            ),
          ),
        ),
      ),
    );
  }
}
