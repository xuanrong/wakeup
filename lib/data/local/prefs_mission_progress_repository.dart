import '../local/prefs_store.dart';
import '../repositories/mission_progress_repository.dart';

/// shared_preferences 实现的任务进度仓库。
///
/// 进度按 `alarmId + triggerDate` 合并成唯一 key，天然防串（见设计文档 3.4）。
class PrefsMissionProgressRepository implements MissionProgressRepository {
  PrefsMissionProgressRepository(this._store);

  static const _prefix = 'mission_progress_';

  final PrefsStore _store;

  String _key(String alarmId, String triggerDate) =>
      '$_prefix$alarmId::$triggerDate';

  @override
  Future<MissionProgress?> load(String alarmId, String triggerDate) async {
    final json = await _store.getJsonMap(_key(alarmId, triggerDate));
    if (json == null) return null;
    return MissionProgress.fromJson(json);
  }

  @override
  Future<void> save(MissionProgress progress) async {
    await _store.setJsonMap(
      _key(progress.alarmId, progress.triggerDate),
      progress.toJson(),
    );
  }

  @override
  Future<void> delete(String alarmId, String triggerDate) async {
    await _store.remove(_key(alarmId, triggerDate));
  }
}
