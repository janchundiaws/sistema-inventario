import 'package:flutter/material.dart';
import '../models/sale.dart';
import '../services/api_service.dart';

class SaleProvider extends ChangeNotifier {
  List<Sale> _sales = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _itemsPerPage = 10;

  List<Sale> get sales => _sales;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get itemsPerPage => _itemsPerPage;

  // Cargar ventas desde la API
  Future<void> loadSales({
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getSales(
        page: page,
        limit: limit,
      );
      
      if (response['success']) {
        final List<dynamic> salesData = response['data'];
        _sales = salesData.map((json) => Sale.fromJson(json)).toList();
        
        // Actualizar información de paginación
        if (response['pagination'] != null) {
          _currentPage = response['pagination']['page'] ?? 1;
          _totalPages = response['pagination']['pages'] ?? 1;
          _totalItems = response['pagination']['total'] ?? 0;
          _itemsPerPage = response['pagination']['limit'] ?? 10;
        }
        
        _error = null;
      } else {
        _error = response['message'] ?? 'Error al cargar ventas';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear nueva venta
  Future<bool> createSale({
    required String customerName,
    required String saleDate,
    double? totalAmount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createSale(
        customerName: customerName,
        saleDate: saleDate,
        totalAmount: totalAmount,
      );
      
      if (response['success']) {
        final newSale = Sale.fromJson(response['data']);
        _sales.insert(0, newSale); // Agregar al inicio
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al crear venta';
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

  // Actualizar venta
  Future<bool> updateSale({
    required int id,
    required String customerName,
    required String saleDate,
    double? totalAmount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updateSale(
        id: id,
        customerName: customerName,
        saleDate: saleDate,
        totalAmount: totalAmount,
      );
      
      if (response['success']) {
        final updatedSale = Sale.fromJson(response['data']);
        final index = _sales.indexWhere((sale) => sale.id == id);
        if (index != -1) {
          _sales[index] = updatedSale;
        }
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al actualizar venta';
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

  // Eliminar venta
  Future<bool> deleteSale(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.deleteSale(id);
      
      if (response['success']) {
        _sales.removeWhere((sale) => sale.id == id);
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al eliminar venta';
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



  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Verificar si las ventas están cargadas
  bool get hasSales => _sales.isNotEmpty;

  // Refrescar ventas (recargar la página actual)
  Future<void> refreshSales() async {
    await loadSales(page: _currentPage, limit: _itemsPerPage);
  }

  // Obtener venta por ID desde la API
  Future<Sale?> getSaleById(int id) async {
    try {
      final response = await ApiService.getSaleById(id);
      
      if (response['success']) {
        return Sale.fromJson(response['data']);
      } else {
        _error = response['message'] ?? 'Error al obtener venta';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Agregar item a una venta
  Future<Map<String, dynamic>> addSaleItem(
    int saleId,
    int productId,
    int quantity,
    double unitPrice,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.addSaleItem(
        saleId: saleId,
        productId: productId,
        quantity: quantity,
        unitPrice: unitPrice,
      );
      
      if (response['success']) {
        _error = null;
        return {
          'success': true,
          'data': response['data'],
          'message': 'Item agregado exitosamente'
        };
      } else {
        _error = response['message'] ?? 'Error al agregar item';
        return {
          'success': false,
          'message': response['message'] ?? 'Error al agregar item',
          'data': response['data'] // Para errores de stock insuficiente
        };
      }
    } catch (e) {
      _error = e.toString();
      return {
        'success': false,
        'message': e.toString()
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar item de una venta
  Future<bool> deleteSaleItem(int saleId, int itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.deleteSaleItem(saleId, itemId);
      
      if (response['success']) {
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al eliminar item';
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

  // Obtener items de una venta
  Future<List<SaleItem>> getSaleItems(int saleId) async {
    try {
      final response = await ApiService.getSaleItems(saleId);
      
      if (response['success']) {
        final List<dynamic> itemsData = response['data'];
        return itemsData.map((json) => SaleItem.fromJson(json)).toList();
      } else {
        _error = response['message'] ?? 'Error al obtener items';
        return [];
      }
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }
} 