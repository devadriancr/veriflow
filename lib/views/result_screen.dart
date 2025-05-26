import 'package:flutter/material.dart';
import 'package:veriflow/controllers/record_controller.dart';
import 'package:veriflow/services/api_service.dart';
import 'package:veriflow/services/lock_service.dart';

class ResultScreen extends StatefulWidget {
  final bool isValid;

  const ResultScreen({super.key, required this.isValid});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _showCodeInput = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isValid) {
      LockService.lockApp();
      _showCodeInput = true;
    }
  }

  void _validateCode() async {
    if (_codeController.text == '9876') {
      await LockService.unlockApp();

      final record = await RecordController.getLastNGRecord();
      if (record != null && record.recordId != null) {
        await ApiService.sendAuthData(
          record.recordId!,
          DateTime.now().toIso8601String(),
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Código incorrecto', style: TextStyle(color: Colors.red)),
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(bottom: 30, left: 20, right: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.red, width: 1),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isValid && _showCodeInput) {
      return _buildLockScreen();
    }

    return _buildResultScreen();
  }

  Widget _buildResultScreen() {
    final color = widget.isValid ? Colors.blue[900]! : Colors.red[900]!;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: color,
        body: Stack(
          children: [
            Center(
              child: Text(
                widget.isValid ? 'OK' : 'NG',
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
            if (widget.isValid)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(0xE6),
                    foregroundColor: color,
                    fixedSize: const Size.fromHeight(48),
                    minimumSize: const Size(double.infinity, 48),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  icon: Icon(Icons.arrow_back, color: color),
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
      ),
    );
  }

  Widget _buildLockScreen() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.red[900],
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'NG',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 200,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _codeController,
                  style: const TextStyle(color: Colors.red),
                  decoration: InputDecoration(
                    hintText: 'Código',
                    hintStyle: const TextStyle(color: Colors.red),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _validateCode(), // Aquí la magia
                ),
                // Eliminamos el botón y su SizedBox
              ],
            ),
          ),
        ),
      ),
    );
  }
}
