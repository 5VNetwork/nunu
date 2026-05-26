import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Dark mode – arctic night ────────────────────────────────────────────────
const _deepArctic = Color(0xFF071018);
const _arcticNight = Color(0xFF0C1A2E);
const _glacierDeep = Color(0xFF132238);
const _glacierMid = Color(0xFF1A3050);
const _glacierLight = Color(0xFF243B5C);
const _frostBlue = Color(0xFF7DD3FC);
const _iceGlow = Color(0xFF38BDF8);
const _snowWhite = Color(0xFFE8F4FC);
const _frostMuted = Color(0xFF94B8D4);
const _iceEdge = Color(0xFF3D5A78);
const _iceEdgeLight = Color(0xFF5A7FA0);
const _darkGradientEnd = Color(0xFF0F2540);

// ── Light mode – snow & ice ─────────────────────────────────────────────────
const _pureSnow = Color(0xFFFFFFFF);
const _snowField = Color(0xFFF8FCFF);
const _frostMist = Color(0xFFF0F7FF);
const _iceMist = Color(0xFFE8F4FC);
const _icePanel = Color(0xFFD6EBFA);
const _skyIce = Color(0xFF0EA5E9);
const _glacierBlue = Color(0xFF0284C7);
const _inkBlue = Color(0xFF0F2942);
const _slateIce = Color(0xFF5B7A94);
const _frozenGray = Color(0xFFC5D9E8);
const _iceBorder = Color(0xFFB8D4E8);
const _iceBorderAccent = Color(0xFF7BA3C0);
const _lightGradientEnd = Color(0xFFE0F2FE);

TextTheme? getTextTheme(Locale? locale, {bool isDark = false}) {
  if (locale?.languageCode == 'zh' &&
      (Platform.isWindows || Platform.isLinux)) {
    return GoogleFonts.notoSansScTextTheme(
      ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
      ).textTheme,
    );
  }
  return null;
}

extension AppColors on ColorScheme {
  bool get _isDark => brightness == Brightness.dark;

  Color get bgColor => _isDark ? _arcticNight : _snowField;

  Color get bgSecondary => surface;

  Color get bgGradientEnd => _isDark ? _darkGradientEnd : _lightGradientEnd;

  Color get inactiveColor => _isDark ? _glacierLight : _frozenGray;

  Color get borderColor => _isDark ? _iceEdgeLight : _iceBorderAccent;
  Color get sidebarColor =>
      _isDark ? _frostBlue.withValues(alpha: 0.35) : _skyIce.withValues(alpha: 0.20);
  Color get backgroundStartColor => _isDark ? _snowWhite : _pureSnow;
  Color get backgroundEndColor => _isDark ? _frostBlue : _skyIce;

  Color get surfaceOverlay => onSurface.withValues(alpha: _isDark ? 0.05 : 0.04);
  Color get surfaceOverlayLight =>
      onSurface.withValues(alpha: _isDark ? 0.08 : 0.06);
  Color get surfaceOverlayLighter =>
      onSurface.withValues(alpha: _isDark ? 0.10 : 0.08);

  Color get borderLight => onSurface.withValues(alpha: _isDark ? 0.12 : 0.10);
  Color get borderMedium => onSurface.withValues(alpha: _isDark ? 0.22 : 0.16);

  Color get shadowDark => _isDark
      ? const Color(0xFF020810).withValues(alpha: 0.65)
      : const Color(0xFF0C2D48).withValues(alpha: 0.12);

  Color get shadowLight => _isDark
      ? const Color(0xFF1A3A5C).withValues(alpha: 0.40)
      : const Color(0xFF7DD3FC).withValues(alpha: 0.25);

  Color get iceGlow => primary.withValues(alpha: _isDark ? 0.45 : 0.35);
}

ThemeData lightTheme(Locale? locale) {
  final colorScheme = ColorScheme.light(
    brightness: Brightness.light,
    primary: _skyIce,
    onPrimary: _pureSnow,
    primaryContainer: _iceMist,
    onPrimaryContainer: _glacierBlue,
    secondary: _glacierBlue,
    onSecondary: _pureSnow,
    secondaryContainer: const Color(0xFFBAE6FD),
    onSecondaryContainer: const Color(0xFF075985),
    tertiary: const Color(0xFF38BDF8),
    onTertiary: _pureSnow,
    surface: _pureSnow,
    onSurface: _inkBlue,
    onSurfaceVariant: _slateIce,
    surfaceContainerLowest: _pureSnow,
    surfaceContainerLow: _snowField,
    surfaceContainer: _frostMist,
    surfaceContainerHigh: _iceMist,
    surfaceContainerHighest: _icePanel,
    outline: _iceBorder,
    outlineVariant: const Color(0xFFD6EBFA),
    shadow: const Color(0xFF0C2D48),
    error: const Color(0xFFDC2626),
    onError: _pureSnow,
  );

  return _buildNunuTheme(
    colorScheme: colorScheme,
    locale: locale,
    isDark: false,
    defaultTextColor: _inkBlue,
    buttonLabelColor: _pureSnow,
  );
}

