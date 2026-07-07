import 'package:flutter/material.dart';

class SodfaStyles {
  static const Color primaryPurple = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5A52D5);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentTeal = Color(0xFF03DAC6);
  static const Color softOrange = Color(0xFFFF8C42);
  static const Color backgroundLight = Color(0xFFF8F9FE);
  static const Color backgroundDark = Color(0xFF1A1A2E);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFFF0F0FF);
  static const Color surfaceDark = Color(0xFF0F3460);
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color textHint = Color(0xFFB2BEC3);
  static const Color dividerColor = Color(0xFFE8E8F0);
  static const Color successGreen = Color(0xFF00B894);
  static const Color errorRed = Color(0xFFD63031);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color silverColor = Color(0xFFC0C0C0);

  static const double cardBorderRadius = 16;
  static const double smallBorderRadius = 10;
  static const double buttonBorderRadius = 12;
  static const double avatarRadius = 24;
  static const double largeAvatarRadius = 40;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets listPadding = EdgeInsets.symmetric(horizontal: 16);

  static BoxDecoration glassCardDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(cardBorderRadius),
    border: Border.all(color: Colors.white.withOpacity(0.3)),
    boxShadow: [
      BoxShadow(
        color: primaryPurple.withOpacity(0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration gradientCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      colors: [primaryPurple, primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(cardBorderRadius),
    boxShadow: [
      BoxShadow(
        color: primaryPurple.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration voiceRoomDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        primaryPurple.withOpacity(0.1),
        accentTeal.withOpacity(0.05),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(cardBorderRadius),
    border: Border.all(color: primaryPurple.withOpacity(0.15)),
  );

  static BoxDecoration activeSpeakerDecoration = BoxDecoration(
    border: Border.all(color: successGreen, width: 2),
    borderRadius: BorderRadius.circular(avatarRadius + 2),
    boxShadow: [
      BoxShadow(
        color: successGreen.withOpacity(0.3),
        blurRadius: 8,
        spreadRadius: 1,
      ),
    ],
  );

  static TextStyle sectionTitle = const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle sectionSubtitle = TextStyle(
    fontSize: 13,
    color: textSecondary,
    fontWeight: FontWeight.w400,
  );

  static TextStyle priceText = const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: goldColor,
  );

  static TextStyle badgeText = const TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}
