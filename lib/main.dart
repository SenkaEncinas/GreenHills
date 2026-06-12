import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ESP32 Control',
      theme: ThemeData(primarySwatch: Colors.indigo, useMaterial3: true),
      home: const HomeScreen(), // Llamada a tu pantalla principal
    );
  }
}
