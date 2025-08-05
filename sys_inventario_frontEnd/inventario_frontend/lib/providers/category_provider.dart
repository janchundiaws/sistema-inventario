import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/api_service.dart';

class CategoryProvider extends ChangeNotifier {
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cargar categorías desde la API
  Future<void> loadCategories() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getCategories();
      
      if (response['success']) {
        final List<dynamic> categoriesData = response['data'];
        _categories = categoriesData.map((json) => Category.fromJson(json)).toList();
        _error = null;
      } else {
        _error = response['message'] ?? 'Error al cargar categorías';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear nueva categoría
  Future<bool> createCategory(String name, String? description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createCategory(name, description);
      
      if (response['success']) {
        final newCategory = Category.fromJson(response['data']);
        _categories.add(newCategory);
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al crear categoría';
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

  // Actualizar categoría
  Future<bool> updateCategory(int id, String name, String? description) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateCategory(id, name, description);
      
      if (response['success']) {
        final updatedCategory = Category.fromJson(response['data']);
        final index = _categories.indexWhere((cat) => cat.id == id);
        if (index != -1) {
          _categories[index] = updatedCategory;
        }
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al actualizar categoría';
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

  // Eliminar categoría
  Future<bool> deleteCategory(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.deleteCategory(id);
      
      if (response['success']) {
        _categories.removeWhere((cat) => cat.id == id);
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al eliminar categoría';
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

  // Obtener categoría por ID
  Category? getCategoryById(int id) {
    try {
      return _categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener categoría por nombre
  Category? getCategoryByName(String name) {
    try {
      return _categories.firstWhere((category) => category.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar si las categorías están cargadas
  bool get hasCategories => _categories.isNotEmpty;
} 