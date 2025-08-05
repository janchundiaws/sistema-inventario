import 'package:flutter/material.dart';

class AlertUtils {
  // Mostrar alerta de stock insuficiente
  static void showInsufficientStockAlert(
    BuildContext context, {
    required String productName,
    required int availableStock,
    required int requestedQuantity,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Stock Insuficiente'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No hay suficiente stock disponible para el producto:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock disponible: $availableStock unidades',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cantidad solicitada: $requestedQuantity unidades',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Por favor, ajuste la cantidad o contacte al administrador para realizar un ajuste de inventario.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // Mostrar alerta de éxito con información de stock actualizado
  static void showStockUpdatedAlert(
    BuildContext context, {
    required String productName,
    required int previousStock,
    required int newStock,
    required String operation, // 'compra' o 'venta'
  }) {
    final isPurchase = operation.toLowerCase() == 'compra';
    final stockChange = newStock - previousStock;
    final changeText = stockChange > 0 ? '+$stockChange' : '$stockChange';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              isPurchase ? Icons.add_circle : Icons.remove_circle,
              color: isPurchase ? Colors.green : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            Text('Stock Actualizado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'El stock del producto se ha actualizado correctamente:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isPurchase ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isPurchase ? Colors.green[200]! : Colors.red[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        size: 16,
                        color: isPurchase ? Colors.green[700] : Colors.red[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cambio: $changeText unidades',
                        style: TextStyle(
                          color: isPurchase ? Colors.green[700] : Colors.red[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock anterior: $previousStock',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock nuevo: $newStock',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  // Mostrar alerta de confirmación para eliminar item
  static Future<bool> showDeleteItemConfirmation(
    BuildContext context, {
    required String itemName,
    String? stockWarning,
  }) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.delete_forever,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 8),
            const Text('Confirmar Eliminación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Está seguro de que desea eliminar este item?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              itemName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (stockWarning != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        stockWarning,
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    ) ?? false;
  }
} 