import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// 🎨 SMARTCART425 THEME - MATCHES WEBSITE DESIGN
// ---------------------------------------------------------------------------

class AppTheme {
  // Colors from website
  static const Color darkBg = Color(0xFF020617); // slate-950
  static const Color darkCard = Color(0xFF0f172a); // slate-900
  static const Color darkCardHover = Color(0xFF1e293b); // slate-800
  static const Color darkSurface = Color(0xFF0f172a);
  static const Color darkBorder = Color(0x1AFFFFFF); // white/10 opacity

  // Light Theme Colors
  static const Color lightBg = Color(0xFFf8fafc); // slate-50
  static const Color lightCard = Color(0xFFffffff); // white
  static const Color lightCardHover = Color(0xFFf1f5f9); // slate-100
  static const Color lightSurface = Color(0xFFffffff);
  static const Color lightBorder = Color(0xFFe2e8f0); // slate-200

  // Primary - Emerald/Green
  static const Color primaryLight = Color(0xFF34d399); // emerald-400
  static const Color primary = Color(0xFF10b981); // emerald-500
  static const Color primaryDark = Color(0xFF059669); // emerald-600

  // Accent colors
  static const Color accentBlue = Color(0xFF3b82f6); // blue-500
  static const Color accentPurple = Color(0xFFa855f7); // purple-500
  static const Color accentOrange = Color(0xFFf97316); // orange-500
  static const Color accentRed = Color(0xFFef4444); // red-500

  // Text colors
  static const Color textPrimary = Color(0xFFffffff); // white
  static const Color textSecondary = Color(0xFFcbd5e1); // slate-300
  static const Color textTertiary = Color(0xFF94a3b8); // slate-400
  static const Color textMuted = Color(0xFF64748b); // slate-500

