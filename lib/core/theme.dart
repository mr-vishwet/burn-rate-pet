import 'package:material_ui/material_ui.dart';
import 'package:google_fonts/google_fonts.dart';

/// Momo theme — the V7 animated-essence palette.
///
/// Night-sky cocoa + stars, deep cocoa gradients, glassmorphic cards,
/// coral → peach gradient CTAs. One theme in phase 1 (the V7 palette);
/// the structure is ready for the phase-2 dark/light swap — [AppTheme]
/// will gain a second [ThemeData] getter and the app shell a mode toggle,
/// with the palette constants below split per brightness.
class AppTheme {
  AppTheme._();

  // Cocoa background ramp (dark first — the V7 screens were designed dark).
  /// Deepest cocoa — the top of the background gradient.
  static const Color cocoa900 = Color(0xFF2B2118);

  /// Mid cocoa — card surfaces and the middle of the background gradient.
  static const Color cocoa800 = Color(0xFF3B2A20);

  /// Lighter cocoa — the bottom of the background gradient.
  static const Color cocoa700 = Color(0xFF4A3428);

  /// Lightest cocoa — raised surfaces.
  static const Color cocoa600 = Color(0xFF5C4233);

  // Ink + text.
  /// Primary text (white).
  static const Color ink = Color(0xFFFFFFFF);

  /// Secondary text — soft peach.
  static const Color peachSoft = Color(0xFFFFD9C7);

  /// Muted text.
  static const Color taupe = Color(0xFFD8A48F);

  /// Text on light chips.
  static const Color cocoaInk = Color(0xFF2B2118);

  // Accents.
  /// CTA gradient start.
  static const Color coral = Color(0xFFF26B4F);

  /// CTA gradient end.
  static const Color peach = Color(0xFFFFB59E);

  /// Momo's accent.
  static const Color orange = Color(0xFFF59E0B);

  /// Success / positive.
  static const Color green = Color(0xFF34D399);

  /// Warning / negative.
  static const Color rose = Color(0xFFFB7185);

  /// Highlight / streak.
  static const Color amber = Color(0xFFFB923C);

  // Glass.
  /// Glass card fill — white 8%.
  static const Color glass = Color(0x14FFFFFF);

  /// Stronger glass fill — white 12%.
  static const Color glassStrong = Color(0x1FFFFFFF);

  /// Hairline border — white 15%.
  static const Color hairline = Color(0x26FFFFFF);

  /// Strong hairline border — white 25%.
  static const Color hairlineStrong = Color(0x40FFFFFF);

  /// The coral → peach CTA gradient.
  static const LinearGradient ctaGradient = LinearGradient(
    colors: [coral, peach],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// The cocoa background gradient.
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [cocoa900, cocoa800, cocoa700],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// The single phase-1 theme (V7 palette).
  static ThemeData get theme {
    const scheme = ColorScheme.dark(
      primary: coral,
      onPrimary: cocoa900,
      secondary: peach,
      surface: cocoa800,
      onSurface: ink,
      error: rose,
    );
    final display = GoogleFonts.spaceGrotesk();
    final body = GoogleFonts.inter();
    final mono = GoogleFonts.jetBrainsMono();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: cocoa900,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: ink,
        elevation: 0,
        titleTextStyle: display.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
      ),
      cardTheme: CardThemeData(
        color: glass,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: hairline),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: coral,
          foregroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: body.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          side: const BorderSide(color: hairlineStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: glass,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: peach),
        ),
        hintStyle: body.copyWith(color: taupe),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? cocoa900
              : taupe,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? peach
              : cocoa600,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: cocoa800,
        indicatorColor: glassStrong,
        labelTextStyle: WidgetStatePropertyAll(
          body.copyWith(fontSize: 12, color: peachSoft),
        ),
      ),
      textTheme: TextTheme(
        displaySmall: display.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: ink,
          height: 1.1,
        ),
        titleLarge: display.copyWith(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleMedium: display.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleSmall: body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: peachSoft,
        ),
        bodyLarge: body.copyWith(fontSize: 16, color: ink),
        bodyMedium: body.copyWith(fontSize: 14, color: ink),
        bodySmall: body.copyWith(fontSize: 12, color: taupe),
        labelLarge: body.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        labelMedium: mono.copyWith(fontSize: 13, color: peachSoft),
        labelSmall: mono.copyWith(fontSize: 11, color: taupe),
      ),
    );
  }

  /// Mono style for numbers (index, amounts, formula lines).
  static TextStyle monoNumbers({
    double size = 14,
    FontWeight weight = FontWeight.w500,
    Color color = ink,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
  );
}
