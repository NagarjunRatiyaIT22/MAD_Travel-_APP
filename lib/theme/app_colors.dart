import 'package:flutter/material.dart';

/// App color palette — curated for a premium travel app feel.
class AppColors {
  AppColors._();

  // Primary palette
  static const Color primaryLight = Color(0xFF6C63FF);
  static const Color primary = Color(0xFF5B52E0);
  static const Color primaryDark = Color(0xFF4A42C4);

  // Secondary / Accent
  static const Color accent = Color(0xFF00D2FF);
  static const Color accentLight = Color(0xFF7EEAFF);

  // Semantic colors
  static const Color success = Color(0xFF2ED573);
  static const Color warning = Color(0xFFFFBE21);
  static const Color error = Color(0xFFFF6B6B);
  static const Color info = Color(0xFF54A0FF);

  // Neutrals — Light mode
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1A1D26);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color dividerLight = Color(0xFFE5E7EB);

  // Neutrals — Dark mode
  static const Color backgroundDark = Color(0xFF0F1123);
  static const Color surfaceDark = Color(0xFF1A1D2E);
  static const Color cardDark = Color(0xFF222539);
  static const Color textPrimaryDark = Color(0xFFF1F3F9);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color dividerDark = Color(0xFF2D3154);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFBE21)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coolGradient = LinearGradient(
    colors: [Color(0xFF00D2FF), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF2ED573), Color(0xFF00D2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF1A1D2E), Color(0xFF222539)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Participant avatar colors
  static const List<Color> avatarColors = [
    Color(0xFF6C63FF),
    Color(0xFFFF6B6B),
    Color(0xFF2ED573),
    Color(0xFFFFBE21),
    Color(0xFF00D2FF),
    Color(0xFFFF9FF3),
    Color(0xFFFF6348),
    Color(0xFF54A0FF),
    Color(0xFF5F27CD),
    Color(0xFF01A3A4),
  ];

  /// Trip cover gradient presets
  static const List<LinearGradient> tripCoverGradients = [
    LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFfa709a), Color(0xFFfee140)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFa18cd1), Color(0xFFfbc2eb)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFFfccb90), Color(0xFFd57eeb)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    LinearGradient(
      colors: [Color(0xFF30cfd0), Color(0xFF330867)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
}
