import 'package:veriflow/models/record_model.dart';
import 'package:veriflow/services/database_helper.dart';

class RecordController {
  static final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  static Future<bool> validateAndSave(
    String containerCode,
    String visualAidCode,
    String finalLabelCode,
  ) async {
    // 1. Verificar si hay campos vacíos (automaticamente NG)
    final hasEmptyFields = containerCode.isEmpty ||
        visualAidCode.isEmpty ||
        finalLabelCode.isEmpty;

    if (hasEmptyFields) {
      return _saveRecord(false, containerCode, visualAidCode, finalLabelCode);
    }

    // 2. Verificar formatos correctos (C- y V-)
    final containerValid =
        containerCode.startsWith('C-') && containerCode.length > 2;
    final visualAidValid =
        visualAidCode.startsWith('V-') && visualAidCode.length > 2;

    if (!containerValid || !visualAidValid) {
      return _saveRecord(false, containerCode, visualAidCode, finalLabelCode);
    }

    // 3. Extraer códigos base (lo que viene después del prefijo)
    final containerBase = containerCode.substring(2);
    final visualAidBase = visualAidCode.substring(2);

    // 4. Verificar que los códigos base coincidan
    if (containerBase != visualAidBase) {
      return _saveRecord(false, containerCode, visualAidCode, finalLabelCode);
    }

    // 5. Verificar que el código base esté incluido en la etiqueta final
    final isValid = finalLabelCode.contains(containerBase);

    return _saveRecord(isValid, containerCode, visualAidCode, finalLabelCode);
  }

  static Future<bool> _saveRecord(
    bool status,
    String containerCode,
    String visualAidCode,
    String finalLabelCode,
  ) async {
    final record = RecordModel(
      containerCode: containerCode,
      visualAidCode: visualAidCode,
      finalLabelCode: finalLabelCode,
      creationDate: DateTime.now().toIso8601String(),
      status: status,
    );

    await _dbHelper.insertRecord(record);
    return status;
  }
}
