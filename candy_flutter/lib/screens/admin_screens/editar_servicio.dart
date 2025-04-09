import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../services/api_service.dart';

class EditarServicioPage extends StatefulWidget {
  final Map<String, dynamic> servicio;

  const EditarServicioPage({required this.servicio, super.key});

  @override
  State<EditarServicioPage> createState() => _EditarServicioPageState();
}

class _EditarServicioPageState extends State<EditarServicioPage> {
  final _formKey = GlobalKey<FormState>();
  final _api = ServicioAPi();

  late TextEditingController _nombreController;
  late TextEditingController _descripcionController;
  late TextEditingController _precioController;
  String _estado = 'activo';
  File? _nuevaImagen;

  @override
  void initState() {
    super.initState();
    final s = widget.servicio;
    _nombreController = TextEditingController(text: s['nombre']);
    _descripcionController = TextEditingController(text: s['descripcion']);
    _precioController = TextEditingController(text: s['precio'].toString());
    _estado = s['estado'];
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _nuevaImagen = File(picked.path);
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate()) {
      final datos = {
        'nombre': _nombreController.text,
        'descripcion': _descripcionController.text,
        'precio': _precioController.text,
        'estado': _estado,
      };

      try {
        await _api.editarServicio(
          widget.servicio['id'],
          datos,
          pathImagen: _nuevaImagen?.path,
        );
        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagenUrl = widget.servicio['imagen'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar servicio'),
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
                  validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
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
                  validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
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
                  validator: (v) => v!.isEmpty ? 'Campo obligatorio' : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField(
                  value: _estado,
                  items:
                      ['activo', 'inactivo']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
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
              const SizedBox(height: 10),
              if (_nuevaImagen != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Image.file(_nuevaImagen!, height: 150),
                )
              else if (imagenUrl != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Image.network(imagenUrl, height: 150),
                ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text('Cambiar imagen'),
                  onPressed: _seleccionarImagen,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarCambios,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
