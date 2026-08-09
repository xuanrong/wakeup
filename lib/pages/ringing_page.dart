import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/alarm_provider.dart';
import '../providers/ringing_provider.dart';
import '../services/alarm_service.dart';
import '../utils/constants.dart';
import '../widgets/ducky.dart';

/// 全屏响铃页：鸭群集结动画（Stage 1→4 鸭子递增）+ 开始任务按钮。
/// 无关闭按钮、拦截返回键（无贪睡）。
class RingingPage extends StatefulWidget {
  const RingingPage({super.key, this.initialAlarmId});

  /// 冷启动时原生传入的 alarmId。
  final String? initialAlarmId;

  @override
  State<RingingPage> createState() => _RingingPageState();
}

class _RingingPageState extends State<RingingPage> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _init();
  }

  Future<void> _init() async {
    final provider = context.read<RingingProvider>();
    if (provider.alarm != null) return;

    final alarmProvider = context.read<AlarmProvider>();

    // alarmId 来源：initialAlarmId（冷启动）> 路由参数 > 原生 getStartAlarmId。
    final arg = ModalRoute.of(context)?.settings.arguments;
    String? alarmId = widget.initialAlarmId ?? (arg is String ? arg : null);
    alarmId ??= await _startAlarmId();

    if (!mounted) return;
    final alarm = alarmProvider.byId(alarmId ?? '');
    if (alarm == null) return; // 找不到闹钟则停留在加载态

    await provider.start(alarm: alarm, triggerTime: DateTime.now());
  }

  Future<String?> _startAlarmId() async {
    try {
      return await AlarmService.getStartAlarmId();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RingingProvider>();
    final alarm = provider.alarm;

    // 冷启动/直达时若无闹钟，自动用默认配置初始化（防御）。
    if (alarm == null) {
      return const _LoadingView();
    }

    // 任务完成 → 结算页。
    if (provider.stage == RingStage.done) {
      return const _DoneView();
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.ink,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppDimens.gapL),
              _Header(stage: provider.stage),
              const Spacer(),
              _DuckArmy(stage: provider.stage),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(AppDimens.pagePadding),
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    provider.enterMission();
                    Navigator.of(context).pushNamed(AppRoutes.mission);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.duckYellow,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  child: const Text(AppTexts.startMission),
                ),
              ),
              const SizedBox(height: AppDimens.gapM),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Ducky(size: 120, mood: DuckyMood.urging),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.stage});

  final RingStage stage;

  @override
  Widget build(BuildContext context) {
    final label = switch (stage) {
      RingStage.stage1 => '独鸭开场',
      RingStage.stage2 => '呼应',
      RingStage.stage3 => '集结',
      RingStage.stage4 => '大军压境',
      _ => '',
    };
    return Column(
      children: [
        Text(
          AppTexts.ringingTitle,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(label,
                style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white.withValues(alpha: 0.6))),
          ),
      ],
    );
  }
}

/// 鸭群：stage 越高鸭子越多。
class _DuckArmy extends StatelessWidget {
  const _DuckArmy({required this.stage});

  final RingStage stage;

  int get _count => switch (stage) {
        RingStage.stage1 => 1,
        RingStage.stage2 => 3,
        RingStage.stage3 => 6,
        RingStage.stage4 => 10,
        _ => 1,
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < _count; i++) _positionedDuck(i),
        ],
      ),
    );
  }

  Widget _positionedDuck(int i) {
    final offset = _offsetFor(i);
    final size = _sizeFor(i);
    final mood = i == 0 ? DuckyMood.urging : DuckyMood.idle;
    return Positioned(
      left: offset.dx,
      top: offset.dy,
      child: Ducky(size: size, mood: mood),
    );
  }

  Offset _offsetFor(int i) {
    // 简单螺旋排布：主鸭居中，其余围绕。
    if (i == 0) return const Offset(170, 40);
    const angleStep = math.pi * 2 / 3;
    final r = 110.0;
    final angle = angleStep * (i - 1);
    return Offset(170 + r * math.cos(angle), 70 + r * math.sin(angle));
  }

  double _sizeFor(int i) => i == 0 ? 160 : 90;
}

/// 结算页：任务完成后的庆祝视图。
class _DoneView extends StatelessWidget {
  const _DoneView();

  @override
  Widget build(BuildContext context) {
    final provider = context.read<RingingProvider>();
    final startedAt = provider.startedAt;
    final seconds = startedAt == null
        ? 0
        : DateTime.now().difference(startedAt).inSeconds;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            const Ducky(size: 200, mood: DuckyMood.happy),
            const SizedBox(height: AppDimens.gapL),
            const Text(AppTexts.finishMission,
                style: TextStyle(
                    fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.ink)),
            const SizedBox(height: AppDimens.gapM),
            Text('用时 ${_fmt(seconds)}',
                style: const TextStyle(fontSize: 15, color: AppColors.greyText)),
            const SizedBox(height: AppDimens.gapL),
            ElevatedButton(
              onPressed: () {
                // 回到首页（响铃完成后可正常返回）。
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
              child: const Text('好的，我起床了'),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  String _fmt(int s) {
    final m = s ~/ 60;
    final sec = s % 60;
    return m > 0 ? '$m 分 $sec 秒' : '$sec 秒';
  }
}
