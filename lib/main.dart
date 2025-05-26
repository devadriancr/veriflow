import 'package:flutter/material.dart';
import 'package:veriflow/views/home_screen.dart';
import 'package:veriflow/services/sync_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Iniciar el sincronizador periódico
    SyncManager().startPeriodicSync();

    return MaterialApp(
      title: 'VERIFLOW',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: 16)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D47A1),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
