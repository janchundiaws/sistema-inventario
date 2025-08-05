class AppConfig {
  // Configuración del Backend
  static const String backendUrl = 'http://localhost:3000';
  static const String apiBaseUrl = '$backendUrl/api';
  
  // Configuración de la aplicación
  static const String appName = 'Sistema de Inventario';
  static const String appVersion = '1.0.0';
  
  // Timeouts
  static const int connectionTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos
  
  // Configuración de desarrollo
  static const bool isDevelopment = true;
  
  // URLs específicas para diferentes entornos
  static const Map<String, String> environmentUrls = {
    'development': 'http://localhost:3000',
    'staging': 'http://staging-api.tudominio.com',
    'production': 'https://api.tudominio.com',
  };
  
  // Obtener URL del backend según el entorno
  static String getBackendUrl() {
    if (isDevelopment) {
      return environmentUrls['development']!;
    }
    return environmentUrls['production']!;
  }
  
  // Obtener URL completa de la API
  static String getApiUrl() {
    return '${getBackendUrl()}/api';
  }
} 