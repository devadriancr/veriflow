import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart'; // Para kDebugMode
import 'package:http/http.dart' as http;
import 'package:network_info_plus/network_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:veriflow/models/record_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.1.50.253:7000/api';
  static const String recordsEndpoint = '$baseUrl/records';
  static final NetworkInfo _networkInfo = NetworkInfo();
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Método para obtener información del dispositivo
  static Future<Map<String, String>> getDeviceInfo() async {
    try {
      // Obtener nombre del dispositivo
      String deviceName = await _getDeviceName();
      // Obtener dirección IP
      String ipAddress = await _getIpAddress();
      // Obtener dirección MAC/BSSID
      String macAddress = await _getMacAddress();

      return {
        'device': deviceName.trim(),
        'ip': ipAddress,
        'mac': macAddress,
      };
    } catch (e) {
      _logError('Error general obteniendo información del dispositivo', e);
      return {
        'device': 'Unknown',
        'ip': 'Unknown',
        'mac': 'Unknown',
      };
    }
  }

  // Método para obtener el nombre del dispositivo
  static Future<String> _getDeviceName() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.utsname.machine;
      }
    } catch (e) {
      _logError('Error obteniendo nombre del dispositivo', e);
    }
    return 'Unknown';
  }

  // Método para obtener la dirección IP
  static Future<String> _getIpAddress() async {
    try {
      return await _networkInfo.getWifiIP() ?? 'Unknown';
    } catch (e) {
      _logError('Error obteniendo IP', e);
      return 'Unknown';
    }
  }

  // Método para obtener la dirección MAC
  static Future<String> _getMacAddress() async {
    String macAddress = 'Unknown';
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt >= 29) {
          macAddress = 'MAC restricted (Android 10+)';
        } else {
          final wifiInfo = await _networkInfo.getWifiBSSID();
          macAddress = wifiInfo?.toUpperCase() ?? 'Unknown';
        }
      }
    } catch (e) {
      _logError('Error obteniendo MAC', e);
    }
    return macAddress;
  }

  // Método para enviar un registro a la API con logs detallados
  static Future<int?> sendRecordToApi(RecordModel record) async {
    try {
      final deviceInfo = await getDeviceInfo();

      // Formatear la fecha correctamente
      final creationDate = DateTime.parse(record.creationDate);
      final formattedDate = "${creationDate.toIso8601String().split('.')[0]}Z";

      // Construir el cuerpo de la solicitud
      final requestBody = {
        'container_code': record.containerCode,
        'visual_aid_code': record.visualAidCode,
        'final_label_code': record.finalLabelCode,
        'created_at': formattedDate,
        'status': record.status,
        'device': deviceInfo['device'],
        'ip': deviceInfo['ip'],
        'mac': deviceInfo['mac'],
      };

      if (kDebugMode) {
        _logRequest(recordsEndpoint, jsonEncode(requestBody));
      }

      final response = await http.post(
        Uri.parse(recordsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (kDebugMode) {
        _logResponse(response.statusCode, response.body);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['id'] as int;
      }
      return null;
    } catch (e) {
      _logError('Error enviando registro a la API', e);
      return null;
    }
  }

  static Future<bool> sendAuthData(int recordId, String createdAt) async {
    const endpoint = '$baseUrl/auth'; // Mejor práctica: definir como constante
    try {
      final creationDate = DateTime.parse(createdAt);
      final formattedDate = "${creationDate.toIso8601String().split('.')[0]}Z";

      final requestBody = {
        'record_id': recordId,
        'created_at': formattedDate,
      };

      // Log de la solicitud
      if (kDebugMode) {
        _logRequest(endpoint, jsonEncode(requestBody));
      }

      final response = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      // Log de la respuesta
      if (kDebugMode) {
        _logResponse(response.statusCode, response.body);
      }

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _logError('Error enviando datos de autenticación a $endpoint', e);
      return false;
    }
  }

  // Métodos auxiliares para logging
  static void _logRequest(String endpoint, String body) {
    print('╔═══════════════════════════════════════════════════════════');
    print('╟── 📤 REQUEST TO API');
    print('║ Endpoint: $endpoint');
    print('║ Request Body:');
    print('║ ${body.replaceAll('\n', '\n║ ')}');
    print('╚═══════════════════════════════════════════════════════════');
  }

  static void _logResponse(int statusCode, String body) {
    print('╔═══════════════════════════════════════════════════════════');
    print('╟── 📥 RESPONSE FROM API');
    print('║ Status Code: $statusCode');
    print('║ Response Body:');
    print('║ ${body.replaceAll('\n', '\n║ ')}');
    print('╚═══════════════════════════════════════════════════════════');
  }

  static void _logError(String message, dynamic error) {
    print('╔═══════════════════════════════════════════════════════════');
    print('╟── ❌ ERROR');
    print('║ $message');
    print('║ Error Details: $error');
    print('╚═══════════════════════════════════════════════════════════');
  }
}
