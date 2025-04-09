import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).conseguirUsuario();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final perfil = user?['perfil'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
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
          user == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Color(0xFFDCD0F2),
                      child: Icon(Icons.person, size: 40),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ListTile(
                    title: const Text('Nombre'),
                    subtitle: Text(
                      '${perfil?['nombre'] ?? ''} ${perfil?['apellido'] ?? ''}',
                    ),
                  ),
                  ListTile(
                    title: const Text('Correo'),
                    subtitle: Text(perfil?['correo'] ?? ''),
                  ),
                  ListTile(
                    title: const Text('Tipo de documento'),
                    subtitle: Text(perfil?['tipo_documento'] ?? ''),
                  ),
                  ListTile(
                    title: const Text('Número de documento'),
                    subtitle: Text(perfil?['numero_documento'] ?? ''),
                  ),
                  ListTile(
                    title: const Text('Celular'),
                    subtitle: Text(perfil?['celular'] ?? ''),
                  ),
                  ListTile(
                    title: const Text('Rol'),
                    subtitle: Text(user['rol'] ?? ''),
                  ),
                ],
              ),
    );
  }
}
