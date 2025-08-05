import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_adjustment_provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

class InventoryAdjustmentFormScreen extends StatefulWidget {
  const InventoryAdjustmentFormScreen({Key? key}) : super(key: key);

  @override
  State<InventoryAdjustmentFormScreen> createState() => _InventoryAdjustmentFormScreenState();
}

class _InventoryAdjustmentFormScreenState extends State<InventoryAdjustmentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedProductId;
  String _adjustmentType = 'ADD';
  int _quantity = 1;
  String _reason = '';
  bool _isLoading = false;
  List<Product> _products = [];
  bool _isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.loadProducts();
      setState(() {
        _products = productProvider.products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar productos: $e')),
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedProductId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona un producto')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<InventoryAdjustmentProvider>(context, listen: false);
      final success = await provider.createAdjustment(
        productId: _selectedProductId!,
        adjustmentType: _adjustmentType,
        quantity: _quantity,
        reason: _reason.isNotEmpty ? _reason : null,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ajuste de inventario creado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Error al crear el ajuste'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Ajuste de Inventario'),
      ),
      body: _isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selector de producto
                    DropdownButtonFormField<int>(
                      value: _selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'Producto *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      items: _products.map((product) {
                        return DropdownMenuItem(
                          value: product.id,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              if (product.sku != null && product.sku!.isNotEmpty)
                                Text(
                                  'SKU: ${product.sku} - Stock: ${product.stockQuantity}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedProductId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Por favor selecciona un producto';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo de ajuste
                    DropdownButtonFormField<String>(
                      value: _adjustmentType,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Ajuste *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.trending_up),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ADD',
                          child: Row(
                            children: [
                              Icon(Icons.add_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Agregar Stock'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'REMOVE',
                          child: Row(
                            children: [
                              Icon(Icons.remove_circle, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Remover Stock'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _adjustmentType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Cantidad
                    TextFormField(
                      initialValue: _quantity.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa la cantidad';
                        }
                        final quantity = int.tryParse(value);
                        if (quantity == null || quantity <= 0) {
                          return 'La cantidad debe ser un número positivo';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _quantity = int.tryParse(value) ?? 1;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Razón del ajuste
                    TextFormField(
                      initialValue: _reason,
                      decoration: const InputDecoration(
                        labelText: 'Razón del Ajuste',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note),
                        hintText: 'Ej: Pérdida por daño, Ajuste de inventario, etc.',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _reason = value;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Información del producto seleccionado
                    if (_selectedProductId != null) ...[
                      _buildProductInfo(),
                      const SizedBox(height: 24),
                    ],

                    // Botón de envío
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                SizedBox(width: 12),
                                Text('Creando ajuste...'),
                              ],
                            )
                          : const Text(
                              'Crear Ajuste',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProductInfo() {
    final product = _products.firstWhere(
      (p) => p.id == _selectedProductId,
      orElse: () => Product(
        id: 0,
        name: 'Producto no encontrado',
        description: '',
        sku: '',
        categoryId: 0,
        stockQuantity: 0,
        price: 0,
        cost: 0,
        status: false,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    );

    final newStock = _adjustmentType == 'ADD'
        ? product.stockQuantity + _quantity
        : product.stockQuantity - _quantity;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resumen del Ajuste',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Stock Actual',
                  '${product.stockQuantity}',
                  Icons.inventory,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Ajuste',
                  '${_adjustmentType == 'ADD' ? '+' : '-'}$_quantity',
                  _adjustmentType == 'ADD' ? Icons.add_circle : Icons.remove_circle,
                  color: _adjustmentType == 'ADD' ? Colors.green : Colors.red,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Stock Final',
                  '$newStock',
                  Icons.inventory_2,
                  color: newStock < 0 ? Colors.red : Colors.green,
                ),
              ),
            ],
          ),
          if (newStock < 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El stock final será negativo',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Colors.grey[600], size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
} 