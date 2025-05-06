import 'package:veriflow/models/record_model.dart';
import 'package:veriflow/services/database_helper.dart';

class RecordController {
  static final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  static Future<bool> validateAndSave(
    String containerCode,
    String visualAidCode,
    String finalLabelCode,
  ) async {
    final isValidFormat = containerCode.startsWith('C-') &&
        visualAidCode.startsWith('V-') &&
        containerCode.length > 2 &&
        visualAidCode.length > 2;

    if (!isValidFormat) {
      return _saveRecord(false, containerCode, visualAidCode, finalLabelCode);
    }

    final containerBase = containerCode.substring(2);
    final visualAidBase = visualAidCode.substring(2);

    final isValid = containerBase == visualAidBase &&
        finalLabelCode.contains(containerBase);

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
