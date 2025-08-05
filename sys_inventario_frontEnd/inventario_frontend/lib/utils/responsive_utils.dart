import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints para diferentes tamaños de pantalla
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Obtener el tipo de pantalla basado en el ancho
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  // Obtener el ancho de la pantalla
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Obtener la altura de la pantalla
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Obtener el padding responsivo
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenType.desktop:
        return const EdgeInsets.all(32.0);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(40.0);
    }
  }

  // Obtener el ancho máximo del contenido
  static double getMaxContentWidth(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 600;
      case ScreenType.desktop:
        return 800;
      case ScreenType.largeDesktop:
        return 1000;
    }
  }

  // Obtener el número de columnas para el grid
  static int getGridCrossAxisCount(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
        return 4;
      case ScreenType.largeDesktop:
        return 5;
    }
  }

  // Obtener el tamaño del ícono responsivo
  static double getResponsiveIconSize(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return 30;
      case ScreenType.tablet:
        return 40;
      case ScreenType.desktop:
        return 50;
      case ScreenType.largeDesktop:
        return 60;
    }
  }

  // Obtener el tamaño del contenedor del ícono responsivo
  static double getResponsiveIconContainerSize(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return 60;
      case ScreenType.tablet:
        return 80;
      case ScreenType.desktop:
        return 100;
      case ScreenType.largeDesktop:
        return 120;
    }
  }

  // Obtener el padding del card responsivo
  static EdgeInsets getResponsiveCardPadding(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return const EdgeInsets.all(16.0);
      case ScreenType.tablet:
        return const EdgeInsets.all(24.0);
      case ScreenType.desktop:
        return const EdgeInsets.all(32.0);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(40.0);
    }
  }

  // Obtener el tamaño de fuente responsivo para títulos
  static double getResponsiveTitleFontSize(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return 18;
      case ScreenType.tablet:
        return 22;
      case ScreenType.desktop:
        return 26;
      case ScreenType.largeDesktop:
        return 30;
    }
  }

  // Obtener el tamaño de fuente responsivo para subtítulos
  static double getResponsiveSubtitleFontSize(BuildContext context) {
    final screenType = getScreenType(context);
    
    switch (screenType) {
      case ScreenType.mobile:
        return 14;
      case ScreenType.tablet:
        return 16;
      case ScreenType.desktop:
        return 18;
      case ScreenType.largeDesktop:
        return 20;
    }
  }

  // Verificar si es una pantalla móvil
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  // Verificar si es una pantalla tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  // Verificar si es una pantalla desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop || 
           getScreenType(context) == ScreenType.largeDesktop;
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
} 