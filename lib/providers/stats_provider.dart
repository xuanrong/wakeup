import 'package:flutter/foundation.dart';

import '../data/repositories/stat_repository.dart';
import '../models/daily_stat.dart';

/// 统计汇总（起床率 / 连续早起），口径见设计文档 3.5。
class StatSummary {
  const StatSummary({
    required this.successDays,
    required this.failedDays,
    required this.streakDays,
    required this.lazyDays,
  });

  /// 起床成功天数。
  final int successDays;

  /// 起床失败天数（当天有响铃闹钟但未完成）。
  final int failedDays;

  /// 连续早起天数（今天成功计 1，昨天起连续）。
  final int streakDays;

  /// 赖床标签天数。
  final int lazyDays;

  /// 起床率（成功 / (成功+失败)），无数据返回 null。
  double? get rate {
    final total = successDays + failedDays;
    if (total == 0) return null;
    return successDays / total;
  }
}

/// 统计状态：读取 + 汇总 + 写入每日记录。
class StatsProvider extends ChangeNotifier {
  StatsProvider(this._repo);

  final StatRepository _repo;

  List<DailyStat> _stats = [];

  List<DailyStat> get stats => List.unmodifiable(_stats);

  Future<void> load() async {
    _stats = await _repo.loadAll();
    notifyListeners();
  }

  /// 保存/覆盖某日统计并刷新。
  Future<void> save(DailyStat stat) async {
    await _repo.save(stat);
    await load();
  }

  /// 本周（周一~今天）成功/失败天数。
  StatSummary summaryForWeek({DateTime? now}) {
    final today = now ?? DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - DateTime.monday));
    return _summary(from: monday, to: today);
  }

  /// 最近 N 天（含今天）统计列表（缺失的日期不补 0）。
  List<DailyStat> recentDays(int n, {DateTime? now}) {
    final today = now ?? DateTime.now();
    final start = today.subtract(Duration(days: n - 1));
    final map = {for (final s in _stats) s.dateKey: s};
    final out = <DailyStat>[];
    for (var i = 0; i < n; i++) {
      final d = start.add(Duration(days: i));
      out.add(map[d.toLocalDateKey()] ?? DailyStat(date: d));
    }
    return out;
  }

  StatSummary _summary({required DateTime from, required DateTime to}) {
    var success = 0, failed = 0, lazy = 0;
    for (final s in _stats) {
      if (s.date.isBefore(from) || s.date.isAfter(to)) continue;
      if (!s.hasAlarm) continue;
      if (s.gotUp) {
        success++;
      } else {
        failed++;
      }
      if (s.lazyFlag) lazy++;
    }
    return StatSummary(
      successDays: success,
      failedDays: failed,
      lazyDays: lazy,
      streakDays: _streak(to),
    );
  }

  /// 连续早起：今天（含）往前数连续 gotUp 的天数（其间无响铃的天不算失败但中断连续）。
  int _streak(DateTime end) {
    var streak = 0;
    var cursor = end;
    final map = {for (final s in _stats) s.dateKey: s};
    for (var i = 0; i < 730; i++) {
      final s = map[cursor.toLocalDateKey()];
      if (s != null && s.hasAlarm) {
        if (s.gotUp) {
          streak++;
        } else {
          break; // 当天有响铃但未完成 → 中断
        }
      }
      // 无响铃的天：不计数也不中断（继续往前看）
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

extension _LocalDateKey on DateTime {
  String toLocalDateKey() =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}
