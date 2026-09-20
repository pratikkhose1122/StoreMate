import 'package:flutter/material.dart';
import 'package:storemate/core/constants/app_colors.dart';
import 'package:storemate/core/constants/app_text_styles.dart';

/// StoreMate Premium Theme Configuration.
///
/// Monochromatic. No colorful accents.
/// Purple CTA only. Green=Positive. Red=Negative.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return _buildTheme(
      colors: AppCustomColors.light,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF5C59E8),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFFFFFFFF),
        surface: Color(0xFFFAFAFA),
        onSurface: Color(0xFF0A0A0A),
        error: Color(0xFFDC2626),
      ),
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      colors: AppCustomColors.dark,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF5C59E8),
        onPrimary: Color(0xFFFFFFFF),
        secondary: Color(0xFF141414),
        surface: Color(0xFF0A0A0A),
        onSurface: Color(0xFFFAFAFA),
        error: Color(0xFFEF4444),
      ),
    );
  }

  static ThemeData _buildTheme({
    required AppCustomColors colors,
    required Brightness brightness,
    required ColorScheme colorScheme,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.background,
      brightness: brightness,
      extensions: [colors],

      // Typography
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayXl,
        displayMedium: AppTextStyles.displayLg,
        displaySmall: AppTextStyles.displayMd,
        headlineLarge: AppTextStyles.titleXl,
        headlineMedium: AppTextStyles.titleLg,
        headlineSmall: AppTextStyles.titleMd,
        titleLarge: AppTextStyles.titleSm,
        titleMedium: AppTextStyles.productLg,
        titleSmall: AppTextStyles.productMd,
        bodyLarge: AppTextStyles.bodyLg,
        bodyMedium: AppTextStyles.bodyMd,
        bodySmall: AppTextStyles.bodySm,
        labelLarge: AppTextStyles.labelLg,
        labelMedium: AppTextStyles.labelMd,
        labelSmall: AppTextStyles.labelSm,
      ),

      // AppBar — flat, minimal
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: colors.background,
        foregroundColor: colors.textPrimary,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTextStyles.productLg.copyWith(color: colors.textPrimary),
      ),

      // Elevated Button (Primary CTA — Purple)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.primaryForeground,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.btnLarge,
        ),
      ),

      // Outlined Button (Secondary)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.textPrimary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: colors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.btnLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          textStyle: AppTextStyles.btnMd,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.elevatedCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.danger, width: 1.5),
        ),
        hintStyle: AppTextStyles.bodyMd.copyWith(color: colors.textTertiary),
        labelStyle: AppTextStyles.bodyMd.copyWith(color: colors.textSecondary),
      ),

      // Card — flat, border-only
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: colors.border, width: 1),
        ),
        color: colors.card,
        margin: EdgeInsets.zero,
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colors.border,
        thickness: 1,
        space: 1,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: colors.card,
        contentTextStyle: AppTextStyles.bodyMd.copyWith(color: colors.textPrimary),
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: colors.elevatedCard,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(color: colors.border),
        ),
        labelStyle: AppTextStyles.labelMd.copyWith(color: colors.textPrimary),
      ),

      // Bottom Navigation — minimal
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.background,
        selectedItemColor: colors.textPrimary,
        unselectedItemColor: colors.textTertiary,
        selectedLabelStyle: AppTextStyles.labelSm.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelSm,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // FAB — Purple CTA
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.primaryForeground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
    );
  }
}
