import 'package:flutter/services.dart';

/// 原生闹钟调度封装（Channel：com.wakeup.duck/alarm）。
/// 接口对应设计文档 4.4。
class AlarmService {
  AlarmService._();

  static const _channel = MethodChannel('com.wakeup.duck/alarm');

  /// 注册下次响铃。timestamp 为毫秒时间戳。
  static Future<bool> scheduleAlarm({
    required String alarmId,
    required int timestamp,
    required String soundPath,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('scheduleAlarm', {
        'alarmId': alarmId,
        'timestamp': timestamp,
        'soundPath': soundPath,
      }) ?? false;
    } on PlatformException catch (e) {
      throw _toAlarmError(e);
    }
  }

  /// 取消闹钟。
  static Future<bool> cancelAlarm(String alarmId) async {
    try {
      return await _channel.invokeMethod<bool>('cancelAlarm', {'alarmId': alarmId}) ?? false;
    } on PlatformException catch (e) {
      throw _toAlarmError(e);
    }
  }

  /// 冷启动时取本次响铃的 alarmId（无则 null）。
  static Future<String?> getStartAlarmId() async {
    try {
      return await _channel.invokeMethod<String>('getStartAlarmId');
    } on PlatformException {
      return null;
    }
  }

  /// 任务完成，通知原生停止前台服务声音。
  static Future<void> stopRinging() async {
    try {
      await _channel.invokeMethod<void>('stopRinging');
    } on PlatformException catch (e) {
      throw _toAlarmError(e);
    }
  }

  /// 进入全屏后原生声音静音待命（Flutter 接管音效）。
  static Future<void> muteBackground(bool muted) async {
    try {
      await _channel.invokeMethod<void>('muteBackground', muted);
    } on PlatformException catch (e) {
      throw _toAlarmError(e);
    }
  }

  /// 开发调试：立即响铃测试（kDebugMode 下使用）。
  static Future<void> triggerTest() async {
    try {
      await _channel.invokeMethod<void>('triggerTest', {'alarmId': 'test'});
    } on PlatformException catch (e) {
      throw _toAlarmError(e);
    }
  }

  static AlarmException _toAlarmError(PlatformException e) =>
      AlarmException(e.code, e.message);
}

class AlarmException implements Exception {
  const AlarmException(this.code, this.message);

  final String code;
  final String? message;

  @override
  String toString() => 'AlarmException($code): $message';
}
