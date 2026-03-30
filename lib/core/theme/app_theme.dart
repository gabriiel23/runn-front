import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Enums ─────────────────────────────────────────────────────────────────────

enum AppColorScheme { pink, blue }

enum AppBrightness { light, dark }

// ── Color tokens ─────────────────────────────────────────────────────────────

class AppColors {
  // Accent palette
  final Color primary;
  final Color primaryLight;
  final Color primaryMid;
  final Color primaryDark;
  final Color primaryDeep;

  // Backgrounds
  final Color bg;
  final Color surface;
  final Color card;
  final Color cardBorder;

  // Nav bar
  final Color navBg;
  final Color navActive;
  final Color navInactive;

  // Text
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;

  // Input
  final Color inputFill;
  final Color inputBorder;
  final Color inputBorderFocused;

  // Dark overlay tints
  final Color darkBg;
  final Color darkCard;
  final Color darkSurface;

  final bool isDark;

  const AppColors({
    required this.primary,
    required this.primaryLight,
    required this.primaryMid,
    required this.primaryDark,
    required this.primaryDeep,
    required this.bg,
    required this.surface,
    required this.card,
    required this.cardBorder,
    required this.navBg,
    required this.navActive,
    required this.navInactive,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.inputFill,
    required this.inputBorder,
    required this.inputBorderFocused,
    required this.darkBg,
    required this.darkCard,
    required this.darkSurface,
    required this.isDark,
  });

  // ── Factory constructors ──────────────────────────────────────────────────

