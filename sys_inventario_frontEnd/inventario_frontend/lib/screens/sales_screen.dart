import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sale_provider.dart';
import '../models/sale.dart';
import '../utils/responsive_utils.dart';
import 'sale_form_screen.dart';
import 'sale_detail_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar ventas al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SaleProvider>(context, listen: false).loadSales();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Ventas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<SaleProvider>(context, listen: false).refreshSales();
            },
          ),
        ],
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
          child: Padding(
            padding: ResponsiveUtils.getResponsivePadding(context),
            child: Column(
              children: [
                // Header con estadísticas
                _buildHeader(),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                
                // Lista de ventas
                Expanded(
                  child: _buildSalesList(),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SaleFormScreen(),
            ),
          ).then((_) {
            // Recargar ventas al regresar
            Provider.of<SaleProvider>(context, listen: false).refreshSales();
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<SaleProvider>(
      builder: (context, saleProvider, child) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: ResponsiveUtils.getResponsiveCardPadding(context),
            child: Row(
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
                    Icons.point_of_sale,
                    size: ResponsiveUtils.getResponsiveIconSize(context),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(width: ResponsiveUtils.isMobile(context) ? 16 : 24),
                
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ventas',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 8),
                      Text(
                        '${saleProvider.totalItems} ventas registradas',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Estado de carga
                if (saleProvider.isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSalesList() {
    return Consumer<SaleProvider>(
      builder: (context, saleProvider, child) {
        if (saleProvider.isLoading && saleProvider.sales.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (saleProvider.error != null && saleProvider.sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 2,
                  color: Colors.red,
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                Text(
                  'Error al cargar ventas',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
                Text(
                  saleProvider.error!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                ElevatedButton(
                  onPressed: () {
                    saleProvider.refreshSales();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (saleProvider.sales.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.point_of_sale_outlined,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 2,
                  color: Colors.grey[400],
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                Text(
                  'No hay ventas registradas',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
                Text(
                  'Agrega tu primera venta usando el botón +',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await saleProvider.refreshSales();
          },
          child: ListView.builder(
            itemCount: saleProvider.sales.length,
            itemBuilder: (context, index) {
              final sale = saleProvider.sales[index];
              return _buildSaleCard(sale);
            },
          ),
        );
      },
    );
  }

  Widget _buildSaleCard(Sale sale) {
    return Card(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.isMobile(context) ? 8 : 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: ResponsiveUtils.getResponsiveCardPadding(context),
        leading: Container(
          width: ResponsiveUtils.getResponsiveIconContainerSize(context),
          height: ResponsiveUtils.getResponsiveIconContainerSize(context),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveIconContainerSize(context) / 2),
          ),
          child: Icon(
            Icons.point_of_sale,
            size: ResponsiveUtils.getResponsiveIconSize(context),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          sale.customerName ?? 'Cliente sin nombre',
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 8),
            Text(
              'Fecha: ${sale.saleDate}',
              style: TextStyle(
                fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
            if (sale.totalAmount != null) ...[
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 2 : 4),
              Text(
                'Total: \$${sale.totalAmount!.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            _handleSaleAction(value, sale);
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Ver detalles'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
        onTap: () {
          // Navegar a la pantalla de detalles
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SaleDetailScreen(saleId: sale.id),
            ),
          );
        },
      ),
    );
  }

  void _handleSaleAction(String action, Sale sale) {
    switch (action) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaleDetailScreen(saleId: sale.id),
          ),
        );
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaleFormScreen(sale: sale),
          ),
        ).then((_) {
          Provider.of<SaleProvider>(context, listen: false).refreshSales();
        });
        break;
      case 'delete':
        _showDeleteConfirmation(sale);
        break;
    }
  }

  void _showDeleteConfirmation(Sale sale) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la venta #${sale.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<SaleProvider>(context, listen: false)
                  .deleteSale(sale.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Venta eliminada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
} 