import 'package:flutter/material.dart';
import '../services/api_service.dart'; // Ajusta el import según tu estructura

class ResetPasswordConfirmScreen extends StatefulWidget {
  final String correo;

  const ResetPasswordConfirmScreen({super.key, required this.correo});

  @override
  _ResetPasswordConfirmScreenState createState() =>
      _ResetPasswordConfirmScreenState();
}

class _ResetPasswordConfirmScreenState
    extends State<ResetPasswordConfirmScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _correoController.text = widget.correo;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    print('Correo: ${_correoController.text}');
    print('Código: ${_codeController.text}');
    print('Nueva contraseña: ${_newPasswordController.text}');

    final result = await _apiService.confirmarResetPassword(
      correo: _correoController.text.trim(),
      codigo: _codeController.text.trim(),
      newPassword: _newPasswordController.text.trim(),
    );

    setState(() => _loading = false);

    if (result['success']) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada exitosamente')),
      );
    } else {
      _showError(result['message']);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
          title: const Text('Confirmar Código'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ), // O el color que prefieras
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 24),
                  Image.asset(
                    'assets/images/logo_sin_fondo.png',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ingresa el código que recibiste y tu nueva contraseña.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
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
                      controller: _codeController,
                      decoration: InputDecoration(
                        labelText: 'Código',
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
                      decoration: InputDecoration(
                        labelText: 'Correo',
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
                      readOnly:
                          true, // Para que el usuario no pueda editar el correo
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
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
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
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(249, 132, 255, 1),
                        elevation: 6,
                      ),
                      child:
                          _loading
                              ? const CircularProgressIndicator()
                              : const Text(
                                'Confirmar cambio',
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
