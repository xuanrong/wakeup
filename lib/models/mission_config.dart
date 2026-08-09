/// 任务类型：4 种核心任务。
enum MissionType { schulte, poem, steps, shake }

/// 任务配置模型（纯数据，可 JSON 序列化）。
///
/// - [difficulty]：1-3 档。schulte = 格数档（3/4/5 格）、poem = 诗长档（短/中/长）；steps/shake 忽略。
/// - [target]：仅 steps/shake，目标步数 / 摇动次数。
/// - [poemId]：仅 poem，指定古诗 ID（为空则随机抽取）。
class MissionConfig {
  const MissionConfig({
    required this.type,
    this.difficulty = 1,
    this.target = 0,
    this.poemId,
  });

  final MissionType type;
  final int difficulty;
  final int target;
  final String? poemId;

  factory MissionConfig.fromJson(Map<String, dynamic> json) {
    return MissionConfig(
      type: MissionType.values.byName(json['type'] as String),
      difficulty: json['difficulty'] as int? ?? 1,
      target: json['target'] as int? ?? 0,
      poemId: json['poemId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'difficulty': difficulty,
        'target': target,
        if (poemId != null) 'poemId': poemId,
      };

  MissionConfig copyWith({
    MissionType? type,
    int? difficulty,
    int? target,
    String? poemId,
  }) {
    return MissionConfig(
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      target: target ?? this.target,
      poemId: poemId ?? this.poemId,
    );
  }

  /// 任务类型的中文展示名。
  String get displayName => switch (type) {
        MissionType.schulte => '舒尔特方格',
        MissionType.poem => '输入古诗',
        MissionType.steps => '步数任务',
        MissionType.shake => '摇动任务',
      };

  @override
  bool operator ==(Object other) =>
      other is MissionConfig &&
      other.type == type &&
      other.difficulty == difficulty &&
      other.target == target &&
      other.poemId == poemId;

  @override
  int get hashCode => Object.hash(type, difficulty, target, poemId);
}
