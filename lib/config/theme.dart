import 'package:flutter/material.dart';

class AppColors {
  // Primary Brown Palette
  static const Color darkBrown = Color(0xFFDCB995); // Changed from dark brown to warm beige
  static const Color mediumBrown = Color(0xFF6D4C41);
  static const Color lightBrown = Color(0xFFA1887F);
  static const Color creamBackground = Color(0xFFF8F3ED);
  static const Color white = Color(0xFFFFFFFF);
  
  // Accent Colors
  static const Color warmBrown = Color(0xFF8D6E63);
  static const Color paleGold = Color(0xFFD7CCC8);
  static const Color softBeige = Color(0xFFEFEBE9);
  
  // Status Colors
  static const Color available = Color(0xFF81C784); // Green
  static const Color partiallyFilled = Color(0xFFFFD54F); // Yellow
  static const Color fullyBooked = Color(0xFFE57373); // Red
  static const Color notAvailable = Color(0xFF9E9E9E); // Brown-Grey
  
  // Text Colors
  static const Color textPrimary = Color(0xFF3E2723);
  static const Color textSecondary = Color(0xFF5D4037);
  static const Color textLight = Color(0xFF8D6E63);
  
  // Error & Success
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
}

/// Dark mode color palette
class DarkColors {
  // Primary Brown Palette (adjusted for dark mode)
  static const Color darkBrown = Color(0xFFCDAB7C); // Lighter for dark bg
  static const Color mediumBrown = Color(0xFFA1887F);
  static const Color lightBrown = Color(0xFFBCAAA4);
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF2D2D2D);
  static const Color cardColor = Color(0xFF363636);
  
  // Accent Colors
  static const Color warmBrown = Color(0xFFBCAAA4);
  static const Color paleGold = Color(0xFF5D4037);
  static const Color softBeige = Color(0xFF3E2723);
  
  // Status Colors
  static const Color available = Color(0xFF81C784);
  static const Color partiallyFilled = Color(0xFFFFD54F);
  static const Color fullyBooked = Color(0xFFE57373);
  static const Color notAvailable = Color(0xFF757575);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFBDBDBD);
  static const Color textLight = Color(0xFF9E9E9E);
  
  // Error & Success
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.darkBrown,
      scaffoldBackgroundColor: AppColors.creamBackground,
      
      colorScheme: ColorScheme.light(
        primary: AppColors.darkBrown,
        secondary: AppColors.mediumBrown,
        surface: AppColors.white,
        background: AppColors.creamBackground,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.white,
      ),
      
      fontFamily: 'Poppins',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBrown,
        foregroundColor: AppColors.textPrimary, // Dark text on light background
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBrown,
          foregroundColor: AppColors.textPrimary, // Dark text on light button
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkBrown,
          side: const BorderSide(color: AppColors.darkBrown, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkBrown,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.paleGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.paleGold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBrown, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontFamily: 'Poppins',
        ),
        hintStyle: const TextStyle(
          color: AppColors.textLight,
          fontFamily: 'Poppins',
        ),
      ),
      
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 2,
        shadowColor: AppColors.darkBrown.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkBrown,
        foregroundColor: AppColors.white,
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.darkBrown,
        unselectedItemColor: AppColors.textLight,
      ),
      
      dividerTheme: const DividerThemeData(
        color: AppColors.paleGold,
        thickness: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkBrown,
        contentTextStyle: const TextStyle(
          color: AppColors.white,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
  
  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: DarkColors.darkBrown,
      scaffoldBackgroundColor: DarkColors.background,
      
      colorScheme: ColorScheme.dark(
        primary: DarkColors.darkBrown,
        secondary: DarkColors.mediumBrown,
        surface: DarkColors.surface,
        error: DarkColors.error,
        onPrimary: DarkColors.background,
        onSecondary: DarkColors.textPrimary,
        onSurface: DarkColors.textPrimary,
        onError: DarkColors.textPrimary,
      ),
      
      fontFamily: 'Poppins',
      
      appBarTheme: const AppBarTheme(
        backgroundColor: DarkColors.surface,
        foregroundColor: DarkColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: DarkColors.textPrimary,
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: DarkColors.darkBrown,
          foregroundColor: DarkColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: DarkColors.darkBrown,
          side: const BorderSide(color: DarkColors.darkBrown, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DarkColors.darkBrown,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DarkColors.cardColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkColors.paleGold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkColors.paleGold),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkColors.darkBrown, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkColors.error),
        ),
        labelStyle: const TextStyle(
          color: DarkColors.textSecondary,
          fontFamily: 'Poppins',
        ),
        hintStyle: const TextStyle(
          color: DarkColors.textLight,
          fontFamily: 'Poppins',
        ),
      ),
      
      cardTheme: CardThemeData(
        color: DarkColors.cardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: DarkColors.darkBrown,
        foregroundColor: DarkColors.background,
      ),
      
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: DarkColors.surface,
        selectedItemColor: DarkColors.darkBrown,
        unselectedItemColor: DarkColors.textLight,
      ),
      
      dividerTheme: const DividerThemeData(
        color: DarkColors.paleGold,
        thickness: 1,
      ),
      
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DarkColors.cardColor,
        contentTextStyle: const TextStyle(
          color: DarkColors.textPrimary,
          fontFamily: 'Poppins',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}