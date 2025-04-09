import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  //verificar el login si esta autenticado
  Future<void> login(String correo, String pasword) async {
    _isLoading = true;
    notifyListeners();

    final result = await _apiService.login(correo, pasword);

    if (result['success']) {
      _isAuthenticated = true;
      _user = result['data'];
    } else {
      _isAuthenticated = false;
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  //relizar la verificacion para el logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _apiService.logout();
    _isAuthenticated = false;
    _user = null;

    _isLoading = false;
    notifyListeners();
  }

  //verificar si el usuario esta autenticado para conseguir su info
  Future<void> conseguirUsuario() async {
    final result = await _apiService.conseguirUsuario();

    if (result['success']) {
      _user = result['data'];
      _isAuthenticated = true;
    } else {
      _user = null;
      _isAuthenticated = false;
    }
    notifyListeners();
  }
}
