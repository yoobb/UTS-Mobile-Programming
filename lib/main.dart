// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // BARU

// Import ViewModel
import 'view_models/auth_view_model.dart';
import 'view_models/cart_view_model.dart';
import 'view_models/history_view_model.dart';

// Import View
import 'views/screens/first_view.dart'; // Ganti dari 'screens/first.dart'

void main() {
  // Inisialisasi MultiProvider untuk menyediakan semua ViewModel ke seluruh app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()),
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
      ],
      child: const BakeryApp(),
    ),
  );
}


const Color COLOR_DARK_PRIMARY = Color(0xFF0D1B2A);
const Color COLOR_SECONDARY_ACCENT = Color(0xFF778DA9);


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
          backgroundColor: COLOR_DARK_PRIMARY,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: COLOR_SECONDARY_ACCENT,
            foregroundColor: Colors.white,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      // MENGGANTI ke nama View yang baru dan menghapus 'const' pada instance widget.
      home: const FirstView(),
    );
  }
}