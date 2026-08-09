import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/mission_config.dart';
import '../providers/ringing_provider.dart';
import '../services/mission_service.dart';
import '../utils/constants.dart';
import '../widgets/ducky.dart';

/// 任务执行页：按配置顺序逐个完成（舒尔特/古诗/步数/摇动）。
/// 全部完成 → 停响铃 + 结算。
class MissionPage extends StatefulWidget {
  const MissionPage({super.key});

  @override
  State<MissionPage> createState() => _MissionPageState();
}

class _MissionPageState extends State<MissionPage> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RingingProvider>();
    final mission = provider.currentMission;

    if (mission == null) {
      // 无当前任务（理论上完成），返回响铃页或直接显示完成态。
      return const _DoneView();
    }

    return PopScope(
      canPop: false, // 返回只会回响铃页，任务不可跳过
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppDimens.gapM),
              _ProgressHeader(
                current: provider.currentMissionNumber,
                total: provider.totalMissions,
              ),
              const SizedBox(height: AppDimens.gapS),
              Text(mission.displayName,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppDimens.gapM),
              Expanded(child: _buildMissionBody(mission)),
              const Padding(
                padding: EdgeInsets.all(AppDimens.pagePadding),
                child: Text(AppTexts.missionExitHint,
                    style: TextStyle(fontSize: 13, color: AppColors.greyText)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionBody(MissionConfig mission) {
    return switch (mission.type) {
      MissionType.schulte => _SchulteBody(mission: mission),
      MissionType.poem => _PoemBody(mission: mission),
      MissionType.steps => _StepsBody(mission: mission),
      MissionType.shake => _ShakeBody(mission: mission),
    };
  }
}

/// 任务进度头：n / total + 完成打勾。
class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.pagePadding),
      child: Row(
        children: [
          Expanded(
            child: LinearProgressIndicator(
              value: current / total,
              backgroundColor: AppColors.greyLine,
              color: AppColors.duckYellow,
            ),
          ),
          const SizedBox(width: AppDimens.gapM),
          Text('$current / $total',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink)),
        ],
      ),
    );
  }
}

// ---------- 舒尔特 ----------

class _SchulteBody extends StatefulWidget {
  const _SchulteBody({required this.mission});

  final MissionConfig mission;

  @override
  State<_SchulteBody> createState() => _SchulteBodyState();
}

class _SchulteBodyState extends State<_SchulteBody> {
  late final int _size;
  late final List<int> _numbers;

  @override
  void initState() {
    super.initState();
    _size = MissionService.schulteGridSize(widget.mission.difficulty);
    _numbers = MissionService.schulteNumbers(_size,
        seed: DateTime.now().millisecondsSinceEpoch.toInt());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RingingProvider>();
    final clicked = provider.progress?.schulteClicked ?? const <int>[];
    final target = MissionService.nextSchulteTarget(clicked);

    return Column(
      children: [
        Text('按顺序点击 1 → ${_size * _size}',
            style: const TextStyle(fontSize: 14, color: AppColors.greyText)),
        Text('下一个：$target',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.duckYellow)),
        const SizedBox(height: AppDimens.gapM),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: _size,
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            for (var i = 0; i < _numbers.length; i++)
              _SchulteCell(
                num: _numbers[i],
                state: _cellState(_numbers[i], clicked, target),
                onTap: () => _onTap(provider, _numbers[i]),
              ),
          ],
        ),
      ],
    );
  }

  _CellState _cellState(int num, List<int> clicked, int target) {
    if (clicked.contains(num)) return _CellState.done;
    if (num == target) return _CellState.active;
    return _CellState.idle;
  }

  void _onTap(RingingProvider provider, int num) {
    final ok = provider.clickSchulte(num);
    HapticFeedback.lightImpact();
    if (ok) {
      provider.checkCurrentMission();
    }
  }
}

enum _CellState { idle, active, done }

class _SchulteCell extends StatelessWidget {
  const _SchulteCell({
    required this.num,
    required this.state,
    required this.onTap,
  });

  final int num;
  final _CellState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _CellState.idle => AppColors.white,
      _CellState.active => AppColors.duckYellow,
      _CellState.done => AppColors.greyLine,
    };
    final textColor = state == _CellState.done ? AppColors.greyText : AppColors.ink;
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Center(
          child: Text('$num',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor)),
        ),
      ),
    );
  }
}

