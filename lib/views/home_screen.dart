import 'package:flutter/material.dart';
import 'package:veriflow/controllers/record_controller.dart';
import 'package:veriflow/views/records_screen.dart';
import 'package:veriflow/views/result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _containerController = TextEditingController();
  final TextEditingController _visualAidController = TextEditingController();
  final TextEditingController _finalLabelController = TextEditingController();

  final FocusNode _containerFocus = FocusNode();
  final FocusNode _visualAidFocus = FocusNode();
  final FocusNode _finalLabelFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _containerFocus.requestFocus();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  void _resetForm() {
    _containerController.clear();
    _visualAidController.clear();
    _finalLabelController.clear();
    _containerFocus.requestFocus();
  }

  Future<void> _validateAndNavigate() async {
    if (!_containerController.text.startsWith('C-')) {
      _showErrorDialog('Contenedor',
          'Revisa que el código se haya escaneado correctamente.');
      return;
    }

    if (!_visualAidController.text.startsWith('V-')) {
      _showErrorDialog('Ayuda Visual',
          'Revisa que el código se haya escaneado correctamente.');
      return;
    }

    final isValid = await RecordController.validateAndSave(
      _containerController.text,
      _visualAidController.text,
      _finalLabelController.text,
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(isValid: isValid),
      ),
    ).then((_) => _resetForm());
  }

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VERIFLOW',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecordsScreen()),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _containerController,
                  focusNode: _containerFocus,
                  decoration: const InputDecoration(
                    labelText: 'Contenedor',
                    hintText: 'C-XXXXX',
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _fieldFocusChange(
                      context, _containerFocus, _visualAidFocus),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _visualAidController,
                  focusNode: _visualAidFocus,
                  decoration: const InputDecoration(
                    labelText: 'Ayuda Visual',
                    hintText: 'V-XXXXX',
                  ),
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _fieldFocusChange(
                      context, _visualAidFocus, _finalLabelFocus),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _finalLabelController,
                  focusNode: _finalLabelFocus,
                  decoration: const InputDecoration(
                    labelText: 'Etiqueta Final',
                    hintText: 'XXXXX',
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _validateAndNavigate(),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _validateAndNavigate,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue[900],
              ),
              child: const Text('VALIDAR',
                  style: TextStyle(
                      fontSize: 16, color: Colors.white, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }
}
