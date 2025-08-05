import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_adjustment_provider.dart';
import '../models/inventory_adjustment.dart';
import '../utils/responsive_utils.dart';
import 'inventory_adjustment_form_screen.dart';

class InventoryAdjustmentsScreen extends StatefulWidget {
  const InventoryAdjustmentsScreen({Key? key}) : super(key: key);

  @override
  State<InventoryAdjustmentsScreen> createState() => _InventoryAdjustmentsScreenState();
}

class _InventoryAdjustmentsScreenState extends State<InventoryAdjustmentsScreen> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedAdjustmentType;
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadAdjustments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreAdjustments();
    }
  }

  Future<void> _loadAdjustments() async {
    final provider = Provider.of<InventoryAdjustmentProvider>(context, listen: false);
    await provider.loadAdjustments(
      productId: _selectedProductId,
      adjustmentType: _selectedAdjustmentType,
    );
  }

  Future<void> _loadMoreAdjustments() async {
    final provider = Provider.of<InventoryAdjustmentProvider>(context, listen: false);
    await provider.loadMoreAdjustments(
      productId: _selectedProductId,
      adjustmentType: _selectedAdjustmentType,
    );
  }

  void _showFilters() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtros'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedAdjustmentType,
              decoration: const InputDecoration(
                labelText: 'Tipo de Ajuste',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos')),
                DropdownMenuItem(value: 'ADD', child: Text('Agregar')),
                DropdownMenuItem(value: 'REMOVE', child: Text('Remover')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedAdjustmentType = value;
                });
              },
            ),
            const SizedBox(height: 16),
            // Aquí podrías agregar un selector de productos si es necesario
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _loadAdjustments();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes de Inventario'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
            tooltip: 'Filtros',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const InventoryAdjustmentFormScreen(),
            ),
          );
          if (result == true) {
            _loadAdjustments();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Nuevo Ajuste',
      ),
      body: Consumer<InventoryAdjustmentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.adjustments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null && provider.adjustments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar ajustes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    provider.error!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadAdjustments,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.adjustments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay ajustes de inventario',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los ajustes de inventario aparecerán aquí',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadAdjustments,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: provider.adjustments.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.adjustments.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final adjustment = provider.adjustments[index];
                return _buildAdjustmentCard(adjustment);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdjustmentCard(InventoryAdjustment adjustment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: adjustment.adjustmentType == 'ADD' 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: adjustment.adjustmentType == 'ADD' 
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        adjustment.adjustmentType == 'ADD' 
                            ? Icons.add_circle
                            : Icons.remove_circle,
                        size: 16,
                        color: adjustment.adjustmentType == 'ADD' 
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        adjustment.adjustmentTypeText,
                        style: TextStyle(
                          color: adjustment.adjustmentType == 'ADD' 
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${adjustment.adjustmentSign}${adjustment.quantity}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: adjustment.adjustmentType == 'ADD' 
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (adjustment.productName != null) ...[
              Text(
                adjustment.productName!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (adjustment.productSku != null) ...[
                const SizedBox(height: 4),
                Text(
                  'SKU: ${adjustment.productSku}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
            if (adjustment.reason != null && adjustment.reason!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        adjustment.reason!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.person,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  adjustment.createdByName ?? 'Usuario',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(adjustment.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
} 