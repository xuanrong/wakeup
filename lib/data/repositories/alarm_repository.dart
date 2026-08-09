import '../../models/alarm_model.dart';

/// 闹钟 CRUD 抽象。MVP 用 shared_preferences 实现，Phase 2 可换 sqflite。
abstract class AlarmRepository {
  Future<List<AlarmModel>> loadAll();

  Future<AlarmModel?> findById(String id);

  /// 新增或覆盖。
  Future<void> save(AlarmModel alarm);

  Future<void> delete(String id);
}
