import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';

void main() {
  runApp(const PowerShareApp());
}

class PowerShareApp extends StatelessWidget {
  const PowerShareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PowerShare SL',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A56DB),
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}