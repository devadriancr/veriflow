import 'package:shared_preferences/shared_preferences.dart';

class LockService {
  static const _key = 'is_locked';

  static Future<bool> isLocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  static Future<void> lockApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> unlockApp() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
