import 'package:flutter/foundation.dart';

import '../data/repositories/alarm_repository.dart';
import '../models/alarm_model.dart';
import '../services/alarm_service.dart';
import '../services/holiday_service.dart';

/// 闹钟列表 CRUD + 原生调度编排。
class AlarmProvider extends ChangeNotifier {
  AlarmProvider(this._repo, this._holidayService);

  final AlarmRepository _repo;
  final HolidayService _holidayService;

  List<AlarmModel> _alarms = [];
  bool _loading = false;
  String? _error;

  List<AlarmModel> get alarms => List.unmodifiable(_alarms);
  bool get loading => _loading;
  String? get error => _error;

  /// 按响铃时刻升序的启用闹钟。
  List<AlarmModel> get enabledAlarms =>
      _alarms.where((a) => a.enabled).toList();

  AlarmModel? byId(String id) {
    for (final a in _alarms) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// 最近一次响铃的启用闹钟（无则 null），供首页页头展示。
  AlarmModel? get nextAlarm {
    AlarmModel? best;
    DateTime? bestTime;
    for (final a in enabledAlarms) {
      final t = _holidayService.nextRingTime(a);
      if (t == null) continue;
      if (bestTime == null || t.isBefore(bestTime)) {
        bestTime = t;
        best = a;
      }
    }
    return best;
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _alarms = await _repo.loadAll();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// 保存（新增/覆盖）并同步原生调度。
  Future<void> save(AlarmModel alarm) async {
    await _repo.save(alarm);
    if (alarm.enabled) {
      await _schedule(alarm);
    } else {
      await AlarmService.cancelAlarm(alarm.id);
    }
    await load();
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    await AlarmService.cancelAlarm(id);
    await load();
  }

  /// 切换启用状态并重新调度。
  Future<void> toggleEnabled(String id, bool enabled) async {
    final alarm = byId(id);
    if (alarm == null) return;
    await save(alarm.copyWith(enabled: enabled));
  }

  /// 全部启用闹钟重新调度（冷启动 / 重启恢复时调用）。
  Future<void> rescheduleAll() async {
    for (final a in enabledAlarms) {
      await _schedule(a);
    }
  }

  Future<void> _schedule(AlarmModel alarm) async {
    final next = _holidayService.nextRingTime(alarm);
    if (next == null) return;
    await AlarmService.scheduleAlarm(
      alarmId: alarm.id,
      timestamp: next.millisecondsSinceEpoch,
      soundPath: alarm.soundPackId,
    );
  }

  /// 下次响铃时间（DateTime?，供 UI 展示）。
  DateTime? nextRingTime(AlarmModel alarm) =>
      _holidayService.nextRingTime(alarm);
}
