class Product {
  final int id;
  final String name;
  final String? description;
  final String? sku;
  final int? categoryId;
  final String? categoryName;
  final int stockQuantity;
  final double price;
  final double cost;
  final bool status;
  final int? createdBy;
  final int? updatedBy;
  final String? createdAt;
  final String? updatedAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    this.categoryId,
    this.categoryName,
    required this.stockQuantity,
    required this.price,
    required this.cost,
    required this.status,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      sku: json['sku'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      stockQuantity: json['stock_quantity'] ?? 0,
      price: double.parse(json['price'].toString()),
      cost: double.parse(json['cost'].toString()),
      status: json['status'] == 1 || json['status'] == true,
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'sku': sku,
      'category_id': categoryId,
      'category_name': categoryName,
      'stock_quantity': stockQuantity,
      'price': price,
      'cost': cost,
      'status': status,
      'created_by': createdBy,
      'updated_by': updatedBy,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, sku: $sku, stock: $stockQuantity, price: $price)';
  }
} 