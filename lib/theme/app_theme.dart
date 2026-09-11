import 'package:flutter/material.dart';

/// نظام التصميم الموحّد للتطبيق: لوحة ألوان فاخرة وحيوية
/// (زمردي غامق + ذهبي + كورال) مع تدرجات وأنماط نصوص جاهزة.
class AppColors {
  AppColors._();

  // الألوان الأساسية
  static const Color emerald = Color(0xFF0F6E56);
  static const Color emeraldDark = Color(0xFF0B4A3C);
  static const Color emeraldLight = Color(0xFF1D9E75);
  static const Color gold = Color(0xFFD9A94E);
  static const Color goldDark = Color(0xFFB8862F);
  static const Color coral = Color(0xFFFF7A59);
  static const Color coralLight = Color(0xFFFFB84D);
  static const Color plum = Color(0xFF7F77DD);

  // خلفيات ونصوص
  static const Color background = Color(0xFFFBF8F2);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1F2A24);
  static const Color textSecondary = Color(0xFF8A8578);
  static const Color border = Color(0xFFEFEAE0);
  static const Color danger = Color(0xFFE24B4A);
  static const Color success = Color(0xFF1D9E75);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [emeraldDark, emerald],
  );

  static const LinearGradient vibrantGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [coral, coralLight],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldDark],
  );

  /// ألوان دورية للكبسولات حسب ترتيب الدواء، لإحساس حيوي متعدد الألوان
  static const List<Color> capsuleColors = [emerald, coral, plum, gold];

  static Color capsuleColorFor(int index) =>
      capsuleColors[index % capsuleColors.length];
}

class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 550);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;
}

class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      fontFamily: 'Cairo',
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.emerald,
        primary: AppColors.emerald,
        secondary: AppColors.gold,
        surface: AppColors.surface,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
        titleMedium: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(color: AppColors.textPrimary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.emerald,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.emerald, width: 1.4),
        ),
      ),
    );
  }
}
