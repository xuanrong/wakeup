import '../../models/daily_stat.dart';
import '../local/prefs_store.dart';
import '../repositories/stat_repository.dart';

/// shared_preferences 实现的统计仓库。
class PrefsStatRepository implements StatRepository {
  PrefsStatRepository(this._store);

  static const _key = 'stats_v1';

  final PrefsStore _store;

  @override
  Future<List<DailyStat>> loadAll() async {
    final list = await _store.getJsonList(_key);
    return list.map(DailyStat.fromJson).toList();
  }

  @override
  Future<DailyStat?> findByDate(String dateKey) async {
    final all = await loadAll();
    for (final s in all) {
      if (s.dateKey == dateKey) return s;
    }
    return null;
  }

  @override
  Future<void> save(DailyStat stat) async {
    final all = await loadAll();
    final idx = all.indexWhere((s) => s.dateKey == stat.dateKey);
    if (idx >= 0) {
      all[idx] = stat;
    } else {
      all.add(stat);
    }
    all.sort((a, b) => a.date.compareTo(b.date));
    await _store.setJsonList(_key, all.map((s) => s.toJson()).toList());
  }

  @override
  Future<void> delete(String dateKey) async {
    final all = await loadAll();
    all.removeWhere((s) => s.dateKey == dateKey);
    await _store.setJsonList(_key, all.map((s) => s.toJson()).toList());
  }
}
