class Purchase {
  final int id;
  final String? supplierName;
  final String purchaseDate;
  final double? totalAmount;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  Purchase({
    required this.id,
    this.supplierName,
    required this.purchaseDate,
    this.totalAmount,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      supplierName: json['supplier_name'],
      purchaseDate: json['purchase_date'],
      totalAmount: json['total_amount'] != null 
          ? double.parse(json['total_amount'].toString()) 
          : null,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_name': supplierName,
      'purchase_date': purchaseDate,
      'total_amount': totalAmount,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Purchase(id: $id, supplier: $supplierName, date: $purchaseDate, total: $totalAmount)';
  }
}

class PurchaseItem {
  final int id;
  final int purchaseId;
  final int productId;
  final String? productName;
  final int quantity;
  final double unitCost;
  final double subtotal;

  PurchaseItem({
    required this.id,
    required this.purchaseId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitCost,
    required this.subtotal,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      id: json['id'],
      purchaseId: json['purchase_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      unitCost: double.parse(json['unit_cost'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_cost': unitCost,
      'subtotal': subtotal,
    };
  }

  @override
  String toString() {
    return 'PurchaseItem(id: $id, product: $productName, quantity: $quantity, cost: $unitCost)';
  }
} 