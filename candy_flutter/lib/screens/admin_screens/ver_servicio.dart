import 'package:flutter/material.dart';

class VerServicioPage extends StatelessWidget {
  final Map<String, dynamic> servicio;

  const VerServicioPage({super.key, required this.servicio});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles servicio'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const SizedBox(height: 16),
            Text(
              'Nombre: ${servicio['nombre']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Descripción: ${servicio['descripcion']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Precio: \$${servicio['precio']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Estado: ${servicio['estado']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text('Imagen:', style: TextStyle(fontSize: 18)),
            if (servicio['url_imagen'] != null)
              Image.network(
                servicio['url_imagen'],
                height: 350,
                fit: BoxFit.contain,
              ),
          ],
        ),
      ),
    );
  }
}
