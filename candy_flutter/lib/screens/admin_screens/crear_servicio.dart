import 'dart:io';

import 'package:candy_flutter/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CrearServicioPage extends StatefulWidget {
  const CrearServicioPage({super.key});

  @override
  State<CrearServicioPage> createState() => _CrearServicioPageState();
}

class _CrearServicioPageState extends State<CrearServicioPage> {
  final _formKey = GlobalKey<FormState>();
  final _servicioApi = ServicioAPi();

  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();

  String _estado = 'activo';
  File? _imagen;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() => _imagen = File(pickedFile.path));
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate() && _imagen != null) {
      try {
        await _servicioApi.crearServicio({
          'nombre': _nombreController.text,
          'descripcion': _descripcionController.text,
          'precio': _precioController.text,
          'duracion': _duracionController.text,
          'estado': _estado,
        }, _imagen!.path);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Servicio creado con éxito')),
          );
          Navigator.pop(context, true); // Se puede usar para refrescar la lista
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos e imagen')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear servicio'),
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
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
            ), // Opcional: padding alrededor de la lista
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
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
                      (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
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
                  validator:
                      (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextFormField(
                  controller: _precioController,
                  decoration: InputDecoration(
                    labelText: 'Precio',
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
                  keyboardType: TextInputType.number,
                  validator:
                      (value) => value!.isEmpty ? 'Campo requerido' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _estado,
                  items: const [
                    DropdownMenuItem(value: 'activo', child: Text('Activo')),
                    DropdownMenuItem(
                      value: 'inactivo',
                      child: Text('Inactivo'),
                    ),
                  ],
                  onChanged: (val) => setState(() => _estado = val!),
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
                ),
              ),
              const SizedBox(
                height: 12,
              ), // Mantiene el espacio antes de la imagen
              _imagen != null
                  ? Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.file(_imagen!, height: 150),
                  )
                  : Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextButton.icon(
                      icon: const Icon(Icons.image),
                      label: const Text('Seleccionar Imagen'),
                      onPressed: _pickImage,
                    ),
                  ),
              const SizedBox(height: 20), // Mantiene el espacio antes del botón
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Crear Servicio'),
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
