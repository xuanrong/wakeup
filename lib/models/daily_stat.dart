import 'mission_config.dart';

/// 每日统计（起床率/连续早起口径见设计文档 3.5）。
class DailyStat {
  const DailyStat({
    required this.date,
    this.hasAlarm = false,
    this.gotUp = false,
    this.lazyFlag = false,
    this.missionSeconds = 0,
    this.done = const [],
  });

  /// 统计归属日期（本地日期，去掉时分）。
  final DateTime date;

  /// 当天是否有启用闹钟到点响铃（起床率分母）。
  final bool hasAlarm;

  /// 是否起床成功（完成全部任务）。
  final bool gotUp;

  /// 赖床标签：响铃 30 分钟未完成任务（不影响成功判定）。
  final bool lazyFlag;

  /// 任务总耗时（秒）。未完成则为 0。
  final int missionSeconds;

  /// 完成的任务类型列表。
  final List<MissionType> done;

  /// 日期字符串 yyyy-MM-dd（本地）。
  String get dateKey =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: DateTime.parse(json['date'] as String),
      hasAlarm: json['hasAlarm'] as bool? ?? false,
      gotUp: json['gotUp'] as bool? ?? false,
      lazyFlag: json['lazyFlag'] as bool? ?? false,
      missionSeconds: json['missionSeconds'] as int? ?? 0,
      done: (json['done'] as List? ?? const [])
          .map((e) => MissionType.values.byName(e as String))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': dateKey,
        'hasAlarm': hasAlarm,
        'gotUp': gotUp,
        'lazyFlag': lazyFlag,
        'missionSeconds': missionSeconds,
        'done': done.map((e) => e.name).toList(),
      };

  DailyStat copyWith({
    bool? hasAlarm,
    bool? gotUp,
    bool? lazyFlag,
    int? missionSeconds,
    List<MissionType>? done,
  }) {
    return DailyStat(
      date: date,
      hasAlarm: hasAlarm ?? this.hasAlarm,
      gotUp: gotUp ?? this.gotUp,
      lazyFlag: lazyFlag ?? this.lazyFlag,
      missionSeconds: missionSeconds ?? this.missionSeconds,
      done: done ?? this.done,
    );
  }
}
