import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sale_provider.dart';
import '../models/sale.dart';
import '../utils/responsive_utils.dart';

class SaleFormScreen extends StatefulWidget {
  final Sale? sale; // Si es null, es crear. Si tiene valor, es editar

  const SaleFormScreen({super.key, this.sale});

  @override
  State<SaleFormScreen> createState() => _SaleFormScreenState();
}

class _SaleFormScreenState extends State<SaleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _saleDateController = TextEditingController();
  final _totalAmountController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    
    // Si estamos editando, llenar los campos con los datos existentes
    if (widget.sale != null) {
      _customerNameController.text = widget.sale!.customerName ?? '';
      _saleDateController.text = widget.sale!.saleDate;
      _totalAmountController.text = widget.sale!.totalAmount?.toString() ?? '';
      _selectedDate = DateTime.parse(widget.sale!.saleDate);
    } else {
      // Si es nueva venta, establecer la fecha actual
      _saleDateController.text = _formatDate(_selectedDate);
    }
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _saleDateController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _saleDateController.text = _formatDate(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.sale != null;
    final title = isEditing ? 'Editar Venta' : 'Nueva Venta';

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
                              isEditing ? Icons.edit : Icons.point_of_sale,
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
                              ? 'Modifica los datos de la venta'
                              : 'Completa los datos para registrar una nueva venta',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                          // Campo de cliente
                          TextFormField(
                            controller: _customerNameController,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              labelText: 'Nombre del cliente',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa el nombre del cliente';
                              }
                              if (value.length < 2) {
                                return 'El nombre debe tener al menos 2 caracteres';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de fecha
                          TextFormField(
                            controller: _saleDateController,
                            readOnly: true,
                            decoration: InputDecoration(
                              labelText: 'Fecha de venta',
                              prefixIcon: const Icon(Icons.calendar_today_outlined),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.calendar_month),
                                onPressed: () => _selectDate(context),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor selecciona la fecha de venta';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de monto total
                          TextFormField(
                            controller: _totalAmountController,
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: 'Monto total (opcional)',
                              prefixIcon: const Icon(Icons.attach_money_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                final amount = double.tryParse(value);
                                if (amount == null || amount < 0) {
                                  return 'El monto debe ser un número positivo';
                                }
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                          // Botón de guardar
                          Consumer<SaleProvider>(
                            builder: (context, saleProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: ResponsiveUtils.isMobile(context) ? 45 : 50,
                                child: ElevatedButton(
                                  onPressed: saleProvider.isLoading ? null : _handleSave,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: saleProvider.isLoading
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
                          Consumer<SaleProvider>(
                            builder: (context, saleProvider, child) {
                              if (saleProvider.error != null) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Text(
                                    saleProvider.error!,
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
      final saleProvider = Provider.of<SaleProvider>(context, listen: false);
      
      final customerName = _customerNameController.text.trim();
      final saleDate = _saleDateController.text;
      final totalAmount = _totalAmountController.text.trim().isEmpty 
          ? null 
          : double.parse(_totalAmountController.text);

      bool success;
      
      if (widget.sale != null) {
        // Actualizar venta existente
        success = await saleProvider.updateSale(
          id: widget.sale!.id,
          customerName: customerName,
          saleDate: saleDate,
          totalAmount: totalAmount,
        );
      } else {
        // Crear nueva venta
        success = await saleProvider.createSale(
          customerName: customerName,
          saleDate: saleDate,
          totalAmount: totalAmount,
        );
      }

      if (success && mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.sale != null 
                ? 'Venta actualizada exitosamente'
                : 'Venta creada exitosamente',
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