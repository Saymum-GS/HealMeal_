import 'package:flutter/material.dart';

class AppColors {
  // ── Brand Primary ──
  static const Color primary = Color(0xFF0B6E4F);
  static const Color primaryDark = Color(0xFF084F38);
  static const Color primaryLight = Color(0xFFE6F4EF);
  static const Color primaryMid = Color(0xFFB2DFDB);

  // ── Premium Accent Palette ──
  static const Color accentOrange = Color(0xFFF4A261);
  static const Color accentRed = Color(0xFFE63946);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentTeal = Color(0xFF00BFA5);
  static const Color accentPurple = Color(0xFF7C4DFF);

  // ── Light Mode ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFF7F9F8);
  static const Color subtle = Color(0xFFF0F2F1);
  static const Color border = Color(0xFFE0E5E3);
  static const Color muted = Color(0xFF8FA39B);
  static const Color secondary = Color(0xFF5A6272);
  static const Color textPrimary = Color(0xFF1A2E26);
  static const Color textDark = Color(0xFF0D1B15);

  // ── Dark Mode ──
  static const Color darkBg = Color(0xFF0D1B15);
  static const Color darkSurface = Color(0xFF1A2E26);
  static const Color darkCard = Color(0xFF1F3B2E);
  static const Color darkBorder = Color(0xFF2D4A3A);
  static const Color darkMuted = Color(0xFF5A7A68);
  static const Color darkTextPri = Color(0xFFE8F5EF);
  static const Color darkTextSec = Color(0xFFB2CDBE);

  // ── Semantic ──
  static const Color success = Color(0xFF2E7D32);
  static const Color successBg = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57C00);
  static const Color warningBg = Color(0xFFFFF3E0);
  static const Color error = Color(0xFFC62828);
  static const Color errorBg = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1565C0);
  static const Color infoBg = Color(0xFFE3F2FD);

  // ── Premium Gradients ──
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B6E4F), Color(0xFF1A9E73)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF084F38), Color(0xFF0B6E4F), Color(0xFF1A9E73)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE63946), Color(0xFFF4A261)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1A2E26), Color(0xFF0D1B15)],
  );

  static const LinearGradient cardShimmer = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x08FFFFFF), Color(0x14FFFFFF), Color(0x08FFFFFF)],
  );

  // ── Premium Shadows ──
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: primary.withOpacity(0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.02),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primary.withOpacity(0.15),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ];
}

