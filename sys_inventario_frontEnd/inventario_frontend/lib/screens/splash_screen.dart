import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_utils.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Esperar un poco para mostrar la animación
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.initialize();
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => authProvider.isAuthenticated 
                ? const HomeScreen() 
                : const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo
                      Container(
                        width: ResponsiveUtils.getResponsiveIconContainerSize(context) * 2,
                        height: ResponsiveUtils.getResponsiveIconContainerSize(context) * 2,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveIconContainerSize(context)),
                        ),
                        child: Icon(
                          Icons.inventory,
                          size: ResponsiveUtils.getResponsiveIconSize(context) * 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),
                      
                      // Título
                      Text(
                        'Sistema de Inventario',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context) * 1.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 6 : 8),
                      
                      // Subtítulo
                      Text(
                        'Gestión inteligente de inventarios',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.isMobile(context) ? 36 : 48),
                      
                      // Indicador de carga
                      SizedBox(
                        width: ResponsiveUtils.isMobile(context) ? 32 : 40,
                        height: ResponsiveUtils.isMobile(context) ? 32 : 40,
                        child: const CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 