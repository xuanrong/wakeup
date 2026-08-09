import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakeup/data/local/prefs_alarm_repository.dart';
import 'package:wakeup/data/local/prefs_mission_progress_repository.dart';
import 'package:wakeup/data/local/prefs_stat_repository.dart';
import 'package:wakeup/data/local/prefs_store.dart';
import 'package:wakeup/data/repositories/mission_progress_repository.dart';
import 'package:wakeup/models/alarm_model.dart';
import 'package:wakeup/models/daily_stat.dart';

void main() {
  late PrefsStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    store = PrefsStore(prefs);
  });

  group('PrefsAlarmRepository', () {
    test('save + loadAll 往返', () async {
      final repo = PrefsAlarmRepository(store);
      const a = AlarmModel(id: 'a1', hour: 7, minute: 30, label: '晨跑');
      await repo.save(a);
      final all = await repo.loadAll();
      expect(all, [a]);
    });

    test('覆盖同 id', () async {
      final repo = PrefsAlarmRepository(store);
      await repo.save(const AlarmModel(id: 'a1', hour: 7, minute: 0));
      await repo.save(const AlarmModel(id: 'a1', hour: 8, minute: 0));
      final all = await repo.loadAll();
      expect(all.length, 1);
      expect(all.first.hour, 8);
    });

    test('按时间排序 + 删除', () async {
      final repo = PrefsAlarmRepository(store);
      await repo.save(const AlarmModel(id: 'b', hour: 9, minute: 0));
      await repo.save(const AlarmModel(id: 'a', hour: 6, minute: 0));
      expect((await repo.loadAll()).map((a) => a.id).toList(), ['a', 'b']);
      await repo.delete('a');
      expect((await repo.loadAll()).map((a) => a.id).toList(), ['b']);
    });
  });

  group('PrefsStatRepository', () {
    test('save + findByDate', () async {
      final repo = PrefsStatRepository(store);
      final s = DailyStat(date: DateTime(2026, 8, 9), hasAlarm: true, gotUp: true);
      await repo.save(s);
      final found = await repo.findByDate('2026-08-09');
      expect(found, isNotNull);
      expect(found!.gotUp, isTrue);
    });

    test('覆盖同日期', () async {
      final repo = PrefsStatRepository(store);
      await repo.save(DailyStat(date: DateTime(2026, 8, 9), gotUp: false));
      await repo.save(DailyStat(date: DateTime(2026, 8, 9), gotUp: true));
      final all = await repo.loadAll();
      expect(all.length, 1);
      expect(all.first.gotUp, isTrue);
    });
  });

  group('PrefsMissionProgressRepository / 防串', () {
    test('保存与读取（同 alarmId + 日期）', () async {
      final repo = PrefsMissionProgressRepository(store);
      final p = MissionProgress(
        alarmId: 'a1',
        triggerDate: '2026-08-09',
        currentIndex: 1,
        schulteClicked: const [1, 2, 3],
      );
      await repo.save(p);
      final loaded = await repo.load('a1', '2026-08-09');
      expect(loaded, isNotNull);
      expect(loaded!.currentIndex, 1);
      expect(loaded.schulteClicked, [1, 2, 3]);
    });

    test('不同 triggerDate 互不干扰（防串核心）', () async {
      final repo = PrefsMissionProgressRepository(store);
      await repo.save(MissionProgress(alarmId: 'a1', triggerDate: '2026-08-08', currentIndex: 2));
      await repo.save(MissionProgress(alarmId: 'a1', triggerDate: '2026-08-09', currentIndex: 0));
      final old = await repo.load('a1', '2026-08-08');
      final today = await repo.load('a1', '2026-08-09');
      expect(old!.currentIndex, 2);
      expect(today!.currentIndex, 0);
    });

    test('删除进度', () async {
      final repo = PrefsMissionProgressRepository(store);
      await repo.save(MissionProgress(alarmId: 'a1', triggerDate: '2026-08-09'));
      await repo.delete('a1', '2026-08-09');
      expect(await repo.load('a1', '2026-08-09'), isNull);
    });
  });
}
