import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import './perfil.dart';
import 'manicurista_screens/citas_manicurista.dart';

class ManicuristaHome extends StatefulWidget {
  const ManicuristaHome({super.key});

  @override
  State<ManicuristaHome> createState() => _ManicuristaHomeState();
}

class _ManicuristaHomeState extends State<ManicuristaHome> {
  int _selectedIndex = 0;

  Widget _buildPage(String title) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: const Color.fromARGB(0, 224, 224, 224),
            child: Center(
              child: Image.asset(
                'assets/images/logo_sin_fondo.png',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "'Tus manos crean más que belleza, transforman la confianza y el bienestar de quienes atiendes. Cada diseño, cada color y cada detalle es una obra de arte que refleja tu pasión y talento.' Epa Colombia 23:30",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  final List<String> _titles = ['Liquidaciones'];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manicurista - ${user?['nombre'] ?? 'Cargando...'}'),
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
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF1A7B0), Color(0xFFE88798)],
                        ),
                      ),
                      padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            child: Icon(Icons.person, size: 50),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "${user?['nombre'] ?? ''} ${user?['apellido'] ?? ''}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            user?['correo'] ?? '',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                        color: Colors.pinkAccent,
                      ),
                      title: const Text('Mis citas'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MisCitasManicuristaPage(),
                          ),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Colors.pinkAccent,
                      ),
                      title: const Text('Perfil'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PerfilPage()),
                        );
                      },
                    ),
                    const Divider(),
                  ],
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.grey),
                title: const Text('Cerrar sesión'),
                onTap: () {
                  authProvider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
      ),
      body: _buildPage(_titles[_selectedIndex]),
    );
  }
}
