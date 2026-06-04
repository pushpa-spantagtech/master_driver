import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
    fontFamily: 'SFProText',
    primaryColor: const Color(0xFFFFFFFF),
    disabledColor: const Color(0xFFBABFC4),
    primaryColorDark: const Color(0xff007B6C),
    brightness: Brightness.light,
    hintColor: const Color(0xFF9F9F9F),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFAAD02),
      surface: Color(0xFFF8F9FA),
      secondary: Color(0xB2141414),
      onPrimary: Color(0xFF141414),
      onSecondary: Color(0xFF585959),
      secondaryContainer: Color(0x1A141414),
      onSecondaryContainer: Color(0x1A000000),
      tertiary: Color(0x5C141414),
      onTertiaryContainer: Color.fromRGBO(20, 20, 20, 0.5),
      error: Color(0xB2FF0000),
      onSurface: Color(0x99141414),
      outline: Color(0xFFFF8080),
      outlineVariant: Color(0x1A000000),
      onPrimaryContainer: Color(0x33141414),
      tertiaryContainer: Color(0x21FF0000),
      primaryContainer: Color(0xFFFFEFCB),
      onErrorContainer: Color(0xFFFFF3D8),
      shadow: Color(0x40000000),
      surfaceTint: Color(0xFF0B9722),
      errorContainer: Color(0xFFF6F6F6),
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF00A08D))),
    textTheme: const TextTheme(
      displayLarge:
          TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF202020)),
      displayMedium:
          TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF393939)),
      displaySmall:
          TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF282828)),
      bodyLarge:
          TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF272727)),
      bodyMedium:
          TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF334257)),
      bodySmall:
          TextStyle(fontWeight: FontWeight.w300, color: Color(0xFF1D2D2B)),
      headlineLarge: TextStyle(color: Color(0xB2141414)),
    ));