ThemeData darkTheme(Locale? locale) {
  final colorScheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: _frostBlue,
    onPrimary: _deepArctic,
    primaryContainer: const Color(0xFF1A3D5C),
    onPrimaryContainer: _frostBlue,
    secondary: _iceGlow,
    onSecondary: _deepArctic,
    secondaryContainer: const Color(0xFF153050),
    onSecondaryContainer: _frostBlue,
    tertiary: const Color(0xFFBAE6FD),
    onTertiary: _deepArctic,
    surface: _glacierDeep,
    onSurface: _snowWhite,
    onSurfaceVariant: _frostMuted,
    surfaceContainerLowest: _deepArctic,
    surfaceContainerLow: _arcticNight,
    surfaceContainer: _glacierDeep,
    surfaceContainerHigh: _glacierMid,
    surfaceContainerHighest: const Color(0xFF1E3554),
    outline: _iceEdge,
    outlineVariant: const Color(0xFF2A4560),
    shadow: Colors.black,
    error: const Color(0xFFFF6B6B),
    onError: _snowWhite,
  );

  return _buildNunuTheme(
    colorScheme: colorScheme,
    locale: locale,
    isDark: true,
    defaultTextColor: _snowWhite,
    buttonLabelColor: _deepArctic,
  );
}

ThemeData _buildNunuTheme({
  required ColorScheme colorScheme,
  required Locale? locale,
  required bool isDark,
  required Color defaultTextColor,
  required Color buttonLabelColor,
}) {
  final textTheme = getTextTheme(locale, isDark: isDark);
  final baseTextTheme = textTheme ??
      (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.copyWith(
            bodyLarge: TextStyle(color: defaultTextColor),
            bodyMedium: TextStyle(color: defaultTextColor),
            bodySmall: TextStyle(
              color: defaultTextColor.withValues(alpha: 0.87),
            ),
            titleLarge: TextStyle(color: defaultTextColor),
            titleMedium: TextStyle(color: defaultTextColor),
            titleSmall: TextStyle(color: defaultTextColor),
            labelLarge: TextStyle(
              color: buttonLabelColor,
              fontWeight: FontWeight.w700,
            ),
          );

  return ThemeData(
    useMaterial3: true,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: colorScheme,
    textTheme: baseTextTheme,
    scaffoldBackgroundColor: colorScheme.bgColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle:
          isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      iconTheme: IconThemeData(
        color: colorScheme.onSurface.withValues(alpha: 0.87),
      ),
      titleTextStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surfaceContainerHigh,
      elevation: isDark ? 0 : 0,
      shadowColor: colorScheme.shadow.withValues(alpha: isDark ? 0 : 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.borderLight),
      ),
    ),
    navigationDrawerTheme: NavigationDrawerThemeData(
      backgroundColor: colorScheme.surfaceContainer,
      indicatorColor: colorScheme.primary.withValues(alpha: 0.18),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(color: colorScheme.onSurface);
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: isDark ? 0 : 1,
        shadowColor: colorScheme.iceGlow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      filled: true,
      fillColor: colorScheme.surfaceOverlay,
      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: colorScheme.borderMedium,
      thickness: 1,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary;
        }
        return colorScheme.onSurfaceVariant;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return colorScheme.primary.withValues(alpha: 0.35);
        }
        return colorScheme.surfaceContainerHighest;
      }),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      dragHandleColor: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surfaceContainerHigh,
      elevation: isDark ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.borderLight),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: colorScheme.surfaceContainerHighest,
      contentTextStyle: TextStyle(color: colorScheme.onSurface),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: colorScheme.primary,
      linearTrackColor: colorScheme.primary.withValues(alpha: 0.15),
    ),
    iconTheme: IconThemeData(
      color: colorScheme.onSurface.withValues(alpha: 0.87),
    ),
  );
}
