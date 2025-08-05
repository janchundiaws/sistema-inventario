import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _sessionKey = 'session_info';
  static const String _lastLoginKey = 'last_login';
  static const String _rememberMeKey = 'remember_me';

  // Guardar token de autenticación
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      
      if (kIsWeb) {
        print('🔐 Token guardado en localStorage (Web)');
      } else {
        print('🔐 Token guardado en SharedPreferences (Mobile)');
      }
    } catch (e) {
      print('❌ Error al guardar token: $e');
      rethrow;
    }
  }

  // Obtener token de autenticación
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      
      if (kIsWeb) {
        print('🔍 Token recuperado de localStorage (Web): ${token != null ? 'Sí' : 'No'}');
      } else {
        print('🔍 Token recuperado de SharedPreferences (Mobile): ${token != null ? 'Sí' : 'No'}');
      }
      
      return token;
    } catch (e) {
      print('❌ Error al obtener token: $e');
      return null;
    }
  }

  // Eliminar token (logout)
  static Future<void> removeToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      
      if (kIsWeb) {
        print('🗑️ Token eliminado de localStorage (Web)');
      } else {
        print('🗑️ Token eliminado de SharedPreferences (Mobile)');
      }
    } catch (e) {
      print('❌ Error al eliminar token: $e');
      rethrow;
    }
  }

  // Guardar información del usuario
  static Future<void> saveUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = json.encode(user.toJson());
      await prefs.setString(_userKey, userJson);
      
      if (kIsWeb) {
        print('👤 Usuario guardado en localStorage (Web): ${user.name}');
      } else {
        print('👤 Usuario guardado en SharedPreferences (Mobile): ${user.name}');
      }
    } catch (e) {
      print('❌ Error al guardar usuario: $e');
      rethrow;
    }
  }

  // Obtener información del usuario
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      
      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        final user = User.fromJson(userMap);
        
        if (kIsWeb) {
          print('👤 Usuario recuperado de localStorage (Web): ${user.name}');
        } else {
          print('👤 Usuario recuperado de SharedPreferences (Mobile): ${user.name}');
        }
        
        return user;
      }
      
      return null;
    } catch (e) {
      print('❌ Error al obtener usuario: $e');
      return null;
    }
  }

  // Eliminar información del usuario
  static Future<void> removeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      
      if (kIsWeb) {
        print('🗑️ Usuario eliminado de localStorage (Web)');
      } else {
        print('🗑️ Usuario eliminado de SharedPreferences (Mobile)');
      }
    } catch (e) {
      print('❌ Error al eliminar usuario: $e');
      rethrow;
    }
  }

  // Guardar información de sesión
  static Future<void> saveSessionInfo({
    required DateTime loginTime,
    required String userAgent,
    required bool rememberMe,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionInfo = {
        'login_time': loginTime.toIso8601String(),
        'user_agent': userAgent,
        'platform': kIsWeb ? 'web' : 'mobile',
        'remember_me': rememberMe,
      };
      
      await prefs.setString(_sessionKey, json.encode(sessionInfo));
      await prefs.setString(_lastLoginKey, loginTime.toIso8601String());
      await prefs.setBool(_rememberMeKey, rememberMe);
      
      if (kIsWeb) {
        print('💾 Información de sesión guardada en localStorage (Web)');
      } else {
        print('💾 Información de sesión guardada en SharedPreferences (Mobile)');
      }
    } catch (e) {
      print('❌ Error al guardar información de sesión: $e');
      rethrow;
    }
  }

  // Obtener información de sesión
  static Future<Map<String, dynamic>?> getSessionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionJson = prefs.getString(_sessionKey);
      
      if (sessionJson != null) {
        final sessionInfo = json.decode(sessionJson) as Map<String, dynamic>;
        
        if (kIsWeb) {
          print('💾 Información de sesión recuperada de localStorage (Web)');
        } else {
          print('💾 Información de sesión recuperada de SharedPreferences (Mobile)');
        }
        
        return sessionInfo;
      }
      
      return null;
    } catch (e) {
      print('❌ Error al obtener información de sesión: $e');
      return null;
    }
  }

  // Obtener último login
  static Future<DateTime?> getLastLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastLoginStr = prefs.getString(_lastLoginKey);
      
      if (lastLoginStr != null) {
        return DateTime.parse(lastLoginStr);
      }
      
      return null;
    } catch (e) {
      print('❌ Error al obtener último login: $e');
      return null;
    }
  }

  // Verificar si recordar sesión está activado
  static Future<bool> isRememberMeEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_rememberMeKey) ?? false;
    } catch (e) {
      print('❌ Error al verificar remember me: $e');
      return false;
    }
  }

  // Verificar si el usuario está autenticado
  static Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      final user = await getUser();
      
      final isAuth = token != null && user != null;
      
      if (kIsWeb) {
        print('🔍 Verificación de autenticación en localStorage (Web): ${isAuth ? 'Autenticado' : 'No autenticado'}');
      } else {
        print('🔍 Verificación de autenticación en SharedPreferences (Mobile): ${isAuth ? 'Autenticado' : 'No autenticado'}');
      }
      
      return isAuth;
    } catch (e) {
      print('❌ Error al verificar autenticación: $e');
      return false;
    }
  }

  // Limpiar toda la información de sesión
  static Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_sessionKey);
      await prefs.remove(_lastLoginKey);
      await prefs.remove(_rememberMeKey);
      
      if (kIsWeb) {
        print('🧹 Sesión completamente limpiada de localStorage (Web)');
      } else {
        print('🧹 Sesión completamente limpiada de SharedPreferences (Mobile)');
      }
    } catch (e) {
      print('❌ Error al limpiar sesión: $e');
      rethrow;
    }
  }

  // Obtener información de la plataforma
  static String getPlatformInfo() {
    if (kIsWeb) {
      return 'Web (localStorage)';
    } else {
      return 'Mobile (SharedPreferences)';
    }
  }
} 