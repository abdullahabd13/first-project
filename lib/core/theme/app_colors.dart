import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryDark = Color(0xFF1E513B);
  static const Color primary = Color(0xFF286E50);
  static const Color primaryMedium = Color(0xFF3B8C68);
  static const Color primaryLight = Color(0xFF67B591);
  static const Color mintAccent = Color(0xFFD1F0E2);
  static const Color mintBackground = Color(0xFFE2F0EC);
  static const Color background = Color(0xFFF8FAFC);
  static const Color fieldBackground = Color(0xFFE2EBE6);
  static const Color fieldBackgroundDark = Color(0xFF1B2838);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF475569); // WCAG AAA compliant (>= 7:1 against white)
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color cardBackground = Colors.white;

  // High-Contrast Clinical Status Tokens (Light Mode - WCAG AAA compliant)
  static const Color emergencyRed = Color(0xFF991B1B);
  static const Color emergencyRedBg = Color(0xFFFEE2E2);
  static const Color emergencyRedBorder = Color(0xFFF87171);
  static const Color warningAmber = Color(0xFF78350F);
  static const Color warningAmberBg = Color(0xFFFEF3C7);
  static const Color warningAmberBorder = Color(0xFFFBBF24);
  static const Color successGreen = Color(0xFF14532D);
  static const Color successGreenBg = Color(0xFFDCFCE7);
  static const Color successGreenBorder = Color(0xFF4ADE80);
  static const Color infoBlue = Color(0xFF1E3A8A);
  static const Color infoBlueBg = Color(0xFFDBEAFE);
  static const Color infoBlueBorder = Color(0xFF60A5FA);

  // Dark Mode Tokens (WCAG AAA compliant)
  static const Color darkBackground = Color(0xFF0B1320);
  static const Color darkSurface = Color(0xFF152238);
  static const Color darkCard = Color(0xFF152238);
  static const Color darkBorder = Color(0xFF2E405E);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextMuted = Color(0xFFCBD5E1); // WCAG AAA compliant (>= 7:1 against dark card)
  static const Color darkAccent = Color(0xFF4ADE80);

  // Dark Mode Clinical Status Tokens (WCAG AAA compliant)
  static const Color darkEmergencyRed = Color(0xFFFCA5A5);
  static const Color darkEmergencyRedBg = Color(0xFF450A0A);
  static const Color darkWarningAmber = Color(0xFFFDE68A);
  static const Color darkWarningAmberBg = Color(0xFF451A03);
  static const Color darkSuccessGreen = Color(0xFF86EFAC);
  static const Color darkSuccessGreenBg = Color(0xFF052E16);
  static const Color darkInfoBlue = Color(0xFF93C5FD);
  static const Color darkInfoBlueBg = Color(0xFF172554);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1E513B),
      Color(0xFF2D7454),
      Color(0xFF4C9875),
    ],
  );

  static const LinearGradient welcomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF1B4D37),
      Color(0xFF26664A),
      Color(0xFF3B8563),
      Color(0xFF5EAA86),
    ],
  );

  static const LinearGradient darkHeaderGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0A1628), Color(0xFF112240), Color(0xFF1A3358)],
  );

  static const LinearGradient darkWelcomeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF070F1C), Color(0xFF0D1B2A), Color(0xFF132B46), Color(0xFF1B3D66)],
  );
}
