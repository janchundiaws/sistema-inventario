class Sale {
  final int id;
  final String? customerName;
  final String saleDate;
  final double? totalAmount;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  Sale({
    required this.id,
    this.customerName,
    required this.saleDate,
    this.totalAmount,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      customerName: json['customer_name'],
      saleDate: json['sale_date'],
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
      'customer_name': customerName,
      'sale_date': saleDate,
      'total_amount': totalAmount,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Sale(id: $id, customer: $customerName, date: $saleDate, total: $totalAmount)';
  }
}

class SaleItem {
  final int id;
  final int saleId;
  final int productId;
  final String? productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory SaleItem.fromJson(Map<String, dynamic> json) {
    return SaleItem(
      id: json['id'],
      saleId: json['sale_id'],
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_id': saleId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  @override
  String toString() {
    return 'SaleItem(id: $id, product: $productName, quantity: $quantity, price: $unitPrice)';
  }
} 