import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import 'editar_servicio.dart';
import 'ver_servicio.dart';

class ServiciosAdminPage extends StatefulWidget {
  const ServiciosAdminPage({super.key});

  @override
  State<ServiciosAdminPage> createState() => _ServiciosAdminPageState();
}

class _ServiciosAdminPageState extends State<ServiciosAdminPage> {
  final ServicioAPi _apiService = ServicioAPi();
  late Future<List<Map<String, dynamic>>> _serviciosFuture;

  final TextEditingController _busquedaController = TextEditingController();
  List<Map<String, dynamic>> _todosLosServicios = [];
  List<Map<String, dynamic>> _serviciosFiltrados = [];

  @override
  void initState() {
    super.initState();
    _serviciosFuture = _cargarServicios();
    _busquedaController.addListener(_filtrarServicios);
  }

  Future<List<Map<String, dynamic>>> _cargarServicios() async {
    final servicios = await _apiService.obtenerServicios();
    _todosLosServicios = servicios;
    _serviciosFiltrados = servicios;
    return servicios;
  }

  void _filtrarServicios() {
    final texto = _busquedaController.text.toLowerCase();
    setState(() {
      _serviciosFiltrados =
          _todosLosServicios.where((servicio) {
            final nombre = servicio['nombre']?.toLowerCase() ?? '';
            return nombre.contains(texto);
          }).toList();
    });
  }

  @override
  void dispose() {
    _busquedaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Servicios'),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _serviciosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar servicios: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay servicios disponibles.'));
          } else {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _busquedaController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por Nombre',
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
                  ),
                ),
                Expanded(
                  child:
                      _serviciosFiltrados.isEmpty
                          ? const Center(
                            child: Text('No hay servicios que coincidan.'),
                          )
                          : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: _serviciosFiltrados.length,
                            itemBuilder: (context, index) {
                              final servicio = _serviciosFiltrados[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading:
                                      servicio['url_imagen'] != null
                                          ? Image.network(
                                            servicio['url_imagen'],
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          )
                                          : Container(
                                            width: 60,
                                            height: 60,
                                            color: Colors.grey[300],
                                            child: const Icon(
                                              Icons.image,
                                              size: 32,
                                            ),
                                          ),
                                  title: Text(servicio['nombre']),
                                  subtitle: Text('\$${servicio['precio']} COP'),
                                  trailing: Wrap(
                                    spacing: 8,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => VerServicioPage(
                                                    servicio: servicio,
                                                  ),
                                            ),
                                          ).then((actualizado) {
                                            if (actualizado == true) {
                                              setState(() {
                                                _serviciosFuture =
                                                    _cargarServicios();
                                              });
                                            }
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => EditarServicioPage(
                                                    servicio: servicio,
                                                  ),
                                            ),
                                          ).then((actualizado) {
                                            if (actualizado == true) {
                                              setState(() {
                                                _serviciosFuture =
                                                    _cargarServicios();
                                              });
                                            }
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            );
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/crear_servicio',
          ).then((_) => _cargarServicios());
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
