import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/role_provider.dart';
import 'providers/category_provider.dart';
import 'providers/product_provider.dart';
import 'providers/purchase_provider.dart';
import 'providers/sale_provider.dart';
import 'providers/inventory_adjustment_provider.dart';
import 'providers/report_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => InventoryAdjustmentProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        title: 'Sistema de Inventario',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF667eea),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF667eea),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF667eea),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.grey[50],
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
