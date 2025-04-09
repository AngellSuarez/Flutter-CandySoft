import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'cliente_home.dart';
import 'admin_home.dart';
import 'manicurista_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      await authProvider.login(
        _correoController.text.trim(),
        _passwordController.text.trim(),
      );

      if (authProvider.isAuthenticated) {
        final rol = authProvider.user?['rol'];

        Widget nextScreen;
        switch (rol) {
          case 'Cliente':
            nextScreen = const ClienteHome();
            break;
          case 'Manicurista':
            nextScreen = const ManicuristaHome();
            break;
          case 'Admin':
            nextScreen = const AdminHome();
            break;
          default:
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Rol no reconocido')));
            return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => nextScreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Credenciales inválidas o error en el servidor"),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF1A7B0), // Medium pink (top)
            Color(0xFFF8CACA), // Slightly darker light pink (middle-top)
            Color(0xFFFDECEA), // Light pink (middle)
            Color(0xFFF8CACA), // Slightly darker light pink (middle-bottom)
            Color(0xFFF1A7B0), // Medium pink (bottom)
          ],
          stops: [0.0, 0.25, 0.7, 0.75, 1.0],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),

                  // dentro de ListView > children:
                  const SizedBox(height: 12),
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su correo';
                        }
                        return null;
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
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Contraseña',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña';
                        }
                        return null;
                      },
                    ),
                  ),

                  const SizedBox(height: 24),
                  authProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _handleLogin(authProvider),
                          child: const Text(
                            'Ingresar',
                            style: TextStyle(color: Color.fromRGBO(0, 0, 0, 1)),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(249, 132, 255, 1),
                            elevation: 6,
                          ),
                        ),
                      ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/recuperar-request');
                    },
                    child: const Text("¿Olvidaste tu contraseña?"),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/registrar');
                    },
                    child: const Text("¿No tienes cuenta?, Registrate"),
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
