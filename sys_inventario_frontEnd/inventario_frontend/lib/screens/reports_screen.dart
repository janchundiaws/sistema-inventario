import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/report_provider.dart';
import '../utils/responsive_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_widget.dart';
import '../widgets/error_widget.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../services/pdf_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialReport();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialReport() async {
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    await reportProvider.loadProductMovementReport();
  }

  Future<void> _loadReport() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final reportProvider = Provider.of<ReportProvider>(context, listen: false);
    await reportProvider.loadProductMovementReport(
      startDate: _startDate?.toIso8601String().split('T')[0],
      endDate: _endDate?.toIso8601String().split('T')[0],
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF667eea),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      await _loadReport();
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
    _loadReport();
  }

  Future<void> _generatePDF() async {
    try {
      setState(() {
        _isLoading = true;
      });

      await PdfService.generateProductMovementReport(
        startDate: _startDate?.toIso8601String().split('T')[0],
        endDate: _endDate?.toIso8601String().split('T')[0],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
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
      appBar: const CustomAppBar(
        title: 'Reportes de Productos',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildTabBar(),
          Expanded(
            child: _buildTabBarView(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateFilter(),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _selectDateRange,
                icon: const Icon(Icons.date_range),
                label: const Text('Seleccionar Fechas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF667eea),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _generatePDF,
                icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.picture_as_pdf),
                label: Text(_isLoading ? 'Generando...' : 'Generar PDF'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    String dateText = 'Todas las fechas';
    if (_startDate != null && _endDate != null) {
      dateText = '${app_date_utils.DateUtils.formatDate(_startDate!)} - ${app_date_utils.DateUtils.formatDate(_endDate!)}';
    } else if (_startDate != null) {
      dateText = 'Desde ${app_date_utils.DateUtils.formatDate(_startDate!)}';
    } else if (_endDate != null) {
      dateText = 'Hasta ${app_date_utils.DateUtils.formatDate(_endDate!)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade50,
      ),
      child: Row(
        children: [
          Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dateText,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: const Color(0xFF667eea),
        unselectedLabelColor: Colors.grey,
        indicatorColor: const Color(0xFF667eea),
        tabs: const [
          Tab(text: 'Resumen', icon: Icon(Icons.analytics)),
          Tab(text: 'Movimientos', icon: Icon(Icons.list)),
          Tab(text: 'Productos', icon: Icon(Icons.inventory)),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildSummaryTab(),
        _buildMovementsTab(),
        _buildProductsTab(),
      ],
    );
  }

  Widget _buildSummaryTab() {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        if (reportProvider.isLoading) {
          return const LoadingWidget();
        }

        if (reportProvider.error != null) {
          return CustomErrorWidget(
            message: reportProvider.error!,
            onRetry: _loadReport,
          );
        }

        if (!reportProvider.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay datos para mostrar',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Selecciona un rango de fechas para ver el reporte',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final stats = reportProvider.generalStats;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(stats),
              const SizedBox(height: 24),
              _buildTopProductsSection(reportProvider),
              const SizedBox(height: 24),
              _buildProfitLossSection(reportProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: ResponsiveUtils.isMobile(context) ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Movimientos',
          stats['total_movements'].toString(),
          Icons.swap_horiz,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Compras',
          '\$${stats['total_purchases'].toStringAsFixed(2)}',
          Icons.shopping_cart,
          Colors.orange,
        ),
        _buildStatCard(
          'Total Ventas',
          '\$${stats['total_sales'].toStringAsFixed(2)}',
          Icons.point_of_sale,
          Colors.green,
        ),
        _buildStatCard(
          'Ganancia Neta',
          '\$${stats['net_amount'].toStringAsFixed(2)}',
          Icons.trending_up,
          stats['net_amount'] >= 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProductsSection(ReportProvider reportProvider) {
    final topProducts = reportProvider.topProducts;
    
    if (topProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Productos con Mayor Movimiento',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topProducts.length,
            itemBuilder: (context, index) {
              final product = topProducts[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF667eea),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(product.productName),
                subtitle: Text(product.productSku ?? 'Sin SKU'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product.totalSold + product.totalPurchased}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'movimientos',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProfitLossSection(ReportProvider reportProvider) {
    final topProfit = reportProvider.topProfitProducts;
    final topLoss = reportProvider.topLossProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis de Rentabilidad',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildProfitLossCard(
                'Mayor Ganancia',
                topProfit,
                Colors.green,
                true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildProfitLossCard(
                'Mayor Pérdida',
                topLoss,
                Colors.red,
                false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfitLossCard(String title, List<dynamic> products, Color color, bool isProfit) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            if (products.isEmpty)
              Text(
                'No hay datos',
                style: TextStyle(color: Colors.grey.shade600),
              )
            else
              ...products.take(5).map((product) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                                         Expanded(
                       child: Text(
                         product?.productName ?? 'N/A',
                         style: const TextStyle(fontSize: 14),
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     Text(
                       '\$${(product?.netAmount ?? 0.0).toStringAsFixed(2)}',
                       style: TextStyle(
                         fontWeight: FontWeight.bold,
                         color: color,
                       ),
                     ),
                  ],
                ),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildMovementsTab() {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        if (reportProvider.isLoading) {
          return const LoadingWidget();
        }

        if (reportProvider.error != null) {
          return CustomErrorWidget(
            message: reportProvider.error!,
            onRetry: _loadReport,
          );
        }

        if (!reportProvider.hasData) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay movimientos para mostrar',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final movements = reportProvider.productMovementReport!.movements;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: movements.length,
          itemBuilder: (context, index) {
            final movement = movements[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: movement.movementType == 'PURCHASE' 
                      ? Colors.orange 
                      : Colors.green,
                  child: Icon(
                    movement.movementType == 'PURCHASE' 
                        ? Icons.shopping_cart 
                        : Icons.point_of_sale,
                    color: Colors.white,
                  ),
                ),
                title: Text(movement.productName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${movement.movementTypeDisplay} - ${movement.transactionDateFormatted}'),
                    Text('${movement.customerSupplierLabel}: ${movement.customerSupplierName}'),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${movement.quantity}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '\$${movement.subtotal.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: movement.movementType == 'PURCHASE' 
                            ? Colors.orange 
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsTab() {
    return Consumer<ReportProvider>(
      builder: (context, reportProvider, child) {
        if (reportProvider.isLoading) {
          return const LoadingWidget();
        }

        if (reportProvider.error != null) {
          return CustomErrorWidget(
            message: reportProvider.error!,
            onRetry: _loadReport,
          );
        }

        if (!reportProvider.hasProductSummary) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No hay productos para mostrar',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final products = reportProvider.productMovementReport!.products;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ExpansionTile(
                title: Text(product.productName),
                subtitle: Text(product.productSku ?? 'Sin SKU'),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildProductStatRow('Comprado', '${product.totalPurchased} unidades', '\$${product.totalPurchaseAmount.toStringAsFixed(2)}'),
                        _buildProductStatRow('Vendido', '${product.totalSold} unidades', '\$${product.totalSaleAmount.toStringAsFixed(2)}'),
                        _buildProductStatRow('Stock Neto', '${product.netQuantity} unidades', '\$${product.netAmount.toStringAsFixed(2)}'),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductStatRow(String label, String quantity, String amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 2,
            child: Text(quantity, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 2,
            child: Text(amount, textAlign: TextAlign.end, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
} 