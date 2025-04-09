import '../services/api_service.dart';
import 'package:flutter/material.dart';
import './recuperar_confirm.dart';

class ResetPasswordRequestScreen extends StatefulWidget {
  const ResetPasswordRequestScreen({super.key});

  @override
  _ResetPasswordRequestScreenState createState() =>
      _ResetPasswordRequestScreenState();
}

class _ResetPasswordRequestScreenState
    extends State<ResetPasswordRequestScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    final result = await _apiService.solicitarResetPassword(
      _emailController.text.trim(),
    );

    setState(() => _loading = false);

    if (result['success']) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ResetPasswordConfirmScreen(
                correo: _emailController.text.trim(),
              ),
        ),
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
          title: const Text('Recuperar Contraseña'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
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
                    'Ingresa tu correo para recibir un código.',
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
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Correo electrónico',
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
                                'Enviar código',
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
