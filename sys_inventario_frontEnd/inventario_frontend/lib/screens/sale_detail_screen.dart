import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sale.dart';
import '../models/product.dart';
import '../providers/sale_provider.dart';
import '../providers/product_provider.dart';
import '../utils/responsive_utils.dart';

class SaleDetailScreen extends StatefulWidget {
  final int saleId;

  const SaleDetailScreen({
    Key? key,
    required this.saleId,
  }) : super(key: key);

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  Sale? _sale;
  List<SaleItem> _items = [];
  bool _isLoading = true;
  String? _error;
  List<Product> _products = [];

  @override
  void initState() {
    super.initState();
    _loadSaleDetails();
    _loadProducts();
  }

  Future<void> _loadSaleDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final saleProvider = Provider.of<SaleProvider>(context, listen: false);
      final sale = await saleProvider.getSaleById(widget.saleId);
      
      if (sale != null) {
        final items = await saleProvider.getSaleItems(widget.saleId);
        setState(() {
          _sale = sale;
          _items = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'No se pudo cargar la venta';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar la venta: $e';
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
        builder: (context) => SaleItemFormScreen(
          saleId: widget.saleId,
        ),
      ),
    );

    if (result == true) {
      _loadSaleDetails();
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
        final saleProvider = Provider.of<SaleProvider>(context, listen: false);
        await saleProvider.deleteSaleItem(widget.saleId, itemId);
        _loadSaleDetails();
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
        title: Text('Venta #${widget.saleId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSaleDetails,
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
                        onPressed: _loadSaleDetails,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _sale == null
                  ? const Center(child: Text('Venta no encontrada'))
                  : Column(
                      children: [
                        _buildSaleInfo(),
                        const Divider(),
                        _buildItemsHeader(),
                        Expanded(child: _buildItemsList()),
                      ],
                    ),
      floatingActionButton: _sale != null
          ? FloatingActionButton(
              onPressed: _addItem,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildSaleInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información de la Venta',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
                     _buildInfoRow('Cliente:', _sale!.customerName ?? 'Sin cliente'),
           _buildInfoRow('Fecha:', _sale!.saleDate),
           _buildInfoRow('Total:', '\$${_sale!.totalAmount?.toStringAsFixed(2) ?? '0.00'}'),
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
            'Items de la Venta',
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
            Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay items en esta venta',
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
                Text('Precio unitario: \$${item.unitPrice.toStringAsFixed(2)}'),
                Text(
                  'Subtotal: \$${(item.quantity * item.unitPrice).toStringAsFixed(2)}',
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

class SaleItemFormScreen extends StatefulWidget {
  final int saleId;

  const SaleItemFormScreen({
    Key? key,
    required this.saleId,
  }) : super(key: key);

  @override
  State<SaleItemFormScreen> createState() => _SaleItemFormScreenState();
}

class _SaleItemFormScreenState extends State<SaleItemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  int? _selectedProductId;
  int _quantity = 1;
  double _unitPrice = 0.0;
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
                          _unitPrice = product.price;
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
              initialValue: _unitPrice.toString(),
              decoration: const InputDecoration(
                labelText: 'Precio Unitario *',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el precio unitario';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'El precio debe ser un número válido';
                }
                return null;
              },
              onChanged: (value) {
                _unitPrice = double.tryParse(value) ?? 0.0;
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
      final saleProvider = Provider.of<SaleProvider>(context, listen: false);
      await saleProvider.addSaleItem(
        widget.saleId,
        _selectedProductId!,
        _quantity,
        _unitPrice,
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