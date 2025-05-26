import 'package:veriflow/models/record_model.dart';
import 'package:veriflow/services/database_helper.dart';
import 'package:veriflow/services/api_service.dart';

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
      return _saveAndSyncRecord(
          false, containerCode, visualAidCode, finalLabelCode);
    }

    // 2. Verificar formatos correctos (C- y V-)
    final containerValid =
        containerCode.startsWith('C-') && containerCode.length > 2;
    final visualAidValid =
        visualAidCode.startsWith('V-') && visualAidCode.length > 2;

    if (!containerValid || !visualAidValid) {
      return _saveAndSyncRecord(
          false, containerCode, visualAidCode, finalLabelCode);
    }

    // 3. Extraer códigos base (lo que viene después del prefijo)
    final containerBase = containerCode.substring(2);
    final visualAidBase = visualAidCode.substring(2);

    // 4. Verificar que los códigos base coincidan
    if (containerBase != visualAidBase) {
      return _saveAndSyncRecord(
          false, containerCode, visualAidCode, finalLabelCode);
    }

    // 5. Verificar que el código base esté incluido en la etiqueta final
    final isValid = finalLabelCode.contains(containerBase);

    return _saveAndSyncRecord(
        isValid, containerCode, visualAidCode, finalLabelCode);
  }

  static Future<bool> _saveAndSyncRecord(
    bool status,
    String containerCode,
    String visualAidCode,
    String finalLabelCode,
  ) async {
    try {
      // 1. Crear registro temporal sin ID local
      final record = RecordModel(
        containerCode: containerCode,
        visualAidCode: visualAidCode,
        finalLabelCode: finalLabelCode,
        creationDate: DateTime.now().toIso8601String(),
        status: status,
        isSynced: false,
      );

      // 2. Intentar sincronizar primero con la API
      final serverId = await ApiService.sendRecordToApi(record);

      if (serverId != null) {
        // 3. Si éxito: Guardar en local con serverId
        record.recordId = serverId;
        record.isSynced = true;
        await _dbHelper.insertRecord(record);
      } else {
        // 4. Si falla: Guardar en local para reintentar después
        final localId = await _dbHelper.insertRecord(record);
        record.id = localId;
      }

      return status;
    } catch (e) {
      print('Error guardando registro: $e');
      return false;
    }
  }

  // Método de sincronización mejorado
  static Future<void> syncRecords() async {
    try {
      final unsyncedRecords = await _dbHelper.getUnsyncedRecords();

      for (final record in unsyncedRecords) {
        // 1. Enviar registro a la API
        final serverId = await ApiService.sendRecordToApi(record);

        if (serverId != null) {
          // 2. Actualizar registro local con serverId
          await _dbHelper.updateRecordServerId(record.id!, serverId);

          // 3. Si el registro tenía un recordId previo, actualizar referencias
          if (record.recordId != null) {
            await _dbHelper.updateRecordReferences(record.recordId!, serverId);
          }

          // 4. Marcar como sincronizado
          await _dbHelper.updateRecordSyncStatus(record.id!, true);
        }
      }
    } catch (e) {
      print('Error en la sincronización: $e');
    }
  }

  // Método para obtener el último NG
  static Future<RecordModel?> getLastNGRecord() async {
    final db = await DatabaseHelper.instance.database;
    final result = await db.query(
      'records',
      where: 'status = ? AND record_id IS NOT NULL',
      whereArgs: [0],
      orderBy: 'creation_date DESC',
      limit: 1,
    );
    return result.isNotEmpty ? RecordModel.fromMap(result.first) : null;
  }
}
