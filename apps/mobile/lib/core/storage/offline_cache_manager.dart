import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineCacheManager {
  static const String keyProfile = 'cached_user_profile';
  static const String keySduiLayout = 'cached_sdui_layout_';
  static const String keyRoutine = 'cached_routine_data';
  static const String keyNotices = 'cached_notices_data';

  static Future<void> cacheJson(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> getCachedJson(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  static Future<void> cacheSduiLayout(String screenId, Map<String, dynamic> layout) async {
    await cacheJson('$keySduiLayout$screenId', layout);
  }

  static Future<Map<String, dynamic>?> getSduiLayout(String screenId) async {
    return await getCachedJson('$keySduiLayout$screenId');
  }
}
