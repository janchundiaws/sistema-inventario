import 'package:flutter/foundation.dart';
import '../models/inventory_adjustment.dart';
import '../services/api_service.dart';

class InventoryAdjustmentProvider with ChangeNotifier {
  List<InventoryAdjustment> _adjustments = [];
  bool _isLoading = false;
  String? _error;
  int _totalPages = 0;
  int _currentPage = 1;

  // Getters
  List<InventoryAdjustment> get adjustments => _adjustments;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get totalPages => _totalPages;
  int get currentPage => _currentPage;

  // Cargar ajustes de inventario
  Future<bool> loadAdjustments({
    int page = 1,
    int limit = 10,
    int? productId,
    String? adjustmentType,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getInventoryAdjustments(
        page: page,
        limit: limit,
        productId: productId,
        adjustmentType: adjustmentType,
      );

      if (response['success']) {
        final List<dynamic> data = response['data'];
        final List<InventoryAdjustment> adjustments = data
            .map((json) => InventoryAdjustment.fromJson(json))
            .toList();

        if (page == 1) {
          _adjustments = adjustments;
        } else {
          _adjustments.addAll(adjustments);
        }

        _currentPage = page;
        _totalPages = response['pagination']['pages'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Error al cargar ajustes';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Cargar más ajustes (paginación)
  Future<bool> loadMoreAdjustments({
    int? productId,
    String? adjustmentType,
  }) async {
    if (_currentPage < _totalPages && !_isLoading) {
      return await loadAdjustments(
        page: _currentPage + 1,
        productId: productId,
        adjustmentType: adjustmentType,
      );
    }
    return false;
  }

  // Crear nuevo ajuste de inventario
  Future<bool> createAdjustment({
    required int productId,
    required String adjustmentType,
    required int quantity,
    String? reason,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.createInventoryAdjustment(
        productId: productId,
        adjustmentType: adjustmentType,
        quantity: quantity,
        reason: reason,
      );

      if (response['success']) {
        final newAdjustment = InventoryAdjustment.fromJson(response['data']);
        _adjustments.insert(0, newAdjustment);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Error al crear ajuste';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtener ajuste por ID
  Future<InventoryAdjustment?> getAdjustmentById(int id) async {
    try {
      final response = await ApiService.getInventoryAdjustmentById(id);
      
      if (response['success']) {
        return InventoryAdjustment.fromJson(response['data']);
      } else {
        _error = response['message'] ?? 'Error al obtener ajuste';
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      notifyListeners();
      return null;
    }
  }

  // Obtener ajustes de un producto específico
  Future<bool> loadAdjustmentsByProduct(int productId, {int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getInventoryAdjustmentsByProduct(
        productId,
        page: page,
      );

      if (response['success']) {
        final List<dynamic> data = response['data'];
        final List<InventoryAdjustment> adjustments = data
            .map((json) => InventoryAdjustment.fromJson(json))
            .toList();

        if (page == 1) {
          _adjustments = adjustments;
        } else {
          _adjustments.addAll(adjustments);
        }

        _currentPage = page;
        _totalPages = response['pagination']['pages'];
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Error al cargar ajustes del producto';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error de conexión: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Limpiar estado
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _adjustments = [];
    _isLoading = false;
    _error = null;
    _totalPages = 0;
    _currentPage = 1;
    notifyListeners();
  }
} 