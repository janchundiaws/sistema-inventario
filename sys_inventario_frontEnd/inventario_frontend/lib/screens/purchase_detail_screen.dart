import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/purchase.dart';
import '../models/product.dart';
import '../providers/purchase_provider.dart';
import '../providers/product_provider.dart';
import '../utils/responsive_utils.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final int purchaseId;

  const PurchaseDetailScreen({
    Key? key,
    required this.purchaseId,
  }) : super(key: key);

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  Purchase? _purchase;
  List<PurchaseItem> _items = [];
  bool _isLoading = true;
  String? _error;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadPurchaseDetails();
    _loadProducts();
  }

  Future<void> _loadPurchaseDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
      final purchase = await purchaseProvider.getPurchaseById(widget.purchaseId);
      
      if (purchase != null) {
        final items = await purchaseProvider.getPurchaseItems(widget.purchaseId);
        setState(() {
          _purchase = purchase;
          _items = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se pudo cargar la compra';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar la compra: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    try {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      await productProvider.loadProducts();
      setState(() {
        _products = productProvider.products;
      });
    } catch (e) {
      // Silently handle product loading error
    }
  }

  Future<void> _addItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PurchaseItemFormScreen(
          purchaseId: widget.purchaseId,
        ),
      ),
    );

    if (result == true) {
      _loadPurchaseDetails();
    }
  }

  Future<void> _deleteItem(int itemId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que quieres eliminar este item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
        await purchaseProvider.deletePurchaseItem(widget.purchaseId, itemId);
        _loadPurchaseDetails();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Item eliminado correctamente')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar item: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compra #${widget.purchaseId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPurchaseDetails,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPurchaseDetails,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _purchase == null
                  ? const Center(child: Text('Compra no encontrada'))
                  : Column(
                      children: [
                        _buildPurchaseInfo(),
                        const Divider(),
                        _buildItemsHeader(),
                        Expanded(child: _buildItemsList()),
                      ],
                    ),
      floatingActionButton: _purchase != null
          ? FloatingActionButton(
              onPressed: _addItem,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildPurchaseInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de la Compra',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Proveedor:', _purchase!.supplierName ?? 'Sin proveedor'),
          _buildInfoRow('Fecha:', _purchase!.purchaseDate),
          _buildInfoRow('Total:', '\$${_purchase!.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
          _buildInfoRow('Items:', '${_items.length} productos'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildItemsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Items de la Compra',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '${_items.length} items',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (_items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay items en esta compra',
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Toca el botón + para agregar items',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final product = _products.firstWhere(
          (p) => p.id == item.productId,
          orElse: () => Product(
            id: item.productId,
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

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(product.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SKU: ${product.sku}'),
                Text('Cantidad: ${item.quantity}'),
                Text('Costo unitario: \$${item.unitCost.toStringAsFixed(2)}'),
                Text(
                  'Subtotal: \$${(item.quantity * item.unitCost).toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteItem(item.id),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }


}

class PurchaseItemFormScreen extends StatefulWidget {
  final int purchaseId;

  const PurchaseItemFormScreen({
    Key? key,
    required this.purchaseId,
  }) : super(key: key);

  @override
  State<PurchaseItemFormScreen> createState() => _PurchaseItemFormScreenState();
}

class _PurchaseItemFormScreenState extends State<PurchaseItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedProductId;
  int _quantity = 1;
  double _unitCost = 0.0;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Item'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _isLoadingProducts
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : DropdownButtonFormField<int>(
                    value: _selectedProductId,
                    decoration: const InputDecoration(
                      labelText: 'Producto *',
                      border: OutlineInputBorder(),
                    ),
                    items: _products.map((product) {
                      return DropdownMenuItem(
                        value: product.id,
                        child: Text('${product.name} (${product.sku})'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value;
                        if (value != null) {
                          final product = _products.firstWhere((p) => p.id == value);
                          _unitCost = product.cost;
                        }
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
            TextFormField(
              initialValue: _quantity.toString(),
              decoration: const InputDecoration(
                labelText: 'Cantidad *',
                border: OutlineInputBorder(),
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
            TextFormField(
              initialValue: _unitCost.toString(),
              decoration: const InputDecoration(
                labelText: 'Costo Unitario *',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el costo unitario';
                }
                final cost = double.tryParse(value);
                if (cost == null || cost < 0) {
                  return 'El costo debe ser un número válido';
                }
                return null;
              },
              onChanged: (value) {
                _unitCost = double.tryParse(value) ?? 0.0;
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Guardar Item'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final purchaseProvider = Provider.of<PurchaseProvider>(context, listen: false);
      await purchaseProvider.addPurchaseItem(
        widget.purchaseId,
        _selectedProductId!,
        _quantity,
        _unitCost,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item agregado correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar item: $e')),
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
} 