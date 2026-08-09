import 'dart:math';

import '../data/poem_bank.dart';
import '../models/mission_config.dart';

/// 各任务类型的执行逻辑判定（纯函数，便于单测）。
class MissionService {
  const MissionService();

  // ---------- 舒尔特方格 ----------

  /// 按难度生成格子数：难度 1/2/3 → 3/4/5 格。
  static int schulteGridSize(int difficulty) => switch (difficulty) {
        1 => 3,
        2 => 4,
        _ => 5,
      };

  /// 生成乱序 1..n 的数字序列。
  static List<int> schulteNumbers(int size, {int seed = 0}) {
    final numbers = List.generate(size * size, (i) => i + 1);
    final rng = Random(seed);
    numbers.shuffle(rng);
    return numbers;
  }

  /// 当前应点击的数字（已点 [clicked] 的下一个）。
  static int nextSchulteTarget(List<int> clicked) => clicked.length + 1;

  /// 点击 [num] 是否正确（等于下一个目标）。
  static bool isSchulteCorrect(List<int> clicked, int num) =>
      num == nextSchulteTarget(clicked);

  // ---------- 古诗 ----------

  /// 古诗比对：忽略首尾/连续空白，半角标点等价全角。
  /// 只比对正文诗句（不含标题/作者）。见设计文档 3.3。
  static String normalizePoemInput(String input) {
    const halfToFull = {
      ',': '，', '.': '。', '?': '？', '!': '！', ';': '；', ':': '：',
      '(': '（', ')': '）',
    };
    final sb = StringBuffer();
    for (final ch in input.trim().split('')) {
      if (ch.trim().isEmpty) continue; // 忽略空白
      sb.write(halfToFull[ch] ?? ch);
    }
    return sb.toString();
  }

  /// 输入 [typed] 相对原文 [text] 是否完全匹配（规范化后）。
  static bool isPoemComplete(String text, String typed) =>
      normalizePoemInput(text) == normalizePoemInput(typed);

  /// 返回首个错误位置（0 基，相对原文规范化后的字符索引）；完全正确返回 -1。
  static int firstPoemErrorIndex(String text, String typed) {
    final t = normalizePoemInput(text);
    final i = normalizePoemInput(typed);
    final len = min(t.length, i.length);
    for (var k = 0; k < len; k++) {
      if (t[k] != i[k]) return k;
    }
    if (i.length < t.length) return i.length; // 未打完
    return -1;
  }

  // ---------- 步数 ----------

  /// 步数进度 = 当前累计 - 起始基线（不小于 0）。
  static int stepProgress(int stepStart, int stepCurrent) =>
      max(0, stepCurrent - stepStart);

  static bool isStepsComplete(int target, int progress) => progress >= target;

  // ---------- 摇动 ----------

  static bool isShakeComplete(int target, int count) => count >= target;

  // ---------- 任务参数 ----------

  /// 各任务默认目标值（type=steps/shake 无 difficulty 语义时）。
  static int defaultTarget(MissionType type) => switch (type) {
        MissionType.steps => 20,
        MissionType.shake => 10,
        _ => 0,
      };

  /// 取任务目标：steps/shake 用 config.target（0 则用默认档），其余 0。
  static int effectiveTarget(MissionConfig config) {
    if (config.type == MissionType.steps || config.type == MissionType.shake) {
      return config.target > 0 ? config.target : defaultTarget(config.type);
    }
    return 0;
  }

  /// 取任务难度对应的舒尔特格数或古诗难度。
  static int effectiveDifficulty(MissionConfig config) =>
      config.difficulty.clamp(1, 3);

  /// 取古诗：config.poemId 指定则用之，否则按难度随机。
  static Poem resolvePoem(MissionConfig config, {int? seed}) {
    if (config.poemId != null) {
      final byId = PoemBank.byId(config.poemId!);
      if (byId != null) return byId;
    }
    return PoemBank.randomByDifficulty(config.difficulty.clamp(1, 3), seed: seed);
  }
}
