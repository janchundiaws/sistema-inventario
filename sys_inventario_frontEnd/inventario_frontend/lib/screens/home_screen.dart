import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_utils.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'product_form_screen.dart';
import 'category_form_screen.dart';
import 'purchases_screen.dart';
import 'sales_screen.dart';
import 'configuration_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sistema de Inventario'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.account_circle),
                onSelected: (value) {
                  if (value == 'profile') {
                    _showProfileDialog(context, authProvider.user);
                  } else if (value == 'session') {
                    _showSessionInfoDialog(context);
                  } else if (value == 'logout') {
                    _showLogoutDialog(context, authProvider);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 8),
                        Text('Perfil'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'session',
                    child: Row(
                      children: [
                        Icon(Icons.info),
                        SizedBox(width: 8),
                        Text('Información de Sesión'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout),
                        SizedBox(width: 8),
                        Text('Cerrar Sesión'),
                      ],
                    ),
                  ),
                ],
              );
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
                  // Mensaje de bienvenida
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: ResponsiveUtils.getResponsiveCardPadding(context),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: ResponsiveUtils.getResponsiveIconSize(context) / 2,
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Icon(
                                  Icons.person,
                                  size: ResponsiveUtils.getResponsiveIconSize(context) / 2,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                              SizedBox(width: ResponsiveUtils.isMobile(context) ? 12 : 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '¡Bienvenido!',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      authProvider.user?.name ?? 'Usuario',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      authProvider.user?.email ?? '',
                                      style: TextStyle(
                                        fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),

                  // Título de sección
                  Text(
                    'Funciones Principales',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                  // Grid de funciones
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: ResponsiveUtils.getGridCrossAxisCount(context),
                      crossAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
                      mainAxisSpacing: ResponsiveUtils.isMobile(context) ? 12 : 16,
                      childAspectRatio: ResponsiveUtils.isMobile(context) ? 1.1 : 1.2,
                      children: [
                        _buildFunctionCard(
                          context,
                          'Productos',
                          Icons.inventory,
                          Colors.blue,
                          () => _navigateToProducts(context),
                        ),
                        _buildFunctionCard(
                          context,
                          'Categorías',
                          Icons.category,
                          Colors.green,
                          () => _navigateToCategories(context),
                        ),
                        _buildFunctionCard(
                          context,
                          'Compras',
                          Icons.shopping_cart,
                          Colors.orange,
                          () => _navigateToPurchases(context),
                        ),
                        _buildFunctionCard(
                          context,
                          'Ventas',
                          Icons.point_of_sale,
                          Colors.purple,
                          () => _navigateToSales(context),
                        ),
                        _buildFunctionCard(
                          context,
                          'Reportes',
                          Icons.analytics,
                          Colors.red,
                          () => _showComingSoon(context, 'Reportes y Estadísticas'),
                        ),
                        _buildFunctionCard(
                          context,
                          'Configuración',
                          Icons.settings,
                          Colors.grey,
                          () => _navigateToConfiguration(context),
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

  Widget _buildFunctionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
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
            ],
          ),
        ),
      ),
    );
  }

  void _showProfileDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perfil de Usuario'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nombre: ${user?.name ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Email: ${user?.email ?? 'N/A'}'),
            const SizedBox(height: 8),
            Text('Rol: ${user?.roleName ?? 'Usuario'}'),
            const SizedBox(height: 8),
            Text('Estado: ${user?.status == true ? 'Activo' : 'Inactivo'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showSessionInfoDialog(BuildContext context) async {
    final sessionInfo = await StorageService.getSessionInfo();
    final lastLogin = await StorageService.getLastLogin();
    final rememberMe = await StorageService.isRememberMeEnabled();
    final platformInfo = StorageService.getPlatformInfo();
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Información de Sesión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Plataforma: $platformInfo'),
              const SizedBox(height: 8),
              if (lastLogin != null) ...[
                Text('Último login: ${lastLogin.toString().substring(0, 19)}'),
                const SizedBox(height: 8),
              ],
              Text('Recordar sesión: ${rememberMe ? 'Sí' : 'No'}'),
              if (sessionInfo != null) ...[
                const SizedBox(height: 8),
                Text('User Agent: ${sessionInfo['user_agent'] ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Login Time: ${sessionInfo['login_time'] != null ? DateTime.parse(sessionInfo['login_time']).toString().substring(0, 19) : 'N/A'}'),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              }
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _navigateToProducts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductFormScreen(),
      ),
    );
  }

  void _navigateToCategories(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CategoryFormScreen(),
      ),
    );
  }

  void _navigateToPurchases(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PurchasesScreen(),
      ),
    );
  }

  void _navigateToSales(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SalesScreen(),
      ),
    );
  }

  void _navigateToConfiguration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ConfigurationScreen(),
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