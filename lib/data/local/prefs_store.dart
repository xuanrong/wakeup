import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 通用 JSON 存取封装。Repository 的具体存储实现（MVP 用 shared_preferences）。
class PrefsStore {
  PrefsStore(this._prefs);

  final SharedPreferences _prefs;

  Future<List<Map<String, dynamic>>> getJsonList(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> setJsonList(String key, List<Map<String, dynamic>> list) async {
    await _prefs.setString(key, jsonEncode(list));
  }

  Future<Map<String, dynamic>?> getJsonMap(String key) async {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map).cast<String, dynamic>();
  }

  Future<void> setJsonMap(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Future<String?> getString(String key) async => _prefs.getString(key);

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }
}
