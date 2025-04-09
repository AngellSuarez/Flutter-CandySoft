import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class NovedadesAdminPage extends StatefulWidget {
  const NovedadesAdminPage({super.key});

  @override
  State<NovedadesAdminPage> createState() => _NovedadesAdminPageState();
}

class _NovedadesAdminPageState extends State<NovedadesAdminPage> {
  final NovedadesApi _api = NovedadesApi();
  List<Map<String, dynamic>> _novedades = [];
  List<Map<String, dynamic>> _filtradas = [];

  bool _loading = true;
  String _busquedaManicurista = '';
  DateTime? _fechaSeleccionada;

  @override
  void initState() {
    super.initState();
    _fetchNovedades();
  }

  Future<void> _fetchNovedades() async {
    setState(() => _loading = true);
    try {
      final novedades = await _api.obtenerNovedades();
      setState(() {
        _novedades = novedades;
        _filtradas = novedades;
        _loading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al obtener novedades')),
      );
      setState(() => _loading = false);
    }
  }

  void _filtrar() {
    setState(() {
      _filtradas =
          _novedades.where((novedad) {
            final nombre = novedad['manicurista_nombre']?.toLowerCase() ?? '';
            final fecha = novedad['Fecha'];

            final coincideNombre = nombre.contains(
              _busquedaManicurista.toLowerCase(),
            );
            final coincideFecha =
                _fechaSeleccionada == null ||
                fecha == DateFormat('yyyy-MM-dd').format(_fechaSeleccionada!);

            return coincideNombre && coincideFecha;
          }).toList();
    });
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (fecha != null) {
      setState(() => _fechaSeleccionada = fecha);
      _filtrar();
    }
  }

  void _limpiarFecha() {
    setState(() => _fechaSeleccionada = null);
    _filtrar();
  }

  Future<void> _confirmarEliminar(int id) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar novedad'),
            content: const Text(
              '¿Estás seguro que deseas eliminar esta novedad?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child: const Text('Eliminar'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      await _eliminarNovedad(id);
    }
  }

  Future<void> _eliminarNovedad(int id) async {
    try {
      await _api.eliminarNovedad(id);
      await _fetchNovedades();
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo eliminar la novedad')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Novedades'),
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
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
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
                        _filtrar();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: _seleccionarFecha,
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
                        _filtradas.isEmpty
                            ? const Center(child: Text('No hay novedades.'))
                            : ListView.builder(
                              itemCount: _filtradas.length,
                              itemBuilder: (context, index) {
                                final novedad = _filtradas[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  color: Colors.purple.shade50,
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Manicurista: ${novedad['manicurista_nombre']}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text('Fecha: ${novedad['Fecha']}'),
                                            Text(
                                              'Hora Entrada: ${novedad['HoraEntrada']}',
                                            ),
                                            Text(
                                              'Hora Salida: ${novedad['HoraSalida']}',
                                            ),
                                            if (novedad['Motivo'] != null &&
                                                novedad['Motivo']
                                                    .toString()
                                                    .trim()
                                                    .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4.0,
                                                ),
                                                child: Text(
                                                  'Motivo: ${novedad['Motivo']}',
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      // Botón de eliminar posicionado en el medio del lado derecho
                                      Positioned(
                                        right: 8,
                                        top: 0,
                                        bottom: 0,
                                        child: Center(
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _confirmarEliminar(
                                                  novedad['id'],
                                                ),
                                          ),
                                        ),
                                      ),
                                    ],
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
            '/crear_novedad',
          ).then((_) => _fetchNovedades());
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
