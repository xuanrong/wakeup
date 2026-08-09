/// 响铃任务进度（alarmId + 触发日期防串，见设计文档 3.4）。
///
/// 单条进度在 App 生命周期内唯一：按 `{alarmId, triggerDate}` 读取/写入。
class MissionProgress {
  const MissionProgress({
    required this.alarmId,
    required this.triggerDate,
    this.currentIndex = 0,
    this.completed = const [],
    this.schulteClicked = const [],
    this.poemTyped = '',
    this.stepStart = 0,
    this.shakeCount = 0,
    this.missionStartAt,
  });

  final String alarmId;

  /// 触发日期 'yyyy-MM-dd'。
  final String triggerDate;

  /// 当前正在执行的任务序号（0 起）。
  final int currentIndex;

  /// 已完成的任务（存 MissionType.name）。
  final List<String> completed;

  /// 舒尔特：已按序点击的数字列表。
  final List<int> schulteClicked;

  /// 古诗：已输入文本。
  final String poemTyped;

  /// 步数：响应铃起始累计步数（作差值基线）。
  final int stepStart;

  /// 摇动：已完成次数。
  final int shakeCount;

  /// 进入任务页时间（本地），用于任务耗时。
  final DateTime? missionStartAt;

  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    return MissionProgress(
      alarmId: json['alarmId'] as String,
      triggerDate: json['triggerDate'] as String,
      currentIndex: json['currentIndex'] as int? ?? 0,
      completed: (json['completed'] as List? ?? const []).map((e) => e as String).toList(),
      schulteClicked: (json['schulteClicked'] as List? ?? const [])
          .map((e) => e as int)
          .toList(),
      poemTyped: json['poemTyped'] as String? ?? '',
      stepStart: json['stepStart'] as int? ?? 0,
      shakeCount: json['shakeCount'] as int? ?? 0,
      missionStartAt: json['missionStartAt'] != null
          ? DateTime.parse(json['missionStartAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'alarmId': alarmId,
        'triggerDate': triggerDate,
        'currentIndex': currentIndex,
        'completed': completed,
        'schulteClicked': schulteClicked,
        'poemTyped': poemTyped,
        'stepStart': stepStart,
        'shakeCount': shakeCount,
        if (missionStartAt != null) 'missionStartAt': missionStartAt!.toIso8601String(),
      };

  MissionProgress copyWith({
    int? currentIndex,
    List<String>? completed,
    List<int>? schulteClicked,
    String? poemTyped,
    int? stepStart,
    int? shakeCount,
    DateTime? missionStartAt,
  }) {
    return MissionProgress(
      alarmId: alarmId,
      triggerDate: triggerDate,
      currentIndex: currentIndex ?? this.currentIndex,
      completed: completed ?? this.completed,
      schulteClicked: schulteClicked ?? this.schulteClicked,
      poemTyped: poemTyped ?? this.poemTyped,
      stepStart: stepStart ?? this.stepStart,
      shakeCount: shakeCount ?? this.shakeCount,
      missionStartAt: missionStartAt ?? this.missionStartAt,
    );
  }
}

/// 任务进度读写抽象。
abstract class MissionProgressRepository {
  Future<MissionProgress?> load(String alarmId, String triggerDate);

  Future<void> save(MissionProgress progress);

  Future<void> delete(String alarmId, String triggerDate);
}
