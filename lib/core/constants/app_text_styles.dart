import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// StoreMate V2 Typography System
/// Strictly uses Inter with specific weights.
/// 
/// Note: Colors are no longer hardcoded here. They inherit from Theme.of(context).textTheme
/// or should be passed explicitly using `.copyWith(color: context.colors.XXX)` in UI files.
class AppTextStyles {
  AppTextStyles._();

  // ── Display Numbers (Revenue, Sales, Totals) - ExtraBold w800 ──
  static TextStyle get displayXl => GoogleFonts.inter(
        fontSize: 36, fontWeight: FontWeight.w800, height: 1.1);
  static TextStyle get displayLg => GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w800, height: 1.1);
  static TextStyle get displayMd => GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.w800, height: 1.15);

  // ── Screen Titles - Bold w700 ──
  static TextStyle get titleXl => GoogleFonts.inter(
        fontSize: 32, fontWeight: FontWeight.w700, height: 1.2);
  static TextStyle get titleLg => GoogleFonts.inter(
        fontSize: 28, fontWeight: FontWeight.w700, height: 1.2);

  // ── Section Titles - Bold w700 ──
  static TextStyle get titleMd => GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.w700, height: 1.2);
  static TextStyle get titleSm => GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w700, height: 1.2);

  // ── Product Names - SemiBold w600 ──
  static TextStyle get productLg => GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, height: 1.4);
  static TextStyle get productMd => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, height: 1.4);

  // ── Labels - Medium w500 ──
  static TextStyle get labelLg => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w500, height: 1.4);
  static TextStyle get labelMd => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.4);
  static TextStyle get labelSm => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, height: 1.4);

  // ── Body Text - Regular w400 ──
  static TextStyle get bodyLg => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodyMd => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, height: 1.5);
  static TextStyle get bodySm => GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, height: 1.5);

  // ── Mono / Tabular Numbers - for currency & metrics ──
  static TextStyle get monoLg => GoogleFonts.inter(
        fontSize: 24, fontWeight: FontWeight.w700, height: 1.1,
        fontFeatures: const [FontFeature.tabularFigures()]);
  static TextStyle get monoMd => GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, height: 1.2,
        fontFeatures: const [FontFeature.tabularFigures()]);
  static TextStyle get monoSm => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w500, height: 1.2,
        fontFeatures: const [FontFeature.tabularFigures()]);

  // ── Buttons ──
  static TextStyle get btnLarge => GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, height: 1.2);
  static TextStyle get btnMd => GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, height: 1.2);

  // ── Legacy Aliases ──
  static TextStyle get h1 => titleXl;
  static TextStyle get h2 => titleLg;
  static TextStyle get h3 => titleMd;
  static TextStyle get h4 => titleSm;
  
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get bodySmall => bodySm;
  
  static TextStyle get labelLarge => labelLg;
  static TextStyle get labelMedium => labelMd;
  
  static TextStyle get displayXxl => displayXl;
  static TextStyle get displaySm => titleSm;
  
  static TextStyle get bodyMdStrong => productMd;
  static TextStyle get bodySmStrong => labelMd;
  static TextStyle get uberCaption => labelSm;
  
  static TextStyle get buttonLarge => btnLarge;
  static TextStyle get buttonMedium => btnMd;
  static TextStyle get caption => labelSm;
}
