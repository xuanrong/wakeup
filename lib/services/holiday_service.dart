import '../data/holiday/built_in_holidays.dart';
import '../data/holiday/holiday_table.dart';
import '../models/alarm_model.dart';

/// 节假日 / 大小周 / 下次响铃计算。
/// 判定模型见设计文档 3.6.1（优先级：单日覆盖 > 法定节假日 > 大小周 > 默认周几）。
class HolidayService {
  HolidayService() : _overrideTables = {} {
    _overrideTables.addAll(BuiltInHolidays.tables);
  }

  /// 可通过 `setTable` 注入联网更新的表（可覆盖内置）。
  final Map<int, HolidayTable> _overrideTables;

  /// 注入或更新某年的节假日表。
  void setTable(HolidayTable table) => _overrideTables[table.year] = table;

  HolidayTable _tableFor(DateTime d) =>
      _overrideTables[d.year] ?? HolidayTable(year: d.year);

  /// 日期 → 'yyyy-MM-dd'（本地）。
  String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// 是否为法定节假日（放假）。
  bool isHoliday(DateTime d) => _tableFor(d).isHoliday(dateKey(d));

  /// 是否为调休补班日。
  bool isMakeupWorkday(DateTime d) => _tableFor(d).isMakeupWorkday(dateKey(d));

  /// 该日是否为"休息日"（闹钟工作日模式下不应响铃）。
  ///
  /// 判定：① 单日覆盖 → ② 法定节假日表 → ③ 默认周几（周末休）。
  /// 注意：大小周只影响 [matchesSchedule]，不影响此处（周六默认按周末处理）。
  bool isRestDay(DateTime d, {Map<String, RestOrWork> dayOverrides = const {}}) {
    final key = dateKey(d);
    final override = dayOverrides[key];
    if (override != null) {
      return override == RestOrWork.rest;
    }
    if (isHoliday(d)) return true;
    if (isMakeupWorkday(d)) return false;
    return d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
  }

  /// 单日覆盖判断：返回该日的强制设定（无覆盖则 null）。
  RestOrWork? overrideFor(DateTime d, Map<String, RestOrWork> dayOverrides) {
    return dayOverrides[dateKey(d)];
  }

  /// 大小周：大周周六序号。基准周为 [baseWeek] 所在周的周六（序号 0）。
  bool isBigWeekSaturday(DateTime d, DateTime? baseWeek) {
    final base = baseWeek ?? DateTime(d.year, d.month, d.day);
    final baseSat = _saturdayOfWeek(base);
    final dSat = _saturdayOfWeek(d);
    final weekIndex = dSat.difference(baseSat).inDays ~/ 7;
    // 偶数序号为大周。
    return weekIndex.isEven && weekIndex >= 0;
  }

  DateTime _saturdayOfWeek(DateTime d) {
    final monday = DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: d.weekday - DateTime.monday));
    return monday.add(const Duration(days: 5));
  }

  /// 该日是否匹配闹钟的重复规则（不含 skipHoliday 过滤）。
  bool matchesSchedule(AlarmModel alarm, DateTime d) {
    switch (alarm.scheduleType) {
      case ScheduleType.daily:
        return true;
      case ScheduleType.weekday:
        return d.weekday >= DateTime.monday && d.weekday <= DateTime.friday;
      case ScheduleType.legal:
        return !isRestDay(d, dayOverrides: alarm.dayOverrides);
      case ScheduleType.bigSmallWeek:
        if (d.weekday >= DateTime.monday && d.weekday <= DateTime.friday) {
          return true;
        }
        if (d.weekday == DateTime.saturday) {
          return isBigWeekSaturday(d, alarm.bigSmallBaseWeek);
        }
        return false;
      case ScheduleType.custom:
        final override = overrideFor(d, alarm.dayOverrides);
        if (override != null) return override == RestOrWork.work;
        return alarm.repeatDays.contains(d.weekday);
    }
  }

  /// 该日闹钟是否会响（含 skipHoliday 过滤）。
  bool ringsOn(AlarmModel alarm, DateTime d) {
    if (!alarm.enabled) return false;
    if (!matchesSchedule(alarm, d)) return false;
    if (alarm.skipHoliday && isRestDay(d, dayOverrides: alarm.dayOverrides)) {
      return false;
    }
    return true;
  }

  /// 从 [after]（不含）之后第一个响铃日（日期，不含具体时刻）。
  DateTime? nextRingDate(AlarmModel alarm, {DateTime? after}) {
    final start = after ?? DateTime.now();
    var cursor = DateTime(start.year, start.month, start.day).add(const Duration(days: 1));
    // 最多扫 400 天，避免死循环。
    for (var i = 0; i < 400; i++) {
      if (ringsOn(alarm, cursor)) return cursor;
      cursor = cursor.add(const Duration(days: 1));
    }
    return null;
  }

  /// 下次响铃完整时间点（含时分）。
  DateTime? nextRingTime(AlarmModel alarm, {DateTime? after}) {
    final date = nextRingDate(alarm, after: after);
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day, alarm.hour, alarm.minute);
  }
}
