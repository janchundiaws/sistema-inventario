import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Inicializar el estado de autenticación
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Verificar si hay sesión guardada
      final isAuth = await StorageService.isAuthenticated();
      if (isAuth) {
        // Cargar usuario desde almacenamiento local
        final savedUser = await StorageService.getUser();
        if (savedUser != null) {
          _user = savedUser;
          _isAuthenticated = true;
          _error = null;
          
          if (kIsWeb) {
            print('🔄 Sesión restaurada desde localStorage (Web)');
          } else {
            print('🔄 Sesión restaurada desde SharedPreferences (Mobile)');
          }
        } else {
          // Si no hay usuario guardado, intentar cargar desde API
          await _loadUserProfile();
        }
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar perfil del usuario
  Future<void> _loadUserProfile() async {
    try {
      final response = await ApiService.getProfile();
      if (response['success']) {
        _user = User.fromJson(response['user']);
        _isAuthenticated = true;
        _error = null;
        
        // Guardar usuario en almacenamiento local
        await StorageService.saveUser(_user!);
      }
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      await logout();
    }
  }

  // Login
  Future<bool> login(String email, String password, {bool rememberMe = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      
      if (response['success']) {
        // Guardar token y usuario
        await StorageService.saveToken(response['token']);
        _user = User.fromJson(response['user']);
        await StorageService.saveUser(_user!);
        
        // Guardar información de sesión
        await StorageService.saveSessionInfo(
          loginTime: DateTime.now(),
          userAgent: kIsWeb ? 'Flutter Web' : 'Flutter Mobile',
          rememberMe: rememberMe,
        );
        
        _isAuthenticated = true;
        _error = null;
        
        if (kIsWeb) {
          print('✅ Login exitoso - Sesión guardada en localStorage (Web)');
        } else {
          print('✅ Login exitoso - Sesión guardada en SharedPreferences (Mobile)');
        }
        
        return true;
      } else {
        _error = response['message'] ?? 'Error en el login';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Registro
  Future<bool> register(String name, String email, String password, int? roleId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(name, email, password, roleId);
      
      if (response['success']) {
        // Guardar token y usuario
        await StorageService.saveToken(response['token']);
        _user = User.fromJson(response['user']);
        await StorageService.saveUser(_user!);
        
        // Guardar información de sesión
        await StorageService.saveSessionInfo(
          loginTime: DateTime.now(),
          userAgent: kIsWeb ? 'Flutter Web' : 'Flutter Mobile',
          rememberMe: true, // En registro siempre recordar
        );
        
        _isAuthenticated = true;
        _error = null;
        
        if (kIsWeb) {
          print('✅ Registro exitoso - Sesión guardada en localStorage (Web)');
        } else {
          print('✅ Registro exitoso - Sesión guardada en SharedPreferences (Mobile)');
        }
        
        return true;
      } else {
        _error = response['message'] ?? 'Error en el registro';
        return false;
      }
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Limpiar toda la información de sesión
      await StorageService.clearSession();
      
      if (kIsWeb) {
        print('🚪 Logout - Sesión eliminada de localStorage (Web)');
      } else {
        print('🚪 Logout - Sesión eliminada de SharedPreferences (Mobile)');
      }
    } catch (e) {
      // Ignorar errores en logout
      print('⚠️ Error durante logout: $e');
    } finally {
      _user = null;
      _isAuthenticated = false;
      _error = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 