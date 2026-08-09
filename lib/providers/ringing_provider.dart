import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/repositories/mission_progress_repository.dart';
import '../models/alarm_model.dart';
import '../models/mission_config.dart';
import '../services/alarm_service.dart';
import '../services/mission_service.dart';

/// 响铃状态机（见设计文档 4.4）：单方向推进，任务页回响铃页不倒退。
enum RingStage {
  preview,
  stage1,
  stage2,
  stage3,
  stage4,
  mission,
  done,
}

/// 响铃页状态管理：当前闹钟 + 任务进度（alarmId+日期防串续做）。
class RingingProvider extends ChangeNotifier {
  RingingProvider(this._progressRepo);

  final MissionProgressRepository _progressRepo;

  AlarmModel? _alarm;
  RingStage _stage = RingStage.stage1;
  MissionProgress? _progress;
  DateTime? _startedAt;
  Timer? _stageTimer;
  bool _completed = false;

  /// 本次响铃触发日期（yyyy-MM-dd，本地）。
  String triggerDate = '';

  AlarmModel? get alarm => _alarm;
  RingStage get stage => _stage;
  MissionProgress? get progress => _progress;
  DateTime? get startedAt => _startedAt;
  bool get completed => _completed;

  /// 当前任务配置。
  MissionConfig? get currentMission {
    if (_alarm == null || _progress == null) return null;
    final missions = _alarm!.missions;
    if (missions.isEmpty) return null;
    final idx = _progress!.currentIndex.clamp(0, missions.length - 1);
    return missions[idx];
  }

  /// 当前任务在总任务中的序号（1 起）。
  int get currentMissionNumber {
    final p = _progress;
    if (p == null) return 1;
    return p.currentIndex + 1;
  }

  int get totalMissions => _alarm?.missions.length ?? 0;

  /// 初始化：加载闹钟 + 校验进度（匹配才续做，否则重置）。
  Future<void> start({
    required AlarmModel alarm,
    required DateTime triggerTime,
  }) async {
    _alarm = alarm;
    _startedAt = DateTime.now();
    triggerDate = _dateKey(triggerTime);

    final saved = await _progressRepo.load(alarm.id, triggerDate);
    if (saved != null && _validFor(saved, alarm)) {
      _progress = saved;
    } else {
      _progress = MissionProgress(
        alarmId: alarm.id,
        triggerDate: triggerDate,
        missionStartAt: _startedAt,
      );
      await _persist();
    }

    // 无任务配置则直接完成（防御）。
    if (alarm.missions.isEmpty) {
      await complete();
      return;
    }

    _stage = RingStage.stage1;
    notifyListeners();
    _startStageAdvance();
  }

  bool _validFor(MissionProgress p, AlarmModel alarm) =>
      p.alarmId == alarm.id && p.triggerDate == triggerDate;

  /// 渐进鸭群集结（MVP 简化：stage1→4 每 5s 推进）。
  void _startStageAdvance() {
    _stageTimer?.cancel();
    if (_stage == RingStage.mission || _stage == RingStage.done) return;
    _stageTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_stage == RingStage.stage4) return;
      _stage = _nextStage(_stage);
      notifyListeners();
    });
  }

  RingStage _nextStage(RingStage s) => switch (s) {
        RingStage.stage1 => RingStage.stage2,
        RingStage.stage2 => RingStage.stage3,
        RingStage.stage3 => RingStage.stage4,
        _ => s,
      };

  /// 进入任务页。
  void enterMission() {
    _stageTimer?.cancel();
    _stage = RingStage.mission;
    notifyListeners();
  }

  // ---------- 舒尔特 ----------

  /// 点击数字：正确则记录并返回 true；错误返回 false（上层播放错误音）。
  bool clickSchulte(int num) {
    final p = _progress;
    if (p == null) return false;
    if (MissionService.isSchulteCorrect(p.schulteClicked, num)) {
      _progress = p.copyWith(schulteClicked: [...p.schulteClicked, num]);
      _persist();
      notifyListeners();
      return true;
    }
    return false;
  }

  // ---------- 古诗 ----------

  void updatePoemTyped(String text) {
    final p = _progress;
    if (p == null) return;
    _progress = p.copyWith(poemTyped: text);
    _persist();
    notifyListeners();
  }

  // ---------- 步数 / 摇动 ----------

  void setStepStart(int value) {
    final p = _progress;
    if (p == null) return;
    if (p.stepStart == 0) {
      _progress = p.copyWith(stepStart: value);
      _persist();
      notifyListeners();
    }
  }

  void setShakeCount(int value) {
    final p = _progress;
    if (p == null) return;
    _progress = p.copyWith(shakeCount: value);
    _persist();
    notifyListeners();
  }

  // ---------- 完成判定 ----------

  /// 检查当前任务是否完成；完成则推进到下一个任务或全部结束。
  /// [stepsCurrent]：步数任务当前累计值（相对基线算差值）。
  /// [shakeCount]：摇动任务已计次数。
  Future<void> checkCurrentMission({
    int? stepsCurrent,
    int? shakeCount,
  }) async {
    final p = _progress;
    final mission = currentMission;
    if (p == null || mission == null) return;

    bool doneNow = false;
    switch (mission.type) {
      case MissionType.schulte:
        final size = MissionService.schulteGridSize(mission.difficulty);
        doneNow = p.schulteClicked.length >= size * size;
      case MissionType.poem:
        doneNow = MissionService.isPoemComplete(
          resolvePoemText(mission),
          p.poemTyped,
        );
      case MissionType.steps:
        final target = MissionService.effectiveTarget(mission);
        doneNow = stepsCurrent != null &&
            MissionService.stepProgress(p.stepStart, stepsCurrent) >= target;
      case MissionType.shake:
        final target = MissionService.effectiveTarget(mission);
        doneNow = shakeCount != null && shakeCount >= target;
    }

    if (!doneNow) return;

    final missions = _alarm!.missions;
    final nextIdx = p.currentIndex + 1;
    final completed = [...p.completed, mission.type.name];

    if (nextIdx >= missions.length) {
      await complete();
      return;
    }
    _progress = MissionProgress(
      alarmId: p.alarmId,
      triggerDate: p.triggerDate,
      currentIndex: nextIdx,
      completed: completed,
      missionStartAt: p.missionStartAt,
    );
    await _persist();
    notifyListeners();
  }

  /// 古诗任务：把 resolvePoem 的文本缓存，供比对。由 MissionPage 调用。
  PoemTextCache? _poemCache;

  String resolvePoemText(MissionConfig mission) {
    if (_poemCache == null || _poemCache!.config != mission) {
      final poem = MissionService.resolvePoem(mission);
      _poemCache = PoemTextCache(mission, poem.fullText);
    }
    return _poemCache!.text;
  }

  /// 全部任务完成：停响铃 + 清理进度 + 进入结算。
  Future<void> complete() async {
    if (_completed) return;
    _completed = true;
    _stageTimer?.cancel();
    _stage = RingStage.done;
    await AlarmService.stopRinging();
    if (_progress != null) {
      await _progressRepo.delete(_progress!.alarmId, _progress!.triggerDate);
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = _progress;
    if (p == null) return;
    await _progressRepo.save(p);
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _stageTimer?.cancel();
    super.dispose();
  }
}

/// 古诗文本缓存（同一任务配置保持同一首诗）。
class PoemTextCache {
  const PoemTextCache(this.config, this.text);

  final MissionConfig config;
  final String text;
}
