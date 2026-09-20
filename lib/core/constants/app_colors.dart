import 'package:flutter/material.dart';

/// StoreMate Premium Theme Colors.
///
/// Design rules:
///   - Black / White / Gray only
///   - Purple (#5C59E8) = Primary CTA only
///   - Green = Positive (profit, in-stock, success)
///   - Red = Negative (loss, out-of-stock, error)
///   - No colorful cards, no rainbow dashboards
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  final Color background;
  final Color card;
  final Color elevatedCard;
  final Color border;
  final Color primary;
  final Color primaryForeground;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color success;
  final Color warning;
  final Color danger;

  const AppCustomColors({
    required this.background,
    required this.card,
    required this.elevatedCard,
    required this.border,
    required this.primary,
    required this.primaryForeground,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.success,
    required this.warning,
    required this.danger,
  });

  @override
  ThemeExtension<AppCustomColors> copyWith({
    Color? background,
    Color? card,
    Color? elevatedCard,
    Color? border,
    Color? primary,
    Color? primaryForeground,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? success,
    Color? warning,
    Color? danger,
  }) {
    return AppCustomColors(
      background: background ?? this.background,
      card: card ?? this.card,
      elevatedCard: elevatedCard ?? this.elevatedCard,
      border: border ?? this.border,
      primary: primary ?? this.primary,
      primaryForeground: primaryForeground ?? this.primaryForeground,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  ThemeExtension<AppCustomColors> lerp(covariant ThemeExtension<AppCustomColors>? other, double t) {
    if (other is! AppCustomColors) {
      return this;
    }
    return AppCustomColors(
      background: Color.lerp(background, other.background, t)!,
      card: Color.lerp(card, other.card, t)!,
      elevatedCard: Color.lerp(elevatedCard, other.elevatedCard, t)!,
      border: Color.lerp(border, other.border, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryForeground: Color.lerp(primaryForeground, other.primaryForeground, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }

  // ── Light Theme ──
  static const light = AppCustomColors(
    background: Color(0xFFFAFAFA),
    card: Color(0xFFFFFFFF),
    elevatedCard: Color(0xFFF5F5F5),
    border: Color(0xFFE5E5E5),
    primary: Color(0xFF5C59E8),
    primaryForeground: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0A0A0A),
    textSecondary: Color(0xFF737373),
    textTertiary: Color(0xFFA3A3A3),
    success: Color(0xFF16A34A),
    warning: Color(0xFFD97706),
    danger: Color(0xFFDC2626),
  );

  // ── Dark Theme ──
  static const dark = AppCustomColors(
    background: Color(0xFF0A0A0A),
    card: Color(0xFF141414),
    elevatedCard: Color(0xFF1C1C1C),
    border: Color(0xFF262626),
    primary: Color(0xFF5C59E8),
    primaryForeground: Color(0xFFFFFFFF),
    textPrimary: Color(0xFFFAFAFA),
    textSecondary: Color(0xFF737373),
    textTertiary: Color(0xFF525252),
    success: Color(0xFF22C55E),
    warning: Color(0xFFF59E0B),
    danger: Color(0xFFEF4444),
  );
}

/// Extension on BuildContext to easily access custom colors via `context.colors`
extension BuildContextColors on BuildContext {
  AppCustomColors get colors => Theme.of(this).extension<AppCustomColors>()!;
}

/// Legacy AppColors constants to temporarily satisfy the compiler while we refactor.
/// DO NOT USE these in new code. They will be progressively removed.
class AppColors {
  AppColors._();
  
  static const Color background = Color(0xFF0A0A0A);
  static const Color card = Color(0xFF141414);
  static const Color elevatedCard = Color(0xFF1C1C1C);
  static const Color border = Color(0xFF262626);
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFF737373);
  static const Color accent = Color(0xFF5C59E8);
  static const Color accentForeground = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);

  // Legacy Aliases
  static const Color primary = accent;
  static const Color onPrimary = accentForeground;
  static const Color ink = textPrimary;
  static const Color body = textSecondary;
  static const Color mute = textSecondary;
  static const Color hairlineMid = border;
  static const Color canvas = background;
  static const Color canvasSoft = card;
  static const Color canvasSofter = elevatedCard;
  static const Color error = danger;
  static const Color primaryLight = card;
  static const Color primaryDark = background;
  static const Color primarySurface = elevatedCard;
  static const Color accentLight = accent;
  static const Color accentDark = accent;
  static const Color surface = card;
  static const Color surfaceVariant = elevatedCard;
  static const Color scaffoldDark = background;
  static const Color textTertiary = textSecondary;
  static const Color textOnPrimary = accentForeground;
  static const Color info = Color(0xFF3B82F6);
  static const Color divider = border;
}
