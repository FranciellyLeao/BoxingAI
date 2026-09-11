import 'package:flutter/material.dart';

/// Design System Cyber-Boxing
/// Cores: Fundo #0B0F19, Neon Accent #00FF66, Cyber Pink #FF0055, Card #161F33.
abstract class CyberBoxingTheme {
  static const Color background = Color(0xFF0B0F19);
  static const Color surfaceCard = Color(0xFF161F33);
  static const Color surfaceCardBorder = Color(0xFF23304D);
  static const Color neonGreen = Color(0xFF00FF66);
  static const Color neonPink = Color(0xFFFF0055);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8C9BAE);

  static LinearGradient get neonGreenGradient => const LinearGradient(
        colors: [Color(0xFF00FF66), Color(0xFF00B347)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get cyberCardGradient => const LinearGradient(
        colors: [Color(0xFF161F33), Color(0xFF0F1726)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static List<BoxShadow> get neonGlow => [
        BoxShadow(
          color: neonGreen.withOpacity(0.4),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ];

  static ThemeData get themeData => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        primaryColor: neonGreen,
        colorScheme: const ColorScheme.dark(
          primary: neonGreen,
          secondary: neonPink,
          surface: surfaceCard,
          background: background,
        ),
        cardTheme: CardTheme(
          color: surfaceCard,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: surfaceCardBorder, width: 1),
          ),
        ),
        useMaterial3: true,
      );
}
