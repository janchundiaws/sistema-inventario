import 'package:flutter/material.dart';
import '../models/purchase.dart';
import '../services/api_service.dart';

class PurchaseProvider extends ChangeNotifier {
  List<Purchase> _purchases = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;
  int _itemsPerPage = 10;

  List<Purchase> get purchases => _purchases;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get itemsPerPage => _itemsPerPage;

  // Cargar compras desde la API
  Future<void> loadPurchases({
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getPurchases(
        page: page,
        limit: limit,
      );
      
      if (response['success']) {
        final List<dynamic> purchasesData = response['data'];
        _purchases = purchasesData.map((json) => Purchase.fromJson(json)).toList();
        
        // Actualizar información de paginación
        if (response['pagination'] != null) {
          _currentPage = response['pagination']['page'] ?? 1;
          _totalPages = response['pagination']['pages'] ?? 1;
          _totalItems = response['pagination']['total'] ?? 0;
          _itemsPerPage = response['pagination']['limit'] ?? 10;
        }
        
        _error = null;
      } else {
        _error = response['message'] ?? 'Error al cargar compras';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear nueva compra
  Future<bool> createPurchase({
    required String supplierName,
    required String purchaseDate,
    double? totalAmount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createPurchase(
        supplierName: supplierName,
        purchaseDate: purchaseDate,
        totalAmount: totalAmount,
      );
      
      if (response['success']) {
        final newPurchase = Purchase.fromJson(response['data']);
        _purchases.insert(0, newPurchase); // Agregar al inicio
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al crear compra';
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

  // Actualizar compra
  Future<bool> updatePurchase({
    required int id,
    required String supplierName,
    required String purchaseDate,
    double? totalAmount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.updatePurchase(
        id: id,
        supplierName: supplierName,
        purchaseDate: purchaseDate,
        totalAmount: totalAmount,
      );
      
      if (response['success']) {
        final updatedPurchase = Purchase.fromJson(response['data']);
        final index = _purchases.indexWhere((purchase) => purchase.id == id);
        if (index != -1) {
          _purchases[index] = updatedPurchase;
        }
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al actualizar compra';
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

  // Eliminar compra
  Future<bool> deletePurchase(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.deletePurchase(id);
      
      if (response['success']) {
        _purchases.removeWhere((purchase) => purchase.id == id);
        _error = null;
        return true;
      } else {
        _error = response['message'] ?? 'Error al eliminar compra';
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

  // Verificar si las compras están cargadas
  bool get hasPurchases => _purchases.isNotEmpty;

  // Refrescar compras (recargar la página actual)
  Future<void> refreshPurchases() async {
    await loadPurchases(page: _currentPage, limit: _itemsPerPage);
  }

  // Obtener compra por ID desde la API
  Future<Purchase?> getPurchaseById(int id) async {
    try {
      final response = await ApiService.getPurchaseById(id);
      
      if (response['success']) {
        return Purchase.fromJson(response['data']);
      } else {
        _error = response['message'] ?? 'Error al obtener compra';
        return null;
      }
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  // Agregar item a una compra
  Future<Map<String, dynamic>> addPurchaseItem(
    int purchaseId,
    int productId,
    int quantity,
    double unitCost,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.addPurchaseItem(
        purchaseId: purchaseId,
        productId: productId,
        quantity: quantity,
        unitCost: unitCost,
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
          'data': response['data']
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

  // Eliminar item de una compra
  Future<bool> deletePurchaseItem(int purchaseId, int itemId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.deletePurchaseItem(purchaseId, itemId);
      
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

  // Obtener items de una compra
  Future<List<PurchaseItem>> getPurchaseItems(int purchaseId) async {
    try {
      final response = await ApiService.getPurchaseItems(purchaseId);
      
      if (response['success']) {
        final List<dynamic> itemsData = response['data'];
        return itemsData.map((json) => PurchaseItem.fromJson(json)).toList();
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