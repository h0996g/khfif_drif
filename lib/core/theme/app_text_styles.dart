// lib/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralised text-style definitions.
///
/// All font sizes use `.sp` from flutter_screenutil.
/// Display styles use Plus Jakarta Sans; body/label/input styles use Inter.
abstract final class AppTextStyles {
  AppTextStyles._();

  // ── Display (Plus Jakarta Sans) ──────────────────────────────────────────

  static TextStyle displayLarge(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 32.sp,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.2,
      );

  static TextStyle displayMedium(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 28.sp,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.25,
      );

  static TextStyle displaySmall(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 24.sp,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.3,
      );

  // ── Headings ──────────────────────────────────────────────────────────────

  static TextStyle headingMedium(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.35,
      );

  static TextStyle headingSmall(BuildContext context) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.4,
      );

  // ── Body (Inter) ──────────────────────────────────────────────────────────

  static TextStyle bodyLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.5,
      );

  static TextStyle bodyMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.5,
      );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.5,
      );

  // ── Label / Button ────────────────────────────────────────────────────────

  static TextStyle labelLarge(BuildContext context) => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onPrimary,
        height: 1.0,
      );

  static TextStyle labelMedium(BuildContext context) => GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.0,
      );

  static TextStyle labelSmall(BuildContext context) => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.4,
      );

  // ── Input ─────────────────────────────────────────────────────────────────

  static TextStyle inputText(BuildContext context) => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface,
        height: 1.0,
      );

  static TextStyle inputHint(BuildContext context) => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        height: 1.0,
      );

  static TextStyle inputError(BuildContext context) => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: Theme.of(context).colorScheme.error,
        height: 1.4,
      );
}
