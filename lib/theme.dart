import 'package:flutter/material.dart';

class AppTheme {
  // Colors from the screenshots
  static const Color navyDark = Color(0xFF0D1B2A); // deepest background
  static const Color navyMid = Color(0xFF1A2B3C); // card background
  static const Color navyLight = Color(0xFF243447); // elevated surfaces
  static const Color accent = Color(0xFFFFB800); // yellow/gold — stars, buttons
  static const Color accentOrange = Color(
    0xFFFF8C00,
  ); // "Rate this service" button
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAABBCC);
  static const Color chipBg = Color(0xFF1E3048);
  static const Color chipSelected = Color(0xFF2A4A6B);

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: navyDark,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: accentOrange,
          surface: navyMid,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: navyDark,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: navyMid,
          selectedItemColor: accent,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: navyMid,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: navyLight,
          hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: chipBg,
          selectedColor: chipSelected,
          labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
          side: BorderSide.none,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentOrange,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle:
                const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      );
}

// Categories list — shared across the app
const List<String> kCategories = [
  'All',
  'Café',
  'Hospital',
  'Pharmacy',
  'Police Station',
  'Library',
  'Restaurant',
  'Park',
  'Tourist Attraction',
  'Utility Office',
];

// Category icons map
const Map<String, IconData> kCategoryIcons = {
  'All': Icons.apps,
  'Café': Icons.coffee,
  'Hospital': Icons.local_hospital,
  'Pharmacy': Icons.medication,
  'Police Station': Icons.local_police,
  'Library': Icons.menu_book,
  'Restaurant': Icons.restaurant,
  'Park': Icons.park,
  'Tourist Attraction': Icons.photo_camera,
  'Utility Office': Icons.business,
};
