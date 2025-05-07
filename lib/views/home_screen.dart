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
    FocusScope.of(context).requestFocus(next);
  }

  void _resetForm() {
    _containerController.clear();
    _visualAidController.clear();
    _finalLabelController.clear();
    FocusScope.of(context).requestFocus(_containerFocus);
  }

  Future<void> _validateAndNavigate() async {
    if (_containerController.text.isEmpty) {
      _showErrorDialog('Contenedor', 'Este campo no puede estar vacío.');
      return;
    }

    if (_visualAidController.text.isEmpty) {
      _showErrorDialog('Ayuda Visual', 'Este campo no puede estar vacío.');
      return;
    }

    if (_finalLabelController.text.isEmpty) {
      _showErrorDialog('Etiqueta Final', 'Este campo no puede estar vacío.');
      return;
    }

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

    if (_finalLabelController.text.contains('C-') ||
        _finalLabelController.text.contains('V-')) {
      _showErrorDialog(
          'Etiqueta Final', 'Revisa que se haya escaneado la etiqueta final.');
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1.5,
            )),
        centerTitle: true,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildInputField(
                      controller: _containerController,
                      focusNode: _containerFocus,
                      label: 'Contenedor',
                      hint: 'C-XXXXX',
                      icon: Icons.local_shipping,
                      nextFocus: _visualAidFocus,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _visualAidController,
                      focusNode: _visualAidFocus,
                      label: 'Ayuda Visual',
                      hint: 'V-XXXXX',
                      icon: Icons.article,
                      nextFocus: _finalLabelFocus,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _finalLabelController,
                      focusNode: _finalLabelFocus,
                      label: 'Etiqueta Final',
                      hint: 'XXXXX',
                      icon: Icons.local_offer,
                      isLast: true,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildValidateButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    FocusNode? nextFocus,
    bool isLast = false,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[900]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[400]!), // Borde visible
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue[900]!, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      ),
      style: TextStyle(color: Colors.grey[800], fontSize: 16),
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onSubmitted: (_) {
        if (isLast) {
          _validateAndNavigate();
        } else {
          _fieldFocusChange(context, focusNode, nextFocus!);
        }
      },
    );
  }

  Widget _buildValidateButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8, left: 8, right: 8),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _validateAndNavigate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[900],
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 3,
            shadowColor: Colors.blue[900]!.withOpacity(0.3),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'VALIDAR',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
