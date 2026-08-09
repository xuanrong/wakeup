import '../../models/daily_stat.dart';

/// 统计读写抽象。
abstract class StatRepository {
  Future<List<DailyStat>> loadAll();

  Future<DailyStat?> findByDate(String dateKey);

  Future<void> save(DailyStat stat);

  /// 删除某日统计（用于校准/清空）。
  Future<void> delete(String dateKey);
}
