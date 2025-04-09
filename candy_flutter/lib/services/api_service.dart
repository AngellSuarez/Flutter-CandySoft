import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class ApiService {
  final String baseUrl = 'https://angelsuarez.pythonanywhere.com/api/';
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();

  //todo el tema del login - registro - logout y perfil
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await secureStorage.write(key: 'access_token', value: data['access']);
      await secureStorage.write(key: 'refresh_token', value: data['refresh']);
      await secureStorage.write(
        key: 'user_id',
        value: data['user_id'].toString(),
      );
      await secureStorage.write(key: 'rol', value: data['rol']);

      return {'success': true, 'data': data};
    } else {
      return {
        'success': false,
        'message': 'Credenciales incorrectas o error en el servidor',
      };
    }
  }

  //conseguir el usuario osea el perfil
  Future<Map<String, dynamic>> conseguirUsuario() async {
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) {
      return {'success': false, 'message': 'No hay token de acceso'};
    }

    final response = await http.get(
      Uri.parse('$baseUrl/auth/user/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      return {'success': true, 'data': user};
    } else {
      return {'success': false, 'message': 'Error al conseguir el usuario'};
    }
  }

  Future<Map<String, dynamic>> logout() async {
    final token = await secureStorage.read(key: 'access_token');
    if (token == null) {
      return {'success': false, 'message': 'No hay token de acceso'};
    }

    final response = await http.post(
      Uri.parse('$baseUrl/auth/logout/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      await secureStorage.deleteAll();
      return {'success': true, 'message': 'Logout exitoso'};
    } else {
      return {
        'success': false,
        'message': 'Error al cerrar sesión: ${response.statusCode}',
      };
    }
  }

  //registrar
  Future<bool> registrarUsuario(Map<String, dynamic> data) async {
    final url = Uri.parse('$baseUrl/auth/register/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      return true; // Registro exitoso
    } else {
      throw Exception(
        jsonDecode(response.body)['error'] ?? 'Error al registrar el usuario',
      ); // Error en el registro
    }
  }

  //solicitar el codigo
  Future<Map<String, dynamic>> solicitarResetPassword(String correo) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password/reset-request/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo}),
    );

    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Codigo enviado al correo'};
    } else {
      return {
        'success': false,
        'message': 'Error al solicitar el codigo: ${response.body}',
      };
    }
  }

  //confirmar el reset o enviar la nueva
  Future<Map<String, dynamic>> confirmarResetPassword({
    required String correo,
    required String codigo,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/password/reset-confirm/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'correo': correo,
        'codigo': codigo,
        'nueva_password': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'message': 'Contraseña actualizada correctamente',
      };
    } else {
      return {
        'success': false,
        'message': 'Error al confirmar el reset: ${response.body}',
      };
    }
  }
}

//todo el tema de los servicios
class ServicioAPi {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/citas/servicios/';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<List<Map<String, dynamic>>> obtenerServicios() async {
    final token = await _getToken();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> crearServicio(
    Map<String, dynamic> datos,
    String pathImage,
  ) async {
    final token = await _getToken();
    final formData = FormData.fromMap({
      ...datos,
      'imagen': await MultipartFile.fromFile(
        pathImage,
        filename: pathImage.split('/').last,
      ),
    });

    final response = await _dio.post(
      baseUrl,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear el servicio: ${response.statusCode}');
    }
  }

  Future<void> editarServicio(
    int id,
    Map<String, dynamic> datos, {
    String? pathImagen,
  }) async {
    final token = await _getToken();

    final formData = FormData.fromMap({
      ...datos,
      if (pathImagen != null)
        'imagen': await MultipartFile.fromFile(
          pathImagen,
          filename: pathImagen.split('/').last,
        ),
    });

    final response = await _dio.put(
      '$baseUrl$id/',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al editar el servicio: ${response.statusCode}');
    }
  }
}

//todo el tema de las novedades
class NovedadesApi {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/liquidaciones/novedades/';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  //obtener novedades
  Future<List<Map<String, dynamic>>> obtenerNovedades() async {
    final token = await _getToken();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  //crear novedad
  Future<void> crearNovedad(Map<String, dynamic> datos) async {
    final token = await _getToken();
    final response = await _dio.post(
      baseUrl,
      data: datos,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    if (response.statusCode != 201) {
      throw Exception('Error al crear la novedad: ${response.statusCode}');
    }
  }

  Future<void> eliminarNovedad(int id) async {
    final token = await _getToken();
    final response = await _dio.delete(
      '$baseUrl$id/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la novedad: ${response.statusCode}');
    }
  }
}

//todo el tema de liquidaciones

//todo el tema de manicuristas
class ManicuristasApi {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/usuarios/manicuristas/activos';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<List<Map<String, dynamic>>> obtenerManicuristasActivos() async {
    final token = await _getToken();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    return List<Map<String, dynamic>>.from(response.data);
  }
}

//todo el tema de los clientes
class ClientesApi {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/usuarios/clientes/activos';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<List<Map<String, dynamic>>> obtenerClientesActivos() async {
    final token = await _getToken();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}

//todo el tema de los estados de las citas
class EstadosCitasApi {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/citas/estados-cita/';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<List<Map<String, dynamic>>> obtenerEstadosCita() async {
    final token = await _getToken();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }
}

//todo el tema de las citas
class CitasApi {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl =
      'https://angelsuarez.pythonanywhere.com/api/citas/citas-venta/';

  Future<String?> _getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<List<Map<String, dynamic>>> obtenerCitas() async {
    final token = await _getToken();
    final response = await _dio.get(
      baseUrl,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<Map<String, dynamic>> crearCitaYRetornar(
    Map<String, dynamic> data,
  ) async {
    final token = await _getToken();
    final response = await _dio.post(
      baseUrl,
      data: data,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Error al crear cita');
    }
  }

  Future<List<Map<String, dynamic>>> obtenerCitasPorManicurista(int id) async {
    final token = await _getToken();
    final response = await _dio.get(
      '$baseUrl?manicurista_id=$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> detallesDeCita(int id) async {
    final token = await _getToken();
    final response = await _dio.get(
      'https://angelsuarez.pythonanywhere.com/api/citas/servicios-cita/?cita_id=$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> obtenerCitasPorCliente(int id) async {
    final token = await _getToken();
    final response = await _dio.get(
      '$baseUrl?cliente_id=$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<void> agregarServiciosCita(
    List<Map<String, dynamic>> servicios,
  ) async {
    final token = await _getToken();
    final response = await _dio.post(
      'https://angelsuarez.pythonanywhere.com/api/citas/servicios-cita/batch/',
      data: servicios,
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al agregar servicios a la cita');
    }
  }

  Future<void> eliminarCita(int id) async {
    final token = await _getToken();
    await _dio.delete(
      '$baseUrl$id/',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }
}
