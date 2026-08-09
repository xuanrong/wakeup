import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup/models/alarm_model.dart';
import 'package:wakeup/services/holiday_service.dart';

void main() {
  final svc = HolidayService();
  DateTime d(int y, int m, int day, [int h = 0, int mi = 0]) => DateTime(y, m, day, h, mi);

  group('法定节假日判定', () {
    test('法定放假日被识别为休息', () {
      expect(svc.isRestDay(d(2026, 10, 1)), isTrue); // 国庆
      expect(svc.isRestDay(d(2026, 5, 1)), isTrue); // 劳动节
      expect(svc.isRestDay(d(2026, 2, 15)), isTrue); // 春节
      expect(svc.isRestDay(d(2026, 1, 3)), isTrue); // 元旦
    });

    test('调休补班日被识别为上班', () {
      expect(svc.isRestDay(d(2026, 2, 14)), isFalse); // 周六补班
      expect(svc.isRestDay(d(2026, 2, 28)), isFalse); // 周六补班
      expect(svc.isRestDay(d(2026, 10, 10)), isFalse); // 周六补班
      expect(svc.isRestDay(d(2026, 1, 4)), isFalse); // 周日补班
    });

    test('普通周末休息', () {
      expect(svc.isRestDay(d(2026, 8, 8)), isTrue); // 周六
      expect(svc.isRestDay(d(2026, 8, 9)), isTrue); // 周日
    });

    test('普通工作日上班', () {
      expect(svc.isRestDay(d(2026, 8, 10)), isFalse); // 周一
    });
  });

  group('单日覆盖', () {
    test('覆盖优先于节假日/默认', () {
      const overrides = {'2026-10-01': RestOrWork.work};
      expect(svc.isRestDay(d(2026, 10, 1), dayOverrides: overrides), isFalse);

      const overrides2 = {'2026-08-10': RestOrWork.rest};
      expect(svc.isRestDay(d(2026, 8, 10), dayOverrides: overrides2), isTrue);
    });
  });

  group('大小周', () {
    test('基准周六为大周', () {
      final base = d(2026, 8, 8); // 周六
      expect(svc.isBigWeekSaturday(base, base), isTrue);
    });

    test('下一周六为小周，再下一周为大周', () {
      final base = d(2026, 8, 8);
      expect(svc.isBigWeekSaturday(d(2026, 8, 15), base), isFalse);
      expect(svc.isBigWeekSaturday(d(2026, 8, 22), base), isTrue);
    });
  });

  group('matchesSchedule', () {
    final daily = AlarmModel(id: 'a', hour: 7, minute: 0, scheduleType: ScheduleType.daily);
    final weekday = AlarmModel(id: 'b', hour: 7, minute: 0, scheduleType: ScheduleType.weekday);
    final legal = AlarmModel(id: 'c', hour: 7, minute: 0, scheduleType: ScheduleType.legal);
    final big = AlarmModel(
      id: 'd',
      hour: 7,
      minute: 0,
      scheduleType: ScheduleType.bigSmallWeek,
      bigSmallBaseWeek: d(2026, 8, 8),
    );
    final custom = AlarmModel(
      id: 'e',
      hour: 7,
      minute: 0,
      scheduleType: ScheduleType.custom,
      repeatDays: const [1, 3, 5],
    );

    test('daily 恒真', () {
      expect(svc.matchesSchedule(daily, d(2026, 8, 8)), isTrue);
      expect(svc.matchesSchedule(daily, d(2026, 10, 1)), isTrue);
    });

    test('weekday 只周一到五', () {
      expect(svc.matchesSchedule(weekday, d(2026, 8, 10)), isTrue); // 周一
      expect(svc.matchesSchedule(weekday, d(2026, 8, 15)), isFalse); // 周六
    });

    test('legal 法定工作日（调休处理）', () {
      expect(svc.matchesSchedule(legal, d(2026, 10, 1)), isFalse); // 国庆休
      expect(svc.matchesSchedule(legal, d(2026, 10, 10)), isTrue); // 补班周六
      expect(svc.matchesSchedule(legal, d(2026, 8, 10)), isTrue); // 周一
    });

    test('bigSmallWeek 大周周六响、小周周六不响', () {
      expect(svc.matchesSchedule(big, d(2026, 8, 8)), isTrue); // 大周周六
      expect(svc.matchesSchedule(big, d(2026, 8, 15)), isFalse); // 小周周六
      expect(svc.matchesSchedule(big, d(2026, 8, 10)), isTrue); // 周一
    });

    test('custom 按勾选周几', () {
      expect(svc.matchesSchedule(custom, d(2026, 8, 10)), isTrue); // 周一
      expect(svc.matchesSchedule(custom, d(2026, 8, 11)), isFalse); // 周二
      expect(svc.matchesSchedule(custom, d(2026, 8, 12)), isTrue); // 周三
    });
  });

  group('ringsOn / 下次响铃', () {
    test('skipHoliday 过滤节假日', () {
      final wk = AlarmModel(
        id: 'b',
        hour: 7,
        minute: 0,
        scheduleType: ScheduleType.weekday,
        skipHoliday: true,
      );
      expect(svc.ringsOn(wk, d(2026, 8, 10)), isTrue); // 普通周一
      expect(svc.ringsOn(wk, d(2026, 10, 1)), isFalse); // 国庆周四休
      expect(svc.ringsOn(wk, d(2026, 10, 10)), isFalse); // 周六，weekday 模式不含周六
    });

    test('legal 模式补班周六也响', () {
      final legal = AlarmModel(
        id: 'c',
        hour: 7,
        minute: 0,
        scheduleType: ScheduleType.legal,
        skipHoliday: true,
      );
      expect(svc.ringsOn(legal, d(2026, 10, 10)), isTrue); // 补班周六
      expect(svc.ringsOn(legal, d(2026, 10, 11)), isFalse); // 周日
    });

    test('nextRingDate 取下一匹配日', () {
      final daily = AlarmModel(id: 'a', hour: 7, minute: 0, scheduleType: ScheduleType.daily);
      final next = svc.nextRingDate(daily, after: d(2026, 8, 9, 12, 0));
      expect(next, d(2026, 8, 10));
    });

    test('legal 跳过国庆连假', () {
      final legal = AlarmModel(id: 'c', hour: 7, minute: 0, scheduleType: ScheduleType.legal);
      // 从 10/1 起下一响铃日 = 10/8（10/1-7 放假，10/8 周四上班）
      final next = svc.nextRingDate(legal, after: d(2026, 9, 30, 12, 0));
      expect(next, d(2026, 10, 8));
    });

    test('nextRingTime 带时分', () {
      final daily = AlarmModel(id: 'a', hour: 7, minute: 30, scheduleType: ScheduleType.daily);
      final next = svc.nextRingTime(daily, after: d(2026, 8, 9, 12, 0));
      expect(next, DateTime(2026, 8, 10, 7, 30));
    });
  });
}
