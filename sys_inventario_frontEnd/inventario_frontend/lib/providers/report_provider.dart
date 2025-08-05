import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/product_movement.dart';

class ReportProvider with ChangeNotifier {
  ProductMovementReport? _productMovementReport;
  bool _isLoading = false;
  String? _error;

  // Getters
  ProductMovementReport? get productMovementReport => _productMovementReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Cargar reporte de movimiento de productos
  Future<bool> loadProductMovementReport({
    String? startDate,
    String? endDate,
    int? productId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await ApiService.getProductMovementReport(
        startDate: startDate,
        endDate: endDate,
        productId: productId,
      );

      if (response['success']) {
        _productMovementReport = ProductMovementReport.fromJson(response['data']);
        _error = null;
      } else {
        _error = response['message'] ?? 'Error al cargar el reporte';
        _productMovementReport = null;
      }
    } catch (e) {
      _error = e.toString();
      _productMovementReport = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return _error == null;
  }

  // Obtener movimientos filtrados por tipo
  List<ProductMovement> getMovementsByType(String type) {
    if (_productMovementReport == null) return [];
    return _productMovementReport!.movements
        .where((movement) => movement.movementType == type)
        .toList();
  }

  // Obtener solo compras
  List<ProductMovement> get purchases => getMovementsByType('PURCHASE');

  // Obtener solo ventas
  List<ProductMovement> get sales => getMovementsByType('SALE');

  // Obtener productos con mayor movimiento
  List<ProductSummary> get topProducts {
    if (_productMovementReport == null) return [];
    final products = List<ProductSummary>.from(_productMovementReport!.products);
    products.sort((a, b) => (b.totalSold + b.totalPurchased).compareTo(a.totalSold + a.totalPurchased));
    return products.take(10).toList();
  }

  // Obtener productos con mayor ganancia
  List<ProductSummary> get topProfitProducts {
    if (_productMovementReport == null) return [];
    final products = List<ProductSummary>.from(_productMovementReport!.products);
    products.sort((a, b) => b.netAmount.compareTo(a.netAmount));
    return products.take(10).toList();
  }

  // Obtener productos con mayor pérdida
  List<ProductSummary> get topLossProducts {
    if (_productMovementReport == null) return [];
    final products = List<ProductSummary>.from(_productMovementReport!.products);
    products.sort((a, b) => a.netAmount.compareTo(b.netAmount));
    return products.take(10).toList();
  }

  // Obtener movimientos por fecha
  List<ProductMovement> getMovementsByDate(DateTime date) {
    if (_productMovementReport == null) return [];
    return _productMovementReport!.movements
        .where((movement) => 
          movement.transactionDate.year == date.year &&
          movement.transactionDate.month == date.month &&
          movement.transactionDate.day == date.day)
        .toList();
  }

  // Obtener movimientos por producto
  List<ProductMovement> getMovementsByProduct(int productId) {
    if (_productMovementReport == null) return [];
    return _productMovementReport!.movements
        .where((movement) => movement.productId == productId)
        .toList();
  }

  // Obtener resumen de un producto específico
  ProductSummary? getProductSummary(int productId) {
    if (_productMovementReport == null) return null;
    try {
      return _productMovementReport!.products
          .firstWhere((product) => product.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Obtener estadísticas generales
  Map<String, dynamic> get generalStats {
    if (_productMovementReport == null) {
      return {
        'total_movements': 0,
        'total_purchases': 0.0,
        'total_sales': 0.0,
        'net_amount': 0.0,
        'total_purchase_quantity': 0,
        'total_sale_quantity': 0,
        'net_quantity': 0,
        'average_purchase': 0.0,
        'average_sale': 0.0,
      };
    }

    final totals = _productMovementReport!.totals;

    final averagePurchase = purchases.isNotEmpty 
        ? purchases.map((p) => p.subtotal).reduce((a, b) => a + b) / purchases.length 
        : 0.0;
    
    final averageSale = sales.isNotEmpty 
        ? sales.map((s) => s.subtotal).reduce((a, b) => a + b) / sales.length 
        : 0.0;

    return {
      'total_movements': totals.totalMovements,
      'total_purchases': totals.totalPurchases,
      'total_sales': totals.totalSales,
      'net_amount': totals.netAmount,
      'total_purchase_quantity': totals.totalPurchaseQuantity,
      'total_sale_quantity': totals.totalSaleQuantity,
      'net_quantity': totals.netQuantity,
      'average_purchase': averagePurchase,
      'average_sale': averageSale,
    };
  }

  // Obtener filtros aplicados
  Map<String, dynamic>? get appliedFilters {
    return _productMovementReport?.filters;
  }

  // Verificar si hay datos
  bool get hasData => _productMovementReport != null && _productMovementReport!.movements.isNotEmpty;

  // Verificar si hay productos en el resumen
  bool get hasProductSummary => _productMovementReport != null && _productMovementReport!.products.isNotEmpty;

  // Limpiar reporte
  void clearReport() {
    _productMovementReport = null;
    _error = null;
    notifyListeners();
  }
} 