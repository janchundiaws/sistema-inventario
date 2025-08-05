import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'storage_service.dart';

class ApiService {
  static String get baseUrl => AppConfig.getApiUrl();
  
  // Headers comunes
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Headers con token de autenticación
  static Future<Map<String, String>> get _authHeaders async {
    final token = await StorageService.getToken();
    
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Método genérico para hacer requests
  static Future<Map<String, dynamic>> _makeRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      final headers = requiresAuth ? await _authHeaders : _headers;
      
      print('🌐 API Request: $method $url');
      if (body != null) {
        print('📦 Request Body: ${json.encode(body)}');
      }
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(
            url, 
            headers: headers,
          ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
          break;
        case 'DELETE':
          response = await http.delete(
            url, 
            headers: headers,
          ).timeout(Duration(milliseconds: AppConfig.connectionTimeout));
          break;
        default:
          throw Exception('Método HTTP no soportado');
      }

      print('📡 Response Status: ${response.statusCode}');
      print('📄 Response Body: ${response.body}');

      final responseData = json.decode(response.body);
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Error en la solicitud (${response.statusCode})');
      }
    } catch (e) {
      if (e is FormatException) {
        print('❌ Error de formato en la respuesta: $e');
        throw Exception('Error al procesar la respuesta del servidor');
      } else if (e.toString().contains('SocketException')) {
        print('❌ Error de conexión: $e');
        throw Exception('No se pudo conectar con el servidor. Verifica que el backend esté ejecutándose en ${AppConfig.backendUrl}');
      } else if (e.toString().contains('TimeoutException')) {
        print('❌ Error de timeout: $e');
        throw Exception('La solicitud tardó demasiado en completarse');
      } else {
        print('❌ Error en API: $e');
        rethrow;
      }
    }
  }

  // Autenticación
  static Future<Map<String, dynamic>> login(String email, String password) async {
    return await _makeRequest('/auth/login', 'POST', body: {
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    int? roleId,
  ) async {
    return await _makeRequest('/auth/register', 'POST', body: {
      'name': name,
      'email': email,
      'password': password,
      if (roleId != null) 'role_id': roleId,
    });
  }

  static Future<Map<String, dynamic>> getProfile() async {
    return await _makeRequest('/auth/profile', 'GET', requiresAuth: true);
  }

  // Roles
  static Future<Map<String, dynamic>> getRoles() async {
    return await _makeRequest('/roles', 'GET');
  }

  // Categorías
  static Future<Map<String, dynamic>> getCategories() async {
    return await _makeRequest('/categories', 'GET');
  }

  static Future<Map<String, dynamic>> createCategory(String name, String? description) async {
    return await _makeRequest('/categories', 'POST', body: {
      'name': name,
      if (description != null) 'description': description,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> updateCategory(int id, String name, String? description) async {
    return await _makeRequest('/categories/$id', 'PUT', body: {
      'name': name,
      if (description != null) 'description': description,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> deleteCategory(int id) async {
    return await _makeRequest('/categories/$id', 'DELETE', requiresAuth: true);
  }

  // Productos
  static Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String? search,
    int? categoryId,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    
    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return await _makeRequest('/products?$queryString', 'GET');
  }

  static Future<Map<String, dynamic>> getProductById(int id) async {
    return await _makeRequest('/products/$id', 'GET');
  }

  static Future<Map<String, dynamic>> createProduct({
    required String name,
    String? description,
    String? sku,
    int? categoryId,
    required int stockQuantity,
    required double price,
    required double cost,
    bool? status,
  }) async {
    return await _makeRequest('/products', 'POST', body: {
      'name': name,
      if (description != null) 'description': description,
      if (sku != null) 'sku': sku,
      if (categoryId != null) 'category_id': categoryId,
      'stock_quantity': stockQuantity,
      'price': price,
      'cost': cost,
      if (status != null) 'status': status,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> updateProduct({
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
    return await _makeRequest('/products/$id', 'PUT', body: {
      'name': name,
      if (description != null) 'description': description,
      if (sku != null) 'sku': sku,
      if (categoryId != null) 'category_id': categoryId,
      'stock_quantity': stockQuantity,
      'price': price,
      'cost': cost,
      if (status != null) 'status': status,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    return await _makeRequest('/products/$id', 'DELETE', requiresAuth: true);
  }

  // Guardar token usando StorageService
  static Future<void> saveToken(String token) async {
    await StorageService.saveToken(token);
  }

  // Obtener token usando StorageService
  static Future<String?> getToken() async {
    return await StorageService.getToken();
  }

  // Eliminar token (logout) usando StorageService
  static Future<void> removeToken() async {
    await StorageService.removeToken();
  }

  // Verificar si el usuario está autenticado usando StorageService
  static Future<bool> isAuthenticated() async {
    return await StorageService.isAuthenticated();
  }

  // =====================
  // COMPRAS
  // =====================
  static Future<Map<String, dynamic>> getPurchases({
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return await _makeRequest('/purchases?$queryString', 'GET');
  }

  static Future<Map<String, dynamic>> getPurchaseById(int id) async {
    return await _makeRequest('/purchases/$id', 'GET');
  }

  static Future<Map<String, dynamic>> createPurchase({
    required String supplierName,
    required String purchaseDate,
    double? totalAmount,
  }) async {
    return await _makeRequest('/purchases', 'POST', body: {
      'supplier_name': supplierName,
      'purchase_date': purchaseDate,
      if (totalAmount != null) 'total_amount': totalAmount,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> updatePurchase({
    required int id,
    required String supplierName,
    required String purchaseDate,
    double? totalAmount,
  }) async {
    return await _makeRequest('/purchases/$id', 'PUT', body: {
      'supplier_name': supplierName,
      'purchase_date': purchaseDate,
      if (totalAmount != null) 'total_amount': totalAmount,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> deletePurchase(int id) async {
    return await _makeRequest('/purchases/$id', 'DELETE', requiresAuth: true);
  }

  // Items de compra
  static Future<Map<String, dynamic>> getPurchaseItems(int purchaseId) async {
    return await _makeRequest('/purchases/$purchaseId/items', 'GET');
  }

  static Future<Map<String, dynamic>> addPurchaseItem({
    required int purchaseId,
    required int productId,
    required int quantity,
    required double unitCost,
  }) async {
    return await _makeRequest('/purchases/$purchaseId/items', 'POST', body: {
      'product_id': productId,
      'quantity': quantity,
      'unit_cost': unitCost,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> deletePurchaseItem(int purchaseId, int itemId) async {
    return await _makeRequest('/purchases/$purchaseId/items/$itemId', 'DELETE', requiresAuth: true);
  }

  // =====================
  // VENTAS
  // =====================
  static Future<Map<String, dynamic>> getSales({
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return await _makeRequest('/sales?$queryString', 'GET');
  }

  static Future<Map<String, dynamic>> getSaleById(int id) async {
    return await _makeRequest('/sales/$id', 'GET');
  }

  static Future<Map<String, dynamic>> createSale({
    required String customerName,
    required String saleDate,
    double? totalAmount,
  }) async {
    return await _makeRequest('/sales', 'POST', body: {
      'customer_name': customerName,
      'sale_date': saleDate,
      if (totalAmount != null) 'total_amount': totalAmount,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> updateSale({
    required int id,
    required String customerName,
    required String saleDate,
    double? totalAmount,
  }) async {
    return await _makeRequest('/sales/$id', 'PUT', body: {
      'customer_name': customerName,
      'sale_date': saleDate,
      if (totalAmount != null) 'total_amount': totalAmount,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> deleteSale(int id) async {
    return await _makeRequest('/sales/$id', 'DELETE', requiresAuth: true);
  }

  // Items de venta
  static Future<Map<String, dynamic>> getSaleItems(int saleId) async {
    return await _makeRequest('/sales/$saleId/items', 'GET');
  }

  static Future<Map<String, dynamic>> addSaleItem({
    required int saleId,
    required int productId,
    required int quantity,
    required double unitPrice,
  }) async {
    return await _makeRequest('/sales/$saleId/items', 'POST', body: {
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> deleteSaleItem(int saleId, int itemId) async {
    return await _makeRequest('/sales/$saleId/items/$itemId', 'DELETE', requiresAuth: true);
  }

  // =====================
  // AJUSTES DE INVENTARIO
  // =====================
  static Future<Map<String, dynamic>> getInventoryAdjustments({
    int page = 1,
    int limit = 10,
    int? productId,
    String? adjustmentType,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (productId != null) {
      queryParams['product_id'] = productId.toString();
    }

    if (adjustmentType != null) {
      queryParams['adjustment_type'] = adjustmentType;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return await _makeRequest('/inventory-adjustments?$queryString', 'GET', requiresAuth: true);
  }

  static Future<Map<String, dynamic>> getInventoryAdjustmentById(int id) async {
    return await _makeRequest('/inventory-adjustments/$id', 'GET', requiresAuth: true);
  }

  static Future<Map<String, dynamic>> createInventoryAdjustment({
    required int productId,
    required String adjustmentType,
    required int quantity,
    String? reason,
  }) async {
    return await _makeRequest('/inventory-adjustments', 'POST', body: {
      'product_id': productId,
      'adjustment_type': adjustmentType,
      'quantity': quantity,
      if (reason != null) 'reason': reason,
    }, requiresAuth: true);
  }

  static Future<Map<String, dynamic>> getInventoryAdjustmentsByProduct(
    int productId, {
    int page = 1,
    int limit = 10,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return await _makeRequest('/inventory-adjustments/product/$productId?$queryString', 'GET', requiresAuth: true);
  }

  // =====================
  // REPORTES
  // =====================
  static Future<Map<String, dynamic>> getProductMovementReport({
    String? startDate,
    String? endDate,
    int? productId,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['start_date'] = startDate;
    }

    if (endDate != null) {
      queryParams['end_date'] = endDate;
    }

    if (productId != null) {
      queryParams['product_id'] = productId.toString();
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return await _makeRequest('/reports/product-movement?$queryString', 'GET', requiresAuth: true);
  }

  static Future<Map<String, dynamic>> getCategorySummaryReport({
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{};

    if (startDate != null) {
      queryParams['start_date'] = startDate;
    }

    if (endDate != null) {
      queryParams['end_date'] = endDate;
    }

    final queryString = queryParams.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return await _makeRequest('/reports/category-summary?$queryString', 'GET', requiresAuth: true);
  }
} 