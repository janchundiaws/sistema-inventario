import 'package:flutter/material.dart';
import '../models/role.dart';
import '../services/api_service.dart';

class RoleProvider extends ChangeNotifier {
  List<Role> _roles = [];
  bool _isLoading = false;
  String? _error;

  List<Role> get roles => _roles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar roles desde la API
  Future<void> loadRoles() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getRoles();
      
      if (response['success']) {
        final List<dynamic> rolesData = response['data'];
        _roles = rolesData.map((json) => Role.fromJson(json)).toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Error al cargar roles';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener rol por ID
  Role? getRoleById(int id) {
    try {
      return _roles.firstWhere((role) => role.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener rol por nombre
  Role? getRoleByName(String name) {
    try {
      return _roles.firstWhere((role) => role.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar si los roles están cargados
  bool get hasRoles => _roles.isNotEmpty;
} 