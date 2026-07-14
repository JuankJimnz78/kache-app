// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  // ── Fondos ────────────────────────────────────────────────
  static const Color background =
      Color(0xFFFAF8F4); // crema cálido, no blanco frío
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surface2 = Color(0xFFF3F1EB);
  static const Color border = Color(0xFFE6E2D8);
  static const Color borderLight = Color(0xFFEFEDE5);

  // ── Texto ─────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF221F1B);
  static const Color textSecondary = Color(0xFF6F6A60);
  static const Color textFaint = Color(0xFFAFA99C);

  // ── Accent dorado (más intenso que en oscuro, para contraste sobre claro) ──
  static const Color accent = Color(0xFFC9952E);
  static const Color accentLight = Color(0xFFE0B65A);
  static const Color accentDark = Color(0xFF8F6A1F);
  static const Color onAccent =
      Color(0xFF221F1B); // texto oscuro sobre el dorado

  // ── Semánticos ────────────────────────────────────────────
  static const Color success = Color(0xFF15803D);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFB91C1C);
  static const Color info = Color(0xFF1D4ED8);

  AppColors._();
}
