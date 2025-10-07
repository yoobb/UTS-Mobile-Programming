// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:untitled2/main.dart';

void main() {
  // Ganti nama tes agar sesuai dengan alur aplikasi baru
  testWidgets('Start with login page and check for Nama Pembeli field', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BakeryApp()); // Menggunakan nama kelas aplikasi yang benar

    // Verifikasi bahwa aplikasi dimulai di halaman login (FirstPage)
    expect(find.text('Nama Pembeli'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);

    // Verifikasi bahwa elemen dari aplikasi Counter yang lama tidak ada
    expect(find.byIcon(Icons.add), findsNothing);
  });
}