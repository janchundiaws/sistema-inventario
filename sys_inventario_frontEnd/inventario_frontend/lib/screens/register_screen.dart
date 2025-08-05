import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';
import '../models/role.dart';
import '../utils/responsive_utils.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Role? _selectedRole;

  @override
  void initState() {
    super.initState();
    // Cargar roles al inicializar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<RoleProvider>(context, listen: false).loadRoles();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro'),
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
                              Icons.person_add,
                              size: ResponsiveUtils.getResponsiveIconSize(context),
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 16 : 24),
                          
                          // Título
                          Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveTitleFontSize(context),
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 4 : 8),
                          Text(
                            'Completa los datos para registrarte',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveSubtitleFontSize(context),
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 24 : 32),

                          // Campo de nombre
                          TextFormField(
                            controller: _nameController,
                            keyboardType: TextInputType.name,
                            decoration: InputDecoration(
                              labelText: 'Nombre completo',
                              prefixIcon: const Icon(Icons.person_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu nombre completo';
                              }
                              if (value.length < 2) {
                                return 'El nombre debe tener al menos 2 caracteres';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

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
                                return 'Por favor ingresa una contraseña';
                              }
                              if (value.length < 6) {
                                return 'La contraseña debe tener al menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de selección de rol
                          Consumer<RoleProvider>(
                            builder: (context, roleProvider, child) {
                              if (roleProvider.isLoading) {
                                return const SizedBox(
                                  height: 60,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (roleProvider.error != null) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red[200]!),
                                  ),
                                  child: Text(
                                    'Error al cargar roles: ${roleProvider.error}',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              return DropdownButtonFormField<Role>(
                                value: _selectedRole,
                                decoration: InputDecoration(
                                  labelText: 'Rol de usuario',
                                  prefixIcon: const Icon(Icons.work_outline),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                ),
                                items: roleProvider.roles.map((Role role) {
                                  return DropdownMenuItem<Role>(
                                    value: role,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          role.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                          ),
                                        ),
                                        if (role.description != null)
                                          Text(
                                            role.description!,
                                            style: TextStyle(
                                              fontSize: ResponsiveUtils.isMobile(context) ? 10 : 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (Role? newValue) {
                                  setState(() {
                                    _selectedRole = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Por favor selecciona un rol';
                                  }
                                  return null;
                                },
                              );
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 12 : 16),

                          // Campo de confirmar contraseña
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirmar contraseña',
                              prefixIcon: const Icon(Icons.lock_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
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
                                return 'Por favor confirma tu contraseña';
                              }
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: ResponsiveUtils.isMobile(context) ? 20 : 24),

                          // Botón de registro
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return SizedBox(
                                width: double.infinity,
                                height: ResponsiveUtils.isMobile(context) ? 45 : 50,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading ? null : _handleRegister,
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
                                          'Registrarse',
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

                          // Enlace para login
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '¿Ya tienes una cuenta? ',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: ResponsiveUtils.isMobile(context) ? 12 : 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Inicia sesión aquí',
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

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _selectedRole?.id,
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