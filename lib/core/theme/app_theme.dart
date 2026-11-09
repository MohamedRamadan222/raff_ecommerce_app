import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    background: AppColors.paper,
    surface: AppColors.surface,
    text: AppColors.ink,
    secondaryText: AppColors.inkSecondary,
    muted: AppColors.muted,
    primary: AppColors.accent,
    onPrimary: AppColors.onInk,
    accentSoft: AppColors.accentSoft,
    border: AppColors.line,
    borderStrong: AppColors.lineStrong,
    error: AppColors.danger,
  );

  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    background: AppColors.darkPaper,
    surface: AppColors.darkSurface,
    text: AppColors.darkInk,
    secondaryText: AppColors.darkInkSecondary,
    muted: AppColors.darkMuted,
    primary: AppColors.darkAccent,
    onPrimary: AppColors.darkOnInk,
    accentSoft: AppColors.darkAccentSoft,
    border: AppColors.darkLine,
    borderStrong: AppColors.darkLineStrong,
    error: AppColors.darkDanger,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color text,
    required Color secondaryText,
    required Color muted,
    required Color primary,
    required Color onPrimary,
    required Color accentSoft,
    required Color border,
    required Color borderStrong,
    required Color error,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: accentSoft,
      onSecondary: text,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: text,
      outline: borderStrong,
      outlineVariant: border,
      shadow: Colors.black,
      scrim: Colors.black54,
      inverseSurface: text,
      onInverseSurface: background,
      inversePrimary: AppColors.accent,
      surfaceTint: primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      fontFamily: AppTextStyles.fontFamily,

      appBarTheme: AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: background,
        foregroundColor: text,
        surfaceTintColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: AppTextStyles.button,
        ),
      ),

      dividerTheme: DividerThemeData(color: border, thickness: 1),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: AppTextStyles.description.copyWith(color: muted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
      ),

      textTheme: TextTheme(
        headlineLarge: AppTextStyles.wordmark.copyWith(color: text),
        headlineMedium: AppTextStyles.appBarTitle.copyWith(color: text),
        titleMedium: AppTextStyles.bodyBold.copyWith(color: text),
        bodyMedium: AppTextStyles.description.copyWith(color: secondaryText),
        labelLarge: AppTextStyles.button.copyWith(color: onPrimary),
        labelMedium: AppTextStyles.sectionLabel.copyWith(color: text),
        labelSmall: AppTextStyles.badge.copyWith(color: text),
      ),
    );
  }
}
