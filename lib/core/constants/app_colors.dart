import 'package:flutter/material.dart';

/// StoreMate brand color palette.
///
/// Primary: Deep indigo for professionalism and trust.
/// Accent: Warm amber/gold for premium Indian retail aesthetic.
/// Surface: Dark mode tones for modern, premium feel.
class AppColors {
  AppColors._();

  // ── Primary Palette ───────────────────────────────────────
  static const Color primary = Color(0xFF4F46E5);       // Indigo 600
  static const Color primaryLight = Color(0xFF818CF8);   // Indigo 400
  static const Color primaryDark = Color(0xFF3730A3);    // Indigo 800
  static const Color primarySurface = Color(0xFFEEF2FF); // Indigo 50

  // ── Accent / Secondary ────────────────────────────────────
  static const Color accent = Color(0xFFF59E0B);         // Amber 500
  static const Color accentLight = Color(0xFFFBBF24);    // Amber 400
  static const Color accentDark = Color(0xFFD97706);     // Amber 600

  // ── Backgrounds ───────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);     // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate 100
  static const Color scaffoldDark = Color(0xFF0F172A);   // Slate 900

  // ── Text ──────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1E293B);    // Slate 800
  static const Color textSecondary = Color(0xFF64748B);  // Slate 500
  static const Color textTertiary = Color(0xFF94A3B8);   // Slate 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Status ────────────────────────────────────────────────
  static const Color success = Color(0xFF10B981);        // Emerald 500
  static const Color error = Color(0xFFEF4444);          // Red 500
  static const Color warning = Color(0xFFF59E0B);        // Amber 500
  static const Color info = Color(0xFF3B82F6);           // Blue 500

  // ── Borders & Dividers ────────────────────────────────────
  static const Color border = Color(0xFFE2E8F0);        // Slate 200
  static const Color divider = Color(0xFFF1F5F9);       // Slate 100

  // ── Gradients ─────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4F46E5), Color(0xFF1E1B4B)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
  );
}
