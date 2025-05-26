import 'dart:async';
import 'package:veriflow/controllers/record_controller.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  Timer? _syncTimer;

  factory SyncManager() => _instance;

  SyncManager._internal();

  void startPeriodicSync({Duration interval = const Duration(minutes: 5)}) {
    // Cancelar cualquier temporizador existente
    _syncTimer?.cancel();

    // Ejecutar la primera sincronización inmediatamente
    RecordController.syncRecords();

    // Configurar sincronización periódica
    _syncTimer = Timer.periodic(interval, (timer) {
      RecordController.syncRecords();
    });
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}
