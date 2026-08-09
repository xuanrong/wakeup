import 'mission_config.dart';

/// 重复类型：每天 / 工作日 / 仅法定工作日 / 大小周 / 自定义周几。
enum ScheduleType { daily, weekday, legal, bigSmallWeek, custom }

/// 单日覆盖：休息 / 上班（最高优先级）。
enum RestOrWork { rest, work }

/// 闹钟模型（纯数据，可 JSON 序列化）。
class AlarmModel {
  const AlarmModel({
    required this.id,
    required this.hour,
    required this.minute,
    this.scheduleType = ScheduleType.daily,
    this.repeatDays = const [],
    this.skipHoliday = false,
    this.bigSmallBaseWeek,
    this.dayOverrides = const {},
    this.label = '',
    this.missions = const [],
    this.soundPackId = 'crazy',
    this.volumeFadeIn = true,
    this.enabled = true,
  });

  final String id;
  final int hour;
  final int minute;

  /// 重复类型（daily/weekday/legal/bigSmallWeek/custom）。
  final ScheduleType scheduleType;

  /// custom 模式：周一=1 … 周日=7。
  final List<int> repeatDays;

  /// 闹钟级开关：工作日闹钟跳过节假日/周末。
  final bool skipHoliday;

  /// 大小周基准周（scheduleType=bigSmallWeek 时生效）。
  final DateTime? bigSmallBaseWeek;

  /// 单日覆盖：{'2026-09-01': RestOrWork.rest/work}，最高优先级。
  final Map<String, RestOrWork> dayOverrides;

  final String label;

  /// 任务组合（1-3 个）。
  final List<MissionConfig> missions;

  final String soundPackId;
  final bool volumeFadeIn;
  final bool enabled;

  /// 一天中的分钟数，便于比较/排序。
  int get minutesOfDay => hour * 60 + minute;

  String get timeText => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String,
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      scheduleType: ScheduleType.values.byName(json['scheduleType'] as String? ?? 'daily'),
      repeatDays: (json['repeatDays'] as List?)?.map((e) => e as int).toList() ?? const [],
      skipHoliday: json['skipHoliday'] as bool? ?? false,
      bigSmallBaseWeek: json['bigSmallBaseWeek'] != null
          ? DateTime.parse(json['bigSmallBaseWeek'] as String)
          : null,
      dayOverrides: (json['dayOverrides'] as Map?)?.map(
            (k, v) => MapEntry(k as String, RestOrWork.values.byName(v as String)),
          ) ??
          const {},
      label: json['label'] as String? ?? '',
      missions: (json['missions'] as List? ?? const [])
          .map((e) => MissionConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      soundPackId: json['soundPackId'] as String? ?? 'crazy',
      volumeFadeIn: json['volumeFadeIn'] as bool? ?? true,
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'hour': hour,
        'minute': minute,
        'scheduleType': scheduleType.name,
        'repeatDays': repeatDays,
        'skipHoliday': skipHoliday,
        if (bigSmallBaseWeek != null) 'bigSmallBaseWeek': bigSmallBaseWeek!.toIso8601String(),
        'dayOverrides': dayOverrides.map((k, v) => MapEntry(k, v.name)),
        'label': label,
        'missions': missions.map((m) => m.toJson()).toList(),
        'soundPackId': soundPackId,
        'volumeFadeIn': volumeFadeIn,
        'enabled': enabled,
      };

  /// 复制一份并替换指定字段。
  AlarmModel copyWith({
    int? hour,
    int? minute,
    ScheduleType? scheduleType,
    List<int>? repeatDays,
    bool? skipHoliday,
    DateTime? bigSmallBaseWeek,
    Map<String, RestOrWork>? dayOverrides,
    String? label,
    List<MissionConfig>? missions,
    String? soundPackId,
    bool? volumeFadeIn,
    bool? enabled,
  }) {
    return AlarmModel(
      id: id,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      scheduleType: scheduleType ?? this.scheduleType,
      repeatDays: repeatDays ?? this.repeatDays,
      skipHoliday: skipHoliday ?? this.skipHoliday,
      bigSmallBaseWeek: bigSmallBaseWeek ?? this.bigSmallBaseWeek,
      dayOverrides: dayOverrides ?? this.dayOverrides,
      label: label ?? this.label,
      missions: missions ?? this.missions,
      soundPackId: soundPackId ?? this.soundPackId,
      volumeFadeIn: volumeFadeIn ?? this.volumeFadeIn,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AlarmModel &&
      other.id == id &&
      other.hour == hour &&
      other.minute == minute &&
      other.scheduleType == scheduleType &&
      _listEquals(other.repeatDays, repeatDays) &&
      other.skipHoliday == skipHoliday &&
      other.bigSmallBaseWeek == bigSmallBaseWeek &&
      other.label == label &&
      other.soundPackId == soundPackId &&
      other.volumeFadeIn == volumeFadeIn &&
      other.enabled == enabled;

  @override
  int get hashCode => Object.hash(
        id, hour, minute, scheduleType, repeatDays, skipHoliday, bigSmallBaseWeek, label, soundPackId,
        volumeFadeIn, enabled,
      );

  static bool _listEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
