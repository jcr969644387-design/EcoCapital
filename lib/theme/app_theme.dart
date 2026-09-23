import 'package:flutter/material.dart';

/// Colores semánticos para cifras financieras (crea o destruye valor).
@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  const FinanceColors({
    required this.positive,
    required this.positiveContainer,
    required this.negative,
    required this.negativeContainer,
    required this.warning,
    required this.warningContainer,
    required this.heroStart,
    required this.heroEnd,
  });

  final Color positive;
  final Color positiveContainer;
  final Color negative;
  final Color negativeContainer;
  final Color warning;
  final Color warningContainer;

  /// Degradado de las cabeceras destacadas.
  final Color heroStart;
  final Color heroEnd;

  static const FinanceColors light = FinanceColors(
    positive: Color(0xFF0E8A5F),
    positiveContainer: Color(0xFFD5F5E6),
    negative: Color(0xFFC62E3F),
    negativeContainer: Color(0xFFFCE0E3),
    warning: Color(0xFFB86E00),
    warningContainer: Color(0xFFFFEBCC),
    heroStart: Color(0xFF0B1F3A),
    heroEnd: Color(0xFF0E6B5C),
  );

  static const FinanceColors dark = FinanceColors(
    positive: Color(0xFF4FD6A0),
    positiveContainer: Color(0xFF0F3B2C),
    negative: Color(0xFFFF8A95),
    negativeContainer: Color(0xFF4A1820),
    warning: Color(0xFFFFC266),
    warningContainer: Color(0xFF4A3000),
    heroStart: Color(0xFF0A1830),
    heroEnd: Color(0xFF0B5347),
  );

  static FinanceColors of(BuildContext context) {
    return Theme.of(context).extension<FinanceColors>() ?? light;
  }

  /// Color según el signo de una cifra.
  Color forValue(double value) => value >= 0 ? positive : negative;

  @override
  FinanceColors copyWith({
    Color? positive,
    Color? positiveContainer,
    Color? negative,
    Color? negativeContainer,
    Color? warning,
    Color? warningContainer,
    Color? heroStart,
    Color? heroEnd,
  }) {
    return FinanceColors(
      positive: positive ?? this.positive,
      positiveContainer: positiveContainer ?? this.positiveContainer,
      negative: negative ?? this.negative,
      negativeContainer: negativeContainer ?? this.negativeContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
      heroStart: heroStart ?? this.heroStart,
      heroEnd: heroEnd ?? this.heroEnd,
    );
  }

  @override
  FinanceColors lerp(ThemeExtension<FinanceColors>? other, double t) {
    if (other is! FinanceColors) {
      return this;
    }
    return FinanceColors(
      positive: Color.lerp(positive, other.positive, t)!,
      positiveContainer:
          Color.lerp(positiveContainer, other.positiveContainer, t)!,
      negative: Color.lerp(negative, other.negative, t)!,
      negativeContainer:
          Color.lerp(negativeContainer, other.negativeContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer:
          Color.lerp(warningContainer, other.warningContainer, t)!,
      heroStart: Color.lerp(heroStart, other.heroStart, t)!,
      heroEnd: Color.lerp(heroEnd, other.heroEnd, t)!,
    );
  }
}

/// Tema visual de EcoCapital: azul marino institucional con acento
/// esmeralda, sobrio para el área de Economía y Finanzas.
class AppTheme {
  const AppTheme._();

  static const Color seed = Color(0xFF0E6B5C);
  static const double radius = 20;

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    ).copyWith(
      secondary: isDark ? const Color(0xFF9CB8E0) : const Color(0xFF1F3A63),
      tertiary: isDark ? const Color(0xFFF2C46B) : const Color(0xFF9A6A00),
    );
    final base = ThemeData(
      colorScheme: scheme,
      brightness: brightness,
      visualDensity: VisualDensity.standard,
    );
    final text = base.textTheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    );
    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,
      extensions: [isDark ? FinanceColors.dark : FinanceColors.light],
      textTheme: text.copyWith(
        headlineMedium: text.headlineMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        headlineSmall: text.headlineSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleLarge: text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: scheme.surface,
        surfaceTintColor: scheme.surfaceTint,
        titleTextStyle: text.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 12),
        color: scheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: shape,
          textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(shape: shape),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          minimumSize: const Size(0, 46),
          shape: shape,
          selectedBackgroundColor: scheme.primary,
          selectedForegroundColor: scheme.onPrimary,
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: text.labelLarge,
        selectedColor: scheme.primaryContainer,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        inactiveTrackColor: scheme.primary.withValues(alpha: 0.18),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: shape,
      ),
      listTileTheme: ListTileThemeData(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        shape: Border(),
        collapsedShape: Border(),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
        },
      ),
    );
  }
}
