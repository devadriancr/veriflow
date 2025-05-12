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
    _finalLabelFocus.requestFocus();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode current, FocusNode next) {
    FocusScope.of(context).requestFocus(next);
  }

  void _resetForm() {
    _containerController.clear();
    _visualAidController.clear();
    _finalLabelController.clear();
    FocusScope.of(context).requestFocus(_finalLabelFocus);
  }

  Future<void> _validateAndNavigate() async {
    // 1. Validar campos vacíos
    if (_containerController.text.isEmpty ||
        _visualAidController.text.isEmpty ||
        _finalLabelController.text.isEmpty) {
      final savedStatus = await RecordController.validateAndSave(
        _containerController.text,
        _visualAidController.text,
        _finalLabelController.text,
      );
      _navigateToResult(savedStatus);
      return;
    }

    // 2. Validar formatos C- y V-
    final containerValid = _containerController.text.startsWith('C-');
    final visualAidValid = _visualAidController.text.startsWith('V-');

    if (!containerValid || !visualAidValid) {
      final savedStatus = await RecordController.validateAndSave(
        _containerController.text,
        _visualAidController.text,
        _finalLabelController.text,
      );
      _navigateToResult(savedStatus);
      return;
    }

    // 3. Extraer códigos base y validar coincidencia
    final containerBase = _containerController.text.substring(2);
    final visualAidBase = _visualAidController.text.substring(2);

    if (containerBase != visualAidBase) {
      final savedStatus = await RecordController.validateAndSave(
        _containerController.text,
        _visualAidController.text,
        _finalLabelController.text,
      );
      _navigateToResult(savedStatus);
      return;
    }

    // 4. Validar presencia en etiqueta final
    final isValid = _finalLabelController.text.contains(containerBase);

    // Guardar en BD y mostrar resultado
    final savedStatus = await RecordController.validateAndSave(
      _containerController.text,
      _visualAidController.text,
      _finalLabelController.text,
    );

    if (!mounted) return;
    _navigateToResult(savedStatus);
  }

  void _navigateToResult(bool isValid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(isValid: isValid),
      ),
    ).then((_) => _resetForm());
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
                      controller: _finalLabelController,
                      focusNode: _finalLabelFocus,
                      label: 'Etiqueta Final',
                      hint: 'XXXXX',
                      icon: Icons.local_offer,
                      nextFocus: _visualAidFocus,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _visualAidController,
                      focusNode: _visualAidFocus,
                      label: 'Ayuda Visual',
                      hint: 'V-XXXXX',
                      icon: Icons.article,
                      nextFocus: _containerFocus,
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _containerController,
                      focusNode: _containerFocus,
                      label: 'Contenedor',
                      hint: 'C-XXXXX',
                      icon: Icons.local_shipping,
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
          borderSide: BorderSide(color: Colors.grey[400]!),
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

  @override
  void dispose() {
    _containerController.dispose();
    _visualAidController.dispose();
    _finalLabelController.dispose();
    _containerFocus.dispose();
    _visualAidFocus.dispose();
    _finalLabelFocus.dispose();
    super.dispose();
  }
}