  // Status colors
  static const Color statusSuccess = Color(0xFF10b981); // emerald-500
  static const Color statusWarning = Color(0xFFf97316); // orange-500
  static const Color statusError = Color(0xFFef4444); // red-500
  static const Color statusInfo = Color(0xFF3b82f6); // blue-500

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: primary,
        onPrimary: textPrimary,
        primaryContainer: primaryDark,
        onPrimaryContainer: primaryLight,
        secondary: accentBlue,
        onSecondary: textPrimary,
        surface: darkCard,
        onSurface: textPrimary,
        surfaceContainer: darkCardHover,
        onSurfaceVariant: textTertiary,
        outline: textMuted,
        error: statusError,
        onError: textPrimary,
      ),

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textSecondary),
        actionsIconTheme: IconThemeData(color: textSecondary),
      ),

      // Card Theme (Expressive: Increased radius)
      cardTheme: CardThemeData(
        color: darkCard,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: darkBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Button Themes (Expressive: Stadium boders / Pills)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          elevation: 4,
          shadowColor: primary.withValues(alpha: 0.4),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: darkBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Floating Action Button Theme (Expressive)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: textPrimary,
        elevation: 4,
        focusElevation: 8,
        hoverElevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Navigation Bar Theme (M3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkBg,
        indicatorColor: primary.withValues(alpha: 0.2),
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
             return const IconThemeData(color: primary, size: 26);
          }
          return const IconThemeData(color: textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12);
          }
          return const TextStyle(color: textSecondary, fontWeight: FontWeight.w500, fontSize: 12);
        }),
      ),

      // Input Decoration Theme (Expressive: More rounded)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: darkBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusError, width: 2),
        ),
        hintStyle: const TextStyle(color: textMuted),
        labelStyle: const TextStyle(color: textSecondary),
        prefixIconColor: textTertiary,
        suffixIconColor: textTertiary,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: darkCard,
        selectedColor: primary,
        disabledColor: darkCardHover,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
        side: const BorderSide(color: darkBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: darkCard,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textPrimary),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalBackgroundColor: darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkCardHover,
        contentTextStyle: const TextStyle(color: textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
        actionTextColor: primary,
      ),

      // Popup Menu Theme
      popupMenuTheme: PopupMenuThemeData(
        color: darkCard,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.transparent,
      ),

      // List Tile Theme
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        textColor: textPrimary,
        iconColor: textSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        subtitleTextStyle: TextStyle(fontSize: 14, color: textTertiary),
      ),

      // Drawer Theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkBg,
        scrimColor: Color(0x99000000),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
      ),

      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textTertiary,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),

      // Icon Theme
      iconTheme: const IconThemeData(color: textSecondary, size: 24),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: darkCardHover,
      ),

      dividerTheme: const DividerThemeData(
        color: darkBorder,
        thickness: 1,
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: primary,
        onPrimary: Colors.white,
        primaryContainer: primaryLight,
        onPrimaryContainer: Colors.white,
        secondary: accentBlue,
        onSecondary: Colors.white,
        surface: lightCard,
        onSurface: Colors.black, // Dark text on light surface
        surfaceContainer: lightCardHover,
        onSurfaceVariant: textMuted,
        outline: textTertiary,
        error: statusError,
        onError: Colors.white,
      ),

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
        },
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: -0.5,
        ),
        iconTheme: IconThemeData(color: textMuted),
        actionsIconTheme: IconThemeData(color: textMuted),
      ),

      // Card Theme (Expressive)
      cardTheme: CardThemeData(
        color: lightCard,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),

      // Button Themes (Expressive)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.2),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: const BorderSide(color: lightBorder, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 2,
        focusElevation: 4,
        hoverElevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Navigation Bar Match
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightBg,
        indicatorColor: primary.withValues(alpha: 0.1),
        elevation: 0,
        height: 80,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
             return const IconThemeData(color: primary, size: 26);
          }
          return const IconThemeData(color: textMuted, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12);
          }
          return const TextStyle(color: textMuted, fontWeight: FontWeight.w500, fontSize: 12);
        }),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lightBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: statusError, width: 2),
        ),
        hintStyle: const TextStyle(color: textTertiary),
        labelStyle: const TextStyle(color: textMuted),
        prefixIconColor: textTertiary,
        suffixIconColor: textTertiary,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: lightCard,
        selectedColor: primary,
        disabledColor: lightCardHover,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        side: const BorderSide(color: lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: lightCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        surfaceTintColor: Colors.transparent,
        titleTextStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightCard,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        modalBackgroundColor: lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.black87,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
        actionTextColor: primaryLight,
      ),

      // Popup Menu
      popupMenuTheme: PopupMenuThemeData(
        color: lightCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        surfaceTintColor: Colors.transparent,
      ),

      // List Tile
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        textColor: Colors.black,
        iconColor: textMuted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        subtitleTextStyle: TextStyle(fontSize: 14, color: textMuted),
      ),

      // Drawer
      drawerTheme: const DrawerThemeData(
        backgroundColor: lightBg,
        scrimColor: Color(0x50000000),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
        ),
      ),

      // Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textMuted,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),

      // Icon
      iconTheme: const IconThemeData(color: textMuted, size: 24),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: -1.0,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textMuted,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textMuted,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textTertiary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textMuted,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        circularTrackColor: lightCardHover,
      ),

      dividerTheme: const DividerThemeData(
        color: lightBorder,
        thickness: 1,
      ),
    );
  }

  // Helper method for glass effect
  static BoxDecoration glassEffect({
    double blur = 12,
    Color borderColor = darkBorder,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: darkCard.withValues(alpha: 0.6),
      borderRadius: borderRadius ?? BorderRadius.circular(24),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: blur,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Helper for elevation shadow
  static List<BoxShadow> elevationShadow({int elevation = 2}) {
    final opacity = (elevation / 10).clamp(0.1, 0.3);
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: opacity),
        blurRadius: elevation * 2.0,
        offset: Offset(0, elevation.toDouble()),
      ),
    ];
  }
}
