import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class DetalleCitaPage extends StatefulWidget {
  final Map<String, dynamic> cita;

  const DetalleCitaPage({super.key, required this.cita});

  @override
  State<DetalleCitaPage> createState() => _DetalleCitaPageState();
}

class _DetalleCitaPageState extends State<DetalleCitaPage> {
  final CitasApi _citaApi = CitasApi();
  final ServicioAPi _servicioApi = ServicioAPi();

  List<Map<String, dynamic>> _serviciosCita = [];
  List<Map<String, dynamic>> _serviciosDetalle = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarServiciosCita();
  }

  Future<void> _cargarServiciosCita() async {
    setState(() {
      _cargando = true;
    });

    try {
      // Obtener los servicios asociados a la cita
      final serviciosCita = await _citaApi.detallesDeCita(widget.cita['id']);

      // Si hay servicios, obtener los detalles de cada uno
      if (serviciosCita.isNotEmpty) {
        final todosLosServicios = await _servicioApi.obtenerServicios();

        final List<Map<String, dynamic>> serviciosConDetalles = [];

        for (var servicioCita in serviciosCita) {
          final servicioId = servicioCita['servicio_id'];
          final servicioCompleto = todosLosServicios.firstWhere(
            (s) => s['id'] == servicioId,
            orElse:
                () => {
                  'id': servicioId,
                  'nombre': 'Servicio no encontrado',
                  'descripcion': '',
                  'precio': '0',
                  'estado': '',
                  'url_imagen': '',
                },
          );

          serviciosConDetalles.add({
            ...servicioCompleto,
            'subtotal': servicioCita['subtotal'],
          });
        }

        setState(() {
          _serviciosCita = serviciosCita;
          _serviciosDetalle = serviciosConDetalles;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar servicios: $e')));
    } finally {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de la cita'),
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
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ), // Radio de redondeo de la Card
                        side: BorderSide(
                          color: const Color.fromARGB(255, 203, 203, 203),
                        ),
                      ),
                      color: Colors.grey.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                // Usamos BoxDecoration en lugar de const BoxDecoration para poder usar BorderRadius
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE88798),
                                    Color(0xFFF1A7B0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(
                                  8.0,
                                ), // Radio de redondeo del fondo rosa
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Información de la Cita',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        227,
                                        227,
                                      ),
                                    ),
                                  ),
                                  const Divider(color: Colors.white70),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Cliente: ${widget.cita['cliente_nombre']}'),
                            Text(
                              'Manicurista: ${widget.cita['manicurista_nombre']}',
                            ),
                            Text('Fecha: ${widget.cita['Fecha']}'),
                            Text('Hora: ${widget.cita['Hora']}'),
                            Text('Estado: ${widget.cita['estado_nombre']}'),
                            Text('Total: \$${widget.cita['Total']}'),
                          ],
                        ),
                      ),
                    ),

                    Card(
                      elevation: 1,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        side: BorderSide(
                          color: const Color.fromARGB(255, 203, 203, 203),
                        ),
                      ),
                      color: const Color.fromARGB(255, 239, 243, 229),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFE88798),
                                    Color(0xFFF1A7B0),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Servicios Incluidos',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge?.copyWith(
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        227,
                                        227,
                                      ),
                                    ),
                                  ),
                                  const Divider(color: Colors.white70),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_serviciosDetalle.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: Text(
                                    'No hay servicios asociados a esta cita',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _serviciosDetalle.length,
                                itemBuilder: (context, index) {
                                  final servicio = _serviciosDetalle[index];
                                  return ListTile(
                                    leading:
                                        servicio['url_imagen'] != null &&
                                                servicio['url_imagen']
                                                    .isNotEmpty
                                            ? Image.network(
                                              servicio['url_imagen'],
                                              width: 50,
                                              height: 50,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (_, __, ___) => const Icon(
                                                    Icons.spa,
                                                    size: 40,
                                                    color: Colors.pinkAccent,
                                                  ),
                                            )
                                            : const Icon(
                                              Icons.spa,
                                              size: 40,
                                              color: Colors.pinkAccent,
                                            ),
                                    title: Text(
                                      servicio['nombre'],
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                    subtitle: Text(
                                      servicio['descripcion'],
                                      style: const TextStyle(
                                        color: Color.fromARGB(
                                          255,
                                          106,
                                          105,
                                          105,
                                        ),
                                      ),
                                    ),
                                    trailing: Text(
                                      '\$${servicio['subtotal']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
