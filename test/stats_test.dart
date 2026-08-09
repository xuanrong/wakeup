import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakeup/data/local/prefs_stat_repository.dart';
import 'package:wakeup/data/local/prefs_store.dart';
import 'package:wakeup/models/daily_stat.dart';
import 'package:wakeup/providers/stats_provider.dart';

void main() {
  late PrefsStore store;
  late PrefsStatRepository repo;
  late StatsProvider provider;

  DailyStat day(int m, int d, {bool hasAlarm = true, bool gotUp = false, bool lazy = false}) =>
      DailyStat(
        date: DateTime(2026, m, d),
        hasAlarm: hasAlarm,
        gotUp: gotUp,
        lazyFlag: lazy,
      );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = PrefsStore(await SharedPreferences.getInstance());
    repo = PrefsStatRepository(store);
    provider = StatsProvider(repo);
  });

  test('空数据：rate 为 null，streak 为 0', () async {
    await provider.load();
    final s = provider.summaryForWeek(now: DateTime(2026, 8, 9));
    expect(s.rate, isNull);
    expect(s.streakDays, 0);
  });

  test('本周内成功/失败计入', () async {
    await repo.save(day(8, 3)); // 周一，失败
    await repo.save(day(8, 5, gotUp: true)); // 周三，成功
    await repo.save(day(8, 8, gotUp: true)); // 周六，成功
    await provider.load();
    // now = 周日 8/9，本周 8/3(一)~8/9(日)
    final s = provider.summaryForWeek(now: DateTime(2026, 8, 9));
    expect(s.successDays, 2);
    expect(s.failedDays, 1);
    expect(s.rate, closeTo(2 / 3, 1e-9));
  });

  test('无响铃闹钟的天不计入分母', () async {
    await repo.save(day(8, 3, hasAlarm: false));
    await provider.load();
    final s = provider.summaryForWeek(now: DateTime(2026, 8, 9));
    expect(s.successDays, 0);
    expect(s.failedDays, 0);
    expect(s.rate, isNull);
  });

  test('连续早起：从今天起连续成功', () async {
    await repo.save(day(8, 7, gotUp: true));
    await repo.save(day(8, 8, gotUp: true));
    await repo.save(day(8, 9, gotUp: true)); // 今天
    await provider.load();
    final s = provider.summaryForWeek(now: DateTime(2026, 8, 9));
    expect(s.streakDays, 3);
  });

  test('连续早起：昨天失败中断', () async {
    await repo.save(day(8, 7, gotUp: true));
    await repo.save(day(8, 8)); // 失败
    await repo.save(day(8, 9, gotUp: true));
    await provider.load();
    final s = provider.summaryForWeek(now: DateTime(2026, 8, 9));
    expect(s.streakDays, 1); // 只算今天
  });

  test('连续早起：无响铃天不中断但不计数', () async {
    await repo.save(day(8, 8, gotUp: true));
    await repo.save(day(8, 9, gotUp: true)); // 今天
    // 8/7 无响铃：不中断
    await repo.save(day(8, 6, gotUp: true));
    await provider.load();
    final s = provider.summaryForWeek(now: DateTime(2026, 8, 9));
    expect(s.streakDays, 3); // 8/9, 8/8, (8/7 跳过), 8/6
  });

  test('连续早起：无响铃天紧跟即中断', () async {
    await repo.save(day(8, 8, gotUp: true));
    await repo.save(day(8, 9, gotUp: true)); // 今天
    // 8/7 无响铃，8/6 无记录 → 只算 8/8,8/9
    await provider.load();
    final s = provider.summaryForWeek(now: DateTime(2026, 8, 9));
    expect(s.streakDays, 2);
  });

  test('赖床标签统计', () async {
    await repo.save(day(8, 8, gotUp: true, lazy: true));
    await provider.load();
    final s = provider.summaryForWeek(now: DateTime(2026, 8, 9));
    expect(s.lazyDays, 1);
    // 赖床不影响成功判定
    expect(s.successDays, 1);
  });

  test('recentDays 补缺失为 hasAlarm=false', () async {
    await repo.save(day(8, 8, gotUp: true));
    await provider.load();
    final list = provider.recentDays(3, now: DateTime(2026, 8, 9));
    expect(list.length, 3);
    // 顺序：8/7, 8/8, 8/9
    expect(list[1].gotUp, isTrue);
    expect(list[0].hasAlarm, isFalse);
  });
}
