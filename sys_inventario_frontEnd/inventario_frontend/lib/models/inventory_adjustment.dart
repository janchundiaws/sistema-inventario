class InventoryAdjustment {
  final int id;
  final int productId;
  final String adjustmentType; // 'ADD' o 'REMOVE'
  final int quantity;
  final String? reason;
  final int createdBy;
  final String createdAt;
  final String? productName;
  final String? productSku;
  final String? createdByName;

  InventoryAdjustment({
    required this.id,
    required this.productId,
    required this.adjustmentType,
    required this.quantity,
    this.reason,
    required this.createdBy,
    required this.createdAt,
    this.productName,
    this.productSku,
    this.createdByName,
  });

  factory InventoryAdjustment.fromJson(Map<String, dynamic> json) {
    return InventoryAdjustment(
      id: json['id'],
      productId: json['product_id'],
      adjustmentType: json['adjustment_type'],
      quantity: json['quantity'],
      reason: json['reason'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      productName: json['product_name'],
      productSku: json['product_sku'],
      createdByName: json['created_by_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'adjustment_type': adjustmentType,
      'quantity': quantity,
      'reason': reason,
      'created_by': createdBy,
      'created_at': createdAt,
      'product_name': productName,
      'product_sku': productSku,
      'created_by_name': createdByName,
    };
  }

  // Método para crear un ajuste nuevo (sin ID)
  Map<String, dynamic> toJsonForCreate() {
    return {
      'product_id': productId,
      'adjustment_type': adjustmentType,
      'quantity': quantity,
      'reason': reason,
    };
  }

  // Método para obtener el tipo de ajuste en español
  String get adjustmentTypeText {
    switch (adjustmentType) {
      case 'ADD':
        return 'Agregar';
      case 'REMOVE':
        return 'Remover';
      default:
        return adjustmentType;
    }
  }

  // Método para obtener el signo del ajuste
  String get adjustmentSign {
    switch (adjustmentType) {
      case 'ADD':
        return '+';
      case 'REMOVE':
        return '-';
      default:
        return '';
    }
  }

  // Método para obtener el color del ajuste
  String get adjustmentColor {
    switch (adjustmentType) {
      case 'ADD':
        return '#4CAF50'; // Verde
      case 'REMOVE':
        return '#F44336'; // Rojo
      default:
        return '#757575'; // Gris
    }
  }
} 