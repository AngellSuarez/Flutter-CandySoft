import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'screens/login.dart';
import 'screens/registrar.dart';
import 'screens/cliente_home.dart';
import 'screens/admin_home.dart';
import 'screens/manicurista_home.dart';
import 'screens/admin_screens/crear_servicio.dart';
import 'screens/admin_screens/crear_novedad.dart';
import 'screens/compartidas/crear_citas.dart';
import 'screens/recuperar_request.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'CandySoft',
        theme: ThemeData(primarySwatch: Colors.pink, useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginPage(),
          '/registrar': (_) => const RegistrarPage(),
          '/recuperar-request': (_) => ResetPasswordRequestScreen(),
          '/cliente': (_) => const ClienteHome(),
          '/admin': (_) => const AdminHome(),
          '/manicurista': (_) => const ManicuristaHome(),
          '/crear_servicio': (_) => const CrearServicioPage(),
          '/crear_novedad': (_) => const CrearNovedadPage(),
          '/crear_cita': (_) => const CrearCitaPage(),
        },
      ),
    );
  }
}