// ---------- 古诗 ----------

class _PoemBody extends StatefulWidget {
  const _PoemBody({required this.mission});

  final MissionConfig mission;

  @override
  State<_PoemBody> createState() => _PoemBodyState();
}

class _PoemBodyState extends State<_PoemBody> {
  final TextEditingController _controller = TextEditingController();
  String? _poemText;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _poemText = context.read<RingingProvider>().resolvePoemText(widget.mission);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RingingProvider>();
    final typed = provider.progress?.poemTyped ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimens.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            color: AppColors.white,
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.gapM),
              child: Text(
                _poemText ?? '',
                style: const TextStyle(fontSize: 18, height: 1.9),
              ),
            ),
          ),
          const SizedBox(height: AppDimens.gapM),
          TextField(
            controller: _controller,
            autocorrect: false,
            enableSuggestions: false,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '照着输入这首诗（含标点）',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              provider.updatePoemTyped(v);
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 500), () {
                provider.checkCurrentMission();
              });
            },
          ),
          const SizedBox(height: AppDimens.gapM),
          Text('已输入 ${typed.length} / ${_poemText?.length ?? 0} 字',
              style: const TextStyle(fontSize: 13, color: AppColors.greyText)),
        ],
      ),
    );
  }
}

// ---------- 步数 ----------

class _StepsBody extends StatefulWidget {
  const _StepsBody({required this.mission});

  final MissionConfig mission;

  @override
  State<_StepsBody> createState() => _StepsBodyState();
}

class _StepsBodyState extends State<_StepsBody> {
  int _current = 0;
  int _baseline = 0;

  @override
  void initState() {
    super.initState();
    final provider = context.read<RingingProvider>();
    _baseline = provider.progress?.stepStart ?? 0;
    if (_baseline == 0) {
      // MVP：无 pedometer 时用计数器模拟（设置基线后按步计）。真实传感器第 10 步接入。
      _baseline = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RingingProvider>();
    final target = MissionService.effectiveTarget(widget.mission);
    final progress = (_current - _baseline).clamp(0, target);

    return Column(
      children: [
        Text('走够 $target 步',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppDimens.gapL),
        SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: progress / target,
                strokeWidth: 12,
                backgroundColor: AppColors.greyLine,
                color: AppColors.duckYellow,
              ),
              Text('$progress / $target',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
        const SizedBox(height: AppDimens.gapL),
        // MVP 调试：模拟走一步（真实 pedometer 接入后移除）。
        ElevatedButton.icon(
          onPressed: () {
            setState(() => _current++);
            HapticFeedback.heavyImpact();
            provider.checkCurrentMission(stepsCurrent: _current);
          },
          icon: const Icon(Icons.directions_walk),
          label: const Text('模拟走一步'),
        ),
      ],
    );
  }
}

// ---------- 摇动 ----------

class _ShakeBody extends StatefulWidget {
  const _ShakeBody({required this.mission});

  final MissionConfig mission;

  @override
  State<_ShakeBody> createState() => _ShakeBodyState();
}

class _ShakeBodyState extends State<_ShakeBody> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RingingProvider>();
    final target = MissionService.effectiveTarget(widget.mission);

    return Column(
      children: [
        Text('摇动 $target 次',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppDimens.gapL),
        Text('$_count',
            style: const TextStyle(
                fontSize: 64, fontWeight: FontWeight.w800, color: AppColors.duckYellow)),
        Text('/ $target', style: const TextStyle(color: AppColors.greyText)),
        const SizedBox(height: AppDimens.gapL),
        // MVP 调试：模拟摇一次（真实加速度计接入后移除）。
        ElevatedButton.icon(
          onPressed: () {
            setState(() => _count++);
            HapticFeedback.heavyImpact();
            provider.checkCurrentMission(shakeCount: _count);
          },
          icon: const Icon(Icons.phone_android),
          label: const Text('模拟摇一下'),
        ),
      ],
    );
  }
}

/// 无任务/全部完成时的兜底视图（通常不会展示）。
class _DoneView extends StatelessWidget {
  const _DoneView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Ducky(size: 140, mood: DuckyMood.happy),
            SizedBox(height: AppDimens.gapM),
            Text(AppTexts.finishMission,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}
