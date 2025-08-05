import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/purchase_provider.dart';
import '../models/purchase.dart';
import '../utils/responsive_utils.dart';
import 'purchase_form_screen.dart';
import 'purchase_detail_screen.dart';

class PurchasesScreen extends StatefulWidget {
  const PurchasesScreen({super.key});

  @override
  State<PurchasesScreen> createState() => _PurchasesScreenState();
}

class _PurchasesScreenState extends State<PurchasesScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar compras al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PurchaseProvider>(context, listen: false).loadPurchases();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Compras'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<PurchaseProvider>(context, listen: false).refreshPurchases();
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
                
                // Lista de compras
                Expanded(
                  child: _buildPurchasesList(),
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
              builder: (context) => const PurchaseFormScreen(),
            ),
          ).then((_) {
            // Recargar compras al regresar
            Provider.of<PurchaseProvider>(context, listen: false).refreshPurchases();
          });
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<PurchaseProvider>(
      builder: (context, purchaseProvider, child) {
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
                    Icons.shopping_cart,
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
                        'Compras',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 8),
                      Text(
                        '${purchaseProvider.totalItems} compras registradas',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Estado de carga
                if (purchaseProvider.isLoading)
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

  Widget _buildPurchasesList() {
    return Consumer<PurchaseProvider>(
      builder: (context, purchaseProvider, child) {
        if (purchaseProvider.isLoading && purchaseProvider.purchases.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (purchaseProvider.error != null && purchaseProvider.purchases.isEmpty) {
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
                  'Error al cargar compras',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
                Text(
                  purchaseProvider.error!,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                ElevatedButton(
                  onPressed: () {
                    purchaseProvider.refreshPurchases();
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (purchaseProvider.purchases.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: ResponsiveUtils.getResponsiveIconSize(context) * 2,
                  color: Colors.grey[400],
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                Text(
                  'No hay compras registradas',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
                Text(
                  'Agrega tu primera compra usando el botón +',
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
            await purchaseProvider.refreshPurchases();
          },
          child: ListView.builder(
            itemCount: purchaseProvider.purchases.length,
            itemBuilder: (context, index) {
              final purchase = purchaseProvider.purchases[index];
              return _buildPurchaseCard(purchase);
            },
          ),
        );
      },
    );
  }

  Widget _buildPurchaseCard(Purchase purchase) {
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
            Icons.shopping_cart,
            size: ResponsiveUtils.getResponsiveIconSize(context),
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          purchase.supplierName ?? 'Sin proveedor',
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
              'Fecha: ${purchase.purchaseDate}',
              style: TextStyle(
                fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                color: Colors.grey[600],
              ),
            ),
            if (purchase.totalAmount != null) ...[
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 2 : 4),
              Text(
                'Total: \$${purchase.totalAmount!.toStringAsFixed(2)}',
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
            _handlePurchaseAction(value, purchase);
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
              builder: (context) => PurchaseDetailScreen(purchaseId: purchase.id),
            ),
          );
        },
      ),
    );
  }

  void _handlePurchaseAction(String action, Purchase purchase) {
    switch (action) {
      case 'view':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseDetailScreen(purchaseId: purchase.id),
          ),
        );
        break;
      case 'edit':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseFormScreen(purchase: purchase),
          ),
        ).then((_) {
          Provider.of<PurchaseProvider>(context, listen: false).refreshPurchases();
        });
        break;
      case 'delete':
        _showDeleteConfirmation(purchase);
        break;
    }
  }

  void _showDeleteConfirmation(Purchase purchase) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar la compra #${purchase.id}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await Provider.of<PurchaseProvider>(context, listen: false)
                  .deletePurchase(purchase.id);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compra eliminada exitosamente'),
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