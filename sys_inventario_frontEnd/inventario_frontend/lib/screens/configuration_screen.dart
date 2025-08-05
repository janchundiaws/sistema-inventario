import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';
import 'inventory_adjustments_screen.dart';
import 'reports_screen.dart';

class ConfigurationScreen extends StatelessWidget {
  const ConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf5f7fa),
              Color(0xFFc3cfe2),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: ResponsiveUtils.getMaxContentWidth(context),
            ),
            child: Padding(
              padding: ResponsiveUtils.getResponsivePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título de sección
                  Text(
                    'Opciones de Configuración',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                  // Grid de opciones de configuración
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
                      crossAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
                      mainAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
                      childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.1 : 1.2,
                      children: [
                        _buildConfigurationCard(
                          context,
                          'Ajustes de Inventario',
                          Icons.inventory_2,
                          Colors.teal,
                          'Gestionar ajustes de stock de productos',
                          () => _navigateToInventoryAdjustments(context),
                        ),
                        _buildConfigurationCard(
                          context,
                          'Reportes de Productos',
                          Icons.analytics,
                          Colors.indigo,
                          'Ver reportes de ventas y compras',
                          () => _navigateToReports(context),
                        ),
                        _buildConfigurationCard(
                          context,
                          'Usuarios y Roles',
                          Icons.people,
                          Colors.blue,
                          'Administrar usuarios y permisos',
                          () => _showComingSoon(context, 'Gestión de Usuarios y Roles'),
                        ),
                        _buildConfigurationCard(
                          context,
                          'Configuración del Sistema',
                          Icons.settings,
                          Colors.grey,
                          'Configuraciones generales del sistema',
                          () => _showComingSoon(context, 'Configuración del Sistema'),
                        ),
                        _buildConfigurationCard(
                          context,
                          'Respaldo y Restauración',
                          Icons.backup,
                          Colors.orange,
                          'Gestionar respaldos de datos',
                          () => _showComingSoon(context, 'Respaldo y Restauración'),
                        ),
                        _buildConfigurationCard(
                          context,
                          'Logs del Sistema',
                          Icons.article,
                          Colors.purple,
                          'Ver registros de actividad',
                          () => _showComingSoon(context, 'Logs del Sistema'),
                        ),
                        _buildConfigurationCard(
                          context,
                          'Notificaciones',
                          Icons.notifications,
                          Colors.red,
                          'Configurar notificaciones',
                          () => _showComingSoon(context, 'Configuración de Notificaciones'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigurationCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String description,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: ResponsiveUtils.getResponsiveCardPadding(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: ResponsiveUtils.getResponsiveIconContainerSize(context),
                height: ResponsiveUtils.getResponsiveIconContainerSize(context),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveIconContainerSize(context) / 2),
                ),
                child: Icon(
                  icon,
                  size: ResponsiveUtils.getResponsiveIconSize(context),
                  color: color,
                ),
              ),
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 8 : 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 6),
              Text(
                description,
                style: TextStyle(
                  fontSize: ResponsiveUtils.isMobile(context) ? 10 : 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToInventoryAdjustments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InventoryAdjustmentsScreen(),
      ),
    );
  }

  void _navigateToReports(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ReportsScreen(),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Próximamente'),
        content: Text('La función "$feature" estará disponible en una próxima actualización.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
} 