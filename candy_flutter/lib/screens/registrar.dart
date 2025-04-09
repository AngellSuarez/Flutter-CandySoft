import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegistrarPage extends StatefulWidget {
  const RegistrarPage({super.key});

  @override
  State<RegistrarPage> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends State<RegistrarPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _documentoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();

  String _tipoDocumento = 'CC';
  final List<String> _tiposDocumento = ['CC', 'TI', 'CE'];
  bool _loading = false;

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);
    final api = ApiService();

    final data = {
      "username": _usernameController.text.trim(),
      "password": _passwordController.text.trim(),
      "nombre": _nombreController.text.trim(),
      "apellido": _apellidoController.text.trim(),
      "correo": _correoController.text.trim(),
      "tipo_documento": _tipoDocumento,
      "numero_documento": _documentoController.text.trim(),
      "celular": _celularController.text.trim(),
    };

    try {
      final success = await api.registrarUsuario(data);
      setState(() => _loading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario registrado exitosamente")),
        );
        Navigator.pushReplacementNamed(context, "/");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al registrar el usuario')),
        );
      }
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar el usuario: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1A7B0),
            Color(0xFFF8CACA),
            Color(0xFFFDECEA),
            Color(0xFFF8CACA),
            Color(0xFFF1A7B0),
          ],
          stops: [0.0, 0.25, 0.5, 0.75, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Registrarse'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Image.asset(
                    'assets/images/logo_sin_fondo.png',
                    width: 180,
                    height: 180,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Nombre de usuario',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Requerido'
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Contraseña requerida'
                                  : value.length < 6
                                  ? 'La contraseña debe tener al menos 6 caracteres'
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Requerido'
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _apellidoController,
                      decoration: InputDecoration(
                        labelText: 'Apellido',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Requerido'
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Requerido'
                                  : !RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(value)
                                  ? 'Correo inválido'
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _tipoDocumento,
                      decoration: InputDecoration(
                        labelText: 'Tipo de documento',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      items:
                          _tiposDocumento.map((tipo) {
                            return DropdownMenuItem(
                              value: tipo,
                              child: Text(tipo),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _tipoDocumento = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _documentoController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Número de documento',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Requerido'
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextFormField(
                      controller: _celularController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Número de celular',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.pinkAccent,
                            width: 2.5,
                          ),
                        ),
                      ),
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Requerido'
                                  : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _registrarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(249, 132, 255, 1),
                        elevation: 6,
                      ),
                      child:
                          _loading
                              ? const CircularProgressIndicator()
                              : const Text(
                                'Registrarse',
                                style: TextStyle(color: Colors.black),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
