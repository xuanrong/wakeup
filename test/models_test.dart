import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup/models/alarm_model.dart';
import 'package:wakeup/models/daily_stat.dart';
import 'package:wakeup/models/mission_config.dart';

void main() {
  group('MissionConfig', () {
    test('toJson/fromJson 往返一致', () {
      const m = MissionConfig(type: MissionType.schulte, difficulty: 3);
      final back = MissionConfig.fromJson(m.toJson());
      expect(back, m);
    });

    test('缺省字段有默认值', () {
      final m = MissionConfig.fromJson({'type': 'shake'});
      expect(m.difficulty, 1);
      expect(m.target, 0);
      expect(m.poemId, isNull);
    });

    test('displayName 中文名', () {
      expect(const MissionConfig(type: MissionType.poem).displayName, '输入古诗');
    });
  });

  group('AlarmModel', () {
    test('toJson/fromJson 往返一致（含全字段）', () {
      final a = AlarmModel(
        id: 'a1',
        hour: 7,
        minute: 30,
        scheduleType: ScheduleType.custom,
        repeatDays: const [1, 2, 3, 4, 5],
        skipHoliday: true,
        bigSmallBaseWeek: DateTime(2026, 8, 3),
        dayOverrides: const {'2026-09-01': RestOrWork.rest},
        label: '上班',
        missions: const [
          MissionConfig(type: MissionType.schulte, difficulty: 2),
          MissionConfig(type: MissionType.steps, target: 40),
        ],
        soundPackId: 'gentle',
        volumeFadeIn: false,
      );
      final back = AlarmModel.fromJson(a.toJson());
      expect(back, a);
      expect(back.dayOverrides['2026-09-01'], RestOrWork.rest);
    });

    test('缺省字段有默认值', () {
      final a = AlarmModel.fromJson({'id': 'x', 'hour': 6, 'minute': 0});
      expect(a.scheduleType, ScheduleType.daily);
      expect(a.missions, isEmpty);
      expect(a.enabled, isTrue);
    });

    test('timeText 补零', () {
      const a = AlarmModel(id: 'a', hour: 7, minute: 5);
      expect(a.timeText, '07:05');
    });

    test('minutesOfDay 计算', () {
      const a = AlarmModel(id: 'a', hour: 23, minute: 59);
      expect(a.minutesOfDay, 1439);
    });

    test('copyWith 只改指定字段', () {
      const a = AlarmModel(id: 'a', hour: 7, minute: 0, label: '晨跑');
      final b = a.copyWith(hour: 8);
      expect(b.hour, 8);
      expect(b.minute, 0);
      expect(b.label, '晨跑');
    });
  });

  group('DailyStat', () {
    test('dateKey 格式', () {
      final s = DailyStat(date: DateTime(2026, 8, 9));
      expect(s.dateKey, '2026-08-09');
    });

    test('toJson/fromJson 往返', () {
      final s = DailyStat(
        date: DateTime(2026, 8, 9),
        hasAlarm: true,
        gotUp: true,
        missionSeconds: 95,
        done: const [MissionType.schulte],
      );
      final back = DailyStat.fromJson(s.toJson());
      expect(back.dateKey, '2026-08-09');
      expect(back.done, [MissionType.schulte]);
    });
  });
}