  factory AppColors.pinkLight() => const AppColors(
    primary: Color(0xFFFFD3E0),
    primaryLight: Color(0xFFFFF0F5),
    primaryMid: Color(0xFFFFB8CE),
    primaryDark: Color(0xFFE8A0B8),
    primaryDeep: Color(0xFFC4607A),
    bg: Color(0xFFFCF8F9),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFFFD3E0),
    navBg: Color(0xFFFFFFFF),
    navActive: Color(0xFFC4607A),
    navInactive: Color(0xFF6B6B6B),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF64748B),
    textHint: Color(0xFFAAAAAA),
    inputFill: Color(0xFFFFFFFF),
    inputBorder: Color(0xFFFFB8CE),
    inputBorderFocused: Color(0xFFC4607A),
    darkBg: Color(0xFF2A1520),
    darkCard: Color(0xFF3D1F2A),
    darkSurface: Color(0xFF4F2535),
    isDark: false,
  );

  factory AppColors.pinkDark() => const AppColors(
    primary: Color(0xFFFFD3E0),
    primaryLight: Color(0xFF4F2535),
    primaryMid: Color(0xFFFFB8CE),
    primaryDark: Color(0xFFE8A0B8),
    primaryDeep: Color(0xFFF08AAA),
    bg: Color(0xFF1A0D12),
    surface: Color(0xFF2D1520),
    card: Color(0xFF3D1F2A),
    cardBorder: Color(0xFF5A2D3F),
    navBg: Color(0xFF2D1520),
    navActive: Color(0xFFF08AAA),
    navInactive: Color(0xFF8A7A80),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFCCB8BE),
    textHint: Color(0xFF887078),
    inputFill: Color(0xFF3D1F2A),
    inputBorder: Color(0xFF5A3040),
    inputBorderFocused: Color(0xFFF08AAA),
    darkBg: Color(0xFF0F0809),
    darkCard: Color(0xFF250F18),
    darkSurface: Color(0xFF351525),
    isDark: true,
  );

  factory AppColors.blueLight() => const AppColors(
    primary: Color(0xFF84DEFA),
    primaryLight: Color(0xFFEBF9FF),
    primaryMid: Color(0xFF5BCFF5),
    primaryDark: Color(0xFF2BBCE8),
    primaryDeep: Color(0xFF0A8FAD),
    bg: Color(0xFFF5FEFF),
    surface: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFF84DEFA),
    navBg: Color(0xFFFFFFFF),
    navActive: Color(0xFF0A8FAD),
    navInactive: Color(0xFF6B6B6B),
    textPrimary: Color(0xFF1A1A1A),
    textSecondary: Color(0xFF64748B),
    textHint: Color(0xFFAAAAAA),
    inputFill: Color(0xFFFFFFFF),
    inputBorder: Color(0xFF5BCFF5),
    inputBorderFocused: Color(0xFF0A8FAD),
    darkBg: Color(0xFF0D1A1F),
    darkCard: Color(0xFF1F3540),
    darkSurface: Color(0xFF152530),
    isDark: false,
  );

  factory AppColors.blueDark() => const AppColors(
    primary: Color(0xFF84DEFA),
    primaryLight: Color(0xFF1F3540),
    primaryMid: Color(0xFF5BCFF5),
    primaryDark: Color(0xFF2BBCE8),
    primaryDeep: Color(0xFF4DD4F2),
    bg: Color(0xFF0D1A1F),
    surface: Color(0xFF152530),
    card: Color(0xFF1F3540),
    cardBorder: Color(0xFF2A4555),
    navBg: Color(0xFF152530),
    navActive: Color(0xFF4DD4F2),
    navInactive: Color(0xFF7A9099),
    textPrimary: Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB8D4DD),
    textHint: Color(0xFF7A9099),
    inputFill: Color(0xFF1F3540),
    inputBorder: Color(0xFF2A4555),
    inputBorderFocused: Color(0xFF4DD4F2),
    darkBg: Color(0xFF070F14),
    darkCard: Color(0xFF152530),
    darkSurface: Color(0xFF1F3540),
    isDark: true,
  );

  // ── Static resolver ───────────────────────────────────────────────────────

  static AppColors resolve(AppColorScheme scheme, AppBrightness brightness) {
    if (scheme == AppColorScheme.pink) {
      return brightness == AppBrightness.light
          ? AppColors.pinkLight()
          : AppColors.pinkDark();
    } else {
      return brightness == AppBrightness.light
          ? AppColors.blueLight()
          : AppColors.blueDark();
    }
  }

  // ── Derived helpers ───────────────────────────────────────────────────────

  Color primaryWithAlpha(double alpha) => primary.withValues(alpha: alpha);
  Color primaryDeepWithAlpha(double alpha) =>
      primaryDeep.withValues(alpha: alpha);
  Color primaryMidWithAlpha(double alpha) =>
      primaryMid.withValues(alpha: alpha);
  Color cardBorderWithAlpha(double alpha) =>
      cardBorder.withValues(alpha: alpha);

  // ── TextTheme ─────────────────────────────────────────────────────────────

  /// Anton  → display* + headline*  (impacto máximo, títulos y KPIs)
  /// Barlow Condensed → title* + body* + label*  (legible, compacto, deportivo)
  TextTheme buildTextTheme() {
    // Colores base para cada nivel
    final primary   = TextStyle(color: textPrimary);
    final secondary = TextStyle(color: textSecondary);
    final hint      = TextStyle(color: textHint);

    // Barlow Condensed como base de todo el árbol
    final base = GoogleFonts.barlowCondensedTextTheme(
      TextTheme(
        displayLarge:   primary,
        displayMedium:  primary,
        displaySmall:   primary,
        headlineLarge:  primary,
        headlineMedium: primary,
        headlineSmall:  primary,
        titleLarge:     primary,
        titleMedium:    primary,
        titleSmall:     secondary,
        bodyLarge:      primary,
        bodyMedium:     primary,
        bodySmall:      secondary,
        labelLarge:     primary,
        labelMedium:    secondary,
        labelSmall:     hint,
      ),
    );

    // Anton sobreescribe los niveles de display y headline
    return base.copyWith(
      displayLarge:   GoogleFonts.anton(textStyle: base.displayLarge?.copyWith(fontSize: 57, letterSpacing: 1.5)),
      displayMedium:  GoogleFonts.anton(textStyle: base.displayMedium?.copyWith(fontSize: 45, letterSpacing: 1.2)),
      displaySmall:   GoogleFonts.anton(textStyle: base.displaySmall?.copyWith(fontSize: 36, letterSpacing: 1.0)),
      headlineLarge:  GoogleFonts.anton(textStyle: base.headlineLarge?.copyWith(fontSize: 32, letterSpacing: 0.8)),
      headlineMedium: GoogleFonts.anton(textStyle: base.headlineMedium?.copyWith(fontSize: 28, letterSpacing: 0.6)),
      headlineSmall:  GoogleFonts.anton(textStyle: base.headlineSmall?.copyWith(fontSize: 24, letterSpacing: 0.4)),
    );
  }

  /// MaterialApp ThemeData para este token set
  ThemeData toMaterialTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryDeep,
        onPrimary: isDark ? Colors.black : Colors.white,
        secondary: primaryMid,
        onSecondary: Colors.black,
        error: const Color(0xFFFF3B30),
        onError: Colors.white,
        surface: card,
        onSurface: textPrimary,
      ),
      scaffoldBackgroundColor: bg,
      cardColor: card,
      dividerColor: cardBorderWithAlpha(0.15),
      textTheme: buildTextTheme(),
    );
  }
}
