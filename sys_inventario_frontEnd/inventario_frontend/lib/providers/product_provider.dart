import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _itemsPerPage = 10;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get itemsPerPage => _itemsPerPage;

  // Cargar productos desde la API
  Future<void> loadProducts({
    int page = 1,
    int limit = 10,
    String? search,
    int? categoryId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getProducts(
        page: page,
        limit: limit,
        search: search,
        categoryId: categoryId,
      );
      
      if (response['success']) {
        final List<dynamic> productsData = response['data'];
        _products = productsData.map((json) => Product.fromJson(json)).toList();
        
        // Actualizar información de paginación
        if (response['pagination'] != null) {
          _currentPage = response['pagination']['page'] ?? 1;
          _totalPages = response['pagination']['pages'] ?? 1;
          _totalItems = response['pagination']['total'] ?? 0;
          _itemsPerPage = response['pagination']['limit'] ?? 10;
        }
        
        _error = null;
      } else {
        _error = response['message'] ?? 'Error al cargar productos';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear nuevo producto
  Future<bool> createProduct({
    required String name,
    String? description,
    String? sku,
    int? categoryId,
    required int stockQuantity,
    required double price,
    required double cost,
    bool? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createProduct(
        name: name,
        description: description,
        sku: sku,
        categoryId: categoryId,
        stockQuantity: stockQuantity,
        price: price,
        cost: cost,
        status: status,
      );
      
      if (response['success']) {
        final newProduct = Product.fromJson(response['data']);
        _products.insert(0, newProduct); // Agregar al inicio
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al crear producto';
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

  // Actualizar producto
  Future<bool> updateProduct({
    required int id,
    required String name,
    String? description,
    String? sku,
    int? categoryId,
    required int stockQuantity,
    required double price,
    required double cost,
    bool? status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateProduct(
        id: id,
        name: name,
        description: description,
        sku: sku,
        categoryId: categoryId,
        stockQuantity: stockQuantity,
        price: price,
        cost: cost,
        status: status,
      );
      
      if (response['success']) {
        final updatedProduct = Product.fromJson(response['data']);
        final index = _products.indexWhere((prod) => prod.id == id);
        if (index != -1) {
          _products[index] = updatedProduct;
        }
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al actualizar producto';
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

  // Eliminar producto
  Future<bool> deleteProduct(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.deleteProduct(id);
      
      if (response['success']) {
        _products.removeWhere((prod) => prod.id == id);
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al eliminar producto';
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

  // Obtener producto por ID
  Product? getProductById(int id) {
    try {
      return _products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  // Obtener producto por SKU
  Product? getProductBySku(String sku) {
    try {
      return _products.firstWhere((product) => product.sku == sku);
    } catch (e) {
      return null;
    }
  }

  // Buscar productos por nombre
  List<Product> searchProductsByName(String query) {
    if (query.isEmpty) return _products;
    
    return _products.where((product) =>
        product.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Filtrar productos por categoría
  List<Product> filterProductsByCategory(int categoryId) {
    return _products.where((product) => product.categoryId == categoryId).toList();
  }

  // Obtener productos con stock bajo (menos de 10 unidades)
  List<Product> getLowStockProducts() {
    return _products.where((product) => product.stockQuantity < 10).toList();
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar si los productos están cargados
  bool get hasProducts => _products.isNotEmpty;

  // Refrescar productos (recargar la página actual)
  Future<void> refreshProducts() async {
    await loadProducts(page: _currentPage, limit: _itemsPerPage);
  }
} 