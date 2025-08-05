class ProductMovement {
  final String movementType;
  final int transactionId;
  final DateTime transactionDate;
  final String? supplierName;
  final String? customerName;
  final int productId;
  final String productName;
  final String? productSku;
  final String? categoryName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? createdByName;
  final DateTime createdAt;

  ProductMovement({
    required this.movementType,
    required this.transactionId,
    required this.transactionDate,
    this.supplierName,
    this.customerName,
    required this.productId,
    required this.productName,
    this.productSku,
    this.categoryName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.createdByName,
    required this.createdAt,
  });

  factory ProductMovement.fromJson(Map<String, dynamic> json) {
    return ProductMovement(
      movementType: json['movement_type'] ?? '',
      transactionId: json['transaction_id'] ?? 0,
      transactionDate: DateTime.parse(json['transaction_date'] ?? DateTime.now().toIso8601String()),
      supplierName: json['supplier_name'],
      customerName: json['customer_name'],
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'],
      categoryName: json['category_name'],
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unit_cost'] ?? json['unit_price'] ?? 0).toDouble(),
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      createdByName: json['created_by_name'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movement_type': movementType,
      'transaction_id': transactionId,
      'transaction_date': transactionDate.toIso8601String(),
      'supplier_name': supplierName,
      'customer_name': customerName,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'category_name': categoryName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
      'created_by_name': createdByName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get movementTypeDisplay {
    return movementType == 'PURCHASE' ? 'Compra' : 'Venta';
  }

  String get transactionDateFormatted {
    return '${transactionDate.day.toString().padLeft(2, '0')}/${transactionDate.month.toString().padLeft(2, '0')}/${transactionDate.year}';
  }

  String get customerSupplierName {
    return movementType == 'PURCHASE' ? (supplierName ?? 'N/A') : (customerName ?? 'N/A');
  }

  String get customerSupplierLabel {
    return movementType == 'PURCHASE' ? 'Proveedor' : 'Cliente';
  }
}

class ProductSummary {
  final int productId;
  final String productName;
  final String? productSku;
  final String? categoryName;
  final int totalPurchased;
  final int totalSold;
  final double totalPurchaseAmount;
  final double totalSaleAmount;

  ProductSummary({
    required this.productId,
    required this.productName,
    this.productSku,
    this.categoryName,
    required this.totalPurchased,
    required this.totalSold,
    required this.totalPurchaseAmount,
    required this.totalSaleAmount,
  });

  factory ProductSummary.fromJson(Map<String, dynamic> json) {
    return ProductSummary(
      productId: json['product_id'] ?? 0,
      productName: json['product_name'] ?? '',
      productSku: json['product_sku'],
      categoryName: json['category_name'],
      totalPurchased: json['total_purchased'] ?? 0,
      totalSold: json['total_sold'] ?? 0,
      totalPurchaseAmount: (json['total_purchase_amount'] ?? 0).toDouble(),
      totalSaleAmount: (json['total_sale_amount'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'category_name': categoryName,
      'total_purchased': totalPurchased,
      'total_sold': totalSold,
      'total_purchase_amount': totalPurchaseAmount,
      'total_sale_amount': totalSaleAmount,
    };
  }

  int get netQuantity => totalPurchased - totalSold;
  double get netAmount => totalSaleAmount - totalPurchaseAmount;
}

class ReportTotals {
  final double totalPurchases;
  final double totalSales;
  final int totalPurchaseQuantity;
  final int totalSaleQuantity;
  final int totalMovements;

  ReportTotals({
    required this.totalPurchases,
    required this.totalSales,
    required this.totalPurchaseQuantity,
    required this.totalSaleQuantity,
    required this.totalMovements,
  });

  factory ReportTotals.fromJson(Map<String, dynamic> json) {
    return ReportTotals(
      totalPurchases: (json['total_purchases'] ?? 0).toDouble(),
      totalSales: (json['total_sales'] ?? 0).toDouble(),
      totalPurchaseQuantity: json['total_purchase_quantity'] ?? 0,
      totalSaleQuantity: json['total_sale_quantity'] ?? 0,
      totalMovements: json['total_movements'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_purchases': totalPurchases,
      'total_sales': totalSales,
      'total_purchase_quantity': totalPurchaseQuantity,
      'total_sale_quantity': totalSaleQuantity,
      'total_movements': totalMovements,
    };
  }

  double get netAmount => totalSales - totalPurchases;
  int get netQuantity => totalPurchaseQuantity - totalSaleQuantity;
}

class ProductMovementReport {
  final List<ProductMovement> movements;
  final ReportTotals totals;
  final List<ProductSummary> products;
  final Map<String, dynamic> filters;

  ProductMovementReport({
    required this.movements,
    required this.totals,
    required this.products,
    required this.filters,
  });

  factory ProductMovementReport.fromJson(Map<String, dynamic> json) {
    return ProductMovementReport(
      movements: (json['movements'] as List?)
          ?.map((item) => ProductMovement.fromJson(item))
          .toList() ?? [],
      totals: ReportTotals.fromJson(json['summary']['totals'] ?? {}),
      products: (json['summary']['products'] as List?)
          ?.map((item) => ProductSummary.fromJson(item))
          .toList() ?? [],
      filters: json['filters'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'movements': movements.map((item) => item.toJson()).toList(),
      'summary': {
        'totals': totals.toJson(),
        'products': products.map((item) => item.toJson()).toList(),
      },
      'filters': filters,
    };
  }
} 