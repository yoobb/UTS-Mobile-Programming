import 'package:flutter/material.dart';
import 'screens/first.dart';

void main() {
  runApp(const BakeryApp());
}

// Definisikan Custom Colors dan Swatch berdasarkan palet
const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);

// Buat MaterialColor swatch minimal
const MaterialColor customSwatch = MaterialColor(
  0xFF0D1B2A,
  <int, Color>{
    50: Color(0xFFE1E5EB),
    100: Color(0xFFB5BDC5),
    500: Color(0xFF0D1B2A),
    700: Color(0xFF0B1724),
    900: Color(0xFF081017),
  },
);

class BakeryApp extends StatelessWidget {
  const BakeryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pemesanan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: customSwatch,
        scaffoldBackgroundColor: Colors.white,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: COLOR_DARK_PRIMARY, fontSize: 16),
          titleLarge: TextStyle(color: COLOR_DARK_PRIMARY, fontWeight: FontWeight.bold),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: COLOR_DARK_PRIMARY, // Dark Primary
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: COLOR_SECONDARY_ACCENT, // Secondary Accent
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            textStyle: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const FirstPage(),
    );
  }
}