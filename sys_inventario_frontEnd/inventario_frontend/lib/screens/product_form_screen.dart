import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/category_provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../utils/responsive_utils.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product; // Si es null, es crear. Si tiene valor, es editar

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skuController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  final _costController = TextEditingController();
  
  Category? _selectedCategory;
  bool _status = true;

  @override
  void initState() {
    super.initState();
    // Cargar categorías al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
    });

    // Si estamos editando, llenar los campos con los datos existentes
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description ?? '';
      _skuController.text = widget.product!.sku ?? '';
      _stockController.text = widget.product!.stockQuantity.toString();
      _priceController.text = widget.product!.price.toString();
      _costController.text = widget.product!.cost.toString();
      _status = widget.product!.status == true || widget.product!.status == 1;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _skuController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;
    final title = isEditing ? 'Editar Producto' : 'Nuevo Producto';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.getMaxContentWidth(context),
                ),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: ResponsiveUtils.getResponsiveCardPadding(context),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icono
                          Container(
                            width: ResponsiveUtils.getResponsiveIconContainerSize(context),
                            height: ResponsiveUtils.getResponsiveIconContainerSize(context),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveIconContainerSize(context) / 2),
                            ),
                            child: Icon(
                              isEditing ? Icons.edit : Icons.inventory,
                              size: ResponsiveUtils.getResponsiveIconSize(context),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

                          // Título
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 8),
                          Text(
                            isEditing 
                              ? 'Modifica los datos del producto'
                              : 'Completa los datos para crear un nuevo producto',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                          // Campo de nombre
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Nombre del producto',
                              prefixIcon: const Icon(Icons.inventory_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el nombre del producto';
                              }
                              if (value.length < 2) {
                                return 'El nombre debe tener al menos 2 caracteres';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de descripción
                          TextFormField(
                            controller: _descriptionController,
                            keyboardType: TextInputType.multiline,
                            maxLines: ResponsiveUtils.isMobile(context) ? 2 : 3,
                            decoration: InputDecoration(
                              labelText: 'Descripción (opcional)',
                              prefixIcon: const Icon(Icons.description_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de SKU
                          TextFormField(
                            controller: _skuController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'SKU (opcional)',
                              prefixIcon: const Icon(Icons.qr_code_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de categoría
                          Consumer<CategoryProvider>(
                            builder: (context, categoryProvider, child) {
                              if (categoryProvider.isLoading) {
                                return const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (categoryProvider.error != null) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Text(
                                    'Error al cargar categorías: ${categoryProvider.error}',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              return DropdownButtonFormField<Category>(
                                value: _selectedCategory,
                                decoration: InputDecoration(
                                  labelText: 'Categoría (opcional)',
                                  prefixIcon: const Icon(Icons.category_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                items: [
                                  const DropdownMenuItem<Category>(
                                    value: null,
                                    child: Text('Sin categoría'),
                                  ),
                                  ...categoryProvider.categories.map((Category category) {
                                    return DropdownMenuItem<Category>(
                                      value: category,
                                      child: Text(category.name),
                                    );
                                  }).toList(),
                                ],
                                onChanged: (Category? newValue) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                },
                              );
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de stock
                          TextFormField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Cantidad en stock',
                              prefixIcon: const Icon(Icons.inventory_2_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa la cantidad en stock';
                              }
                              final stock = int.tryParse(value);
                              if (stock == null || stock < 0) {
                                return 'La cantidad debe ser un número entero positivo';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de precio
                          TextFormField(
                            controller: _priceController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Precio de venta',
                              prefixIcon: const Icon(Icons.attach_money_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el precio de venta';
                              }
                              final price = double.tryParse(value);
                              if (price == null || price <= 0) {
                                return 'El precio debe ser un número positivo';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de costo
                          TextFormField(
                            controller: _costController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Costo del producto',
                              prefixIcon: const Icon(Icons.paid_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el costo del producto';
                              }
                              final cost = double.tryParse(value);
                              if (cost == null || cost < 0) {
                                return 'El costo debe ser un número positivo';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de estado
                          SwitchListTile(
                            title: Text(
                              'Producto activo',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                              ),
                            ),
                            subtitle: Text(
                              'El producto estará disponible para ventas',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                              ),
                            ),
                            value: _status,
                            onChanged: (bool value) {
                              print('value: $value');
                              setState(() {
                                _status = value;
                              });
                            },
                            secondary: Icon(
                              _status ? Icons.check_circle : Icons.cancel,
                              color: _status ? Colors.green : Colors.red,
                              size: ResponsiveUtils.getResponsiveIconSize(context),
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                          // Botón de guardar
                          Consumer<ProductProvider>(
                            builder: (context, productProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: ResponsiveUtils.isMobile(context) ? 45 : 50,
                                child: ElevatedButton(
                                  onPressed: productProvider.isLoading ? null : _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: productProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          isEditing ? 'Actualizar' : 'Crear',
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Mensaje de error
                          Consumer<ProductProvider>(
                            builder: (context, productProvider, child) {
                              if (productProvider.error != null) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Text(
                                    productProvider.error!,
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSave() async {


    if (_formKey.currentState!.validate()) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      
      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim();
      final sku = _skuController.text.trim().isEmpty 
          ? null 
          : _skuController.text.trim();
      final stockQuantity = int.parse(_stockController.text);
      final price = double.parse(_priceController.text);
      final cost = double.parse(_costController.text);
      final categoryId = _selectedCategory?.id;

      bool success;
      
      if (widget.product != null) {
        // Actualizar producto existente
        success = await productProvider.updateProduct(
          id: widget.product!.id,
          name: name,
          description: description,
          sku: sku,
          categoryId: categoryId,
          stockQuantity: stockQuantity,
          price: price,
          cost: cost,
          status: _status,
        );
      } else {
        // Crear nuevo producto
        success = await productProvider.createProduct(
          name: name,
          description: description,
          sku: sku,
          categoryId: categoryId,
          stockQuantity: stockQuantity,
          price: price,
          cost: cost,
          status: _status,
        );
      }

      if (success && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product != null 
                ? 'Producto actualizado exitosamente'
                : 'Producto creado exitosamente',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Regresar a la pantalla anterior
        Navigator.pop(context);
      }
    }
  }
} 