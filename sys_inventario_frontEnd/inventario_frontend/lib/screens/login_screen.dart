import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/responsive_utils.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: ResponsiveUtils.getResponsivePadding(context),
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
                          // Logo o ícono
                          Container(
                            width: ResponsiveUtils.getResponsiveIconContainerSize(context),
                            height: ResponsiveUtils.getResponsiveIconContainerSize(context),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.getResponsiveIconContainerSize(context) / 2),
                            ),
                            child: Icon(
                              Icons.inventory,
                              size: ResponsiveUtils.getResponsiveIconSize(context),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                          
                          // Título
                          Text(
                            'Sistema de Inventario',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 8),
                          Text(
                            'Inicia sesión para continuar',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                          // Campo de email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: const Icon(Icons.email_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo electrónico';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return 'Por favor ingresa un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de contraseña
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 20),

                          // Opción "Recordar sesión"
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: Theme.of(context).primaryColor,
                              ),
                              Expanded(
                                child: Text(
                                  'Recordar sesión',
                                  style: TextStyle(
                                    fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 20),

                          // Botón de login
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: ResponsiveUtils.isMobile(context) ? 45 : 50,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : _handleLogin,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
                                          'Iniciar Sesión',
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
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              if (authProvider.error != null) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Text(
                                    authProvider.error!,
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
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 24),

                          // Enlace para registro
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿No tienes una cuenta? ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const RegisterScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Regístrate aquí',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                  ),
                                ),
                              ),
                            ],
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

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
        rememberMe: _rememberMe,
      );

      if (success && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      }
    }
  }
} 