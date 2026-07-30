import 'package:flutter/material.dart';

// Mengimpor halaman DashboardScreen yang sudah dipindah ke folder views
import 'views/dashboard_screen.dart';

void main() {
  runApp(const SakuSiswaApp());
}

class SakuSiswaApp extends StatelessWidget {
  const SakuSiswaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SakuSiswa',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ), // ThemeData
      home: const DashboardScreen(), // Memanggil layar utama dari dashboard_screen.dart
    ); // MaterialApp
  }
}