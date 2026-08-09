import '../../models/alarm_model.dart';
import '../local/prefs_store.dart';
import '../repositories/alarm_repository.dart';

/// shared_preferences 实现的闹钟仓库。
class PrefsAlarmRepository implements AlarmRepository {
  PrefsAlarmRepository(this._store);

  static const _key = 'alarms_v1';

  final PrefsStore _store;

  @override
  Future<List<AlarmModel>> loadAll() async {
    final list = await _store.getJsonList(_key);
    return list.map(AlarmModel.fromJson).toList();
  }

  @override
  Future<AlarmModel?> findById(String id) async {
    final all = await loadAll();
    for (final a in all) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Future<void> save(AlarmModel alarm) async {
    final all = await loadAll();
    final idx = all.indexWhere((a) => a.id == alarm.id);
    if (idx >= 0) {
      all[idx] = alarm;
    } else {
      all.add(alarm);
    }
    all.sort((a, b) => a.minutesOfDay.compareTo(b.minutesOfDay));
    await _store.setJsonList(_key, all.map((a) => a.toJson()).toList());
  }

  @override
  Future<void> delete(String id) async {
    final all = await loadAll();
    all.removeWhere((a) => a.id == id);
    await _store.setJsonList(_key, all.map((a) => a.toJson()).toList());
  }
}
