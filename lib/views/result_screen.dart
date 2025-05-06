import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool isValid;

  const ResultScreen({super.key, required this.isValid});

  @override
  Widget build(BuildContext context) {
    final color = isValid ? Colors.blue[900]! : Colors.red[900]!;

    return Scaffold(
      backgroundColor: color,
      body: Stack(
        children: [
          Center(
            child: Text(
              isValid ? 'OK' : 'NG',
              style: TextStyle(
                fontSize: 200,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: color.withAlpha(0x4D),
                    blurRadius: 10,
                    offset: const Offset(2, 2),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12, // Margen izquierdo
            right: 12, // Margen derecho
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withAlpha(0xE6),
                foregroundColor: color,
                fixedSize: const Size.fromHeight(48), // Altura fija
                minimumSize: const Size(double.infinity, 48), // Ancho completo
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              label: const Text(
                'REGRESAR',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
