import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/daily_stat.dart';
import '../providers/stats_provider.dart';
import '../utils/constants.dart';
import '../widgets/ducky.dart';

/// 统计页（极简 + 卡片分格）：白鸭小头 + 2×2 数据格墙 + 最近 7 天分格条。
class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatsProvider>();
    final week = provider.summaryForWeek();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppDimens.pagePadding),
          children: [
            Row(
              children: [
                const Ducky(size: 64, mood: DuckyMood.happy),
                const SizedBox(width: AppDimens.gapM),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '起床统计',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: AppDimens.gapS),
                      Text('看看今天鸭鸭有多高兴',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.greyText)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapL),
            // 2×2 数据格墙
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _StatCell(label: '本周起床率', value: week.rate == null ? '--' : '${(week.rate! * 100).round()}%', sub: '成功 ${week.successDays} 天', accent: AppColors.duckYellowDeep)),
                const SizedBox(width: AppDimens.gapM),
                Expanded(child: _StatCell(label: '连续早起', value: '${week.streakDays}', sub: '天', accent: AppColors.duckYellow)),
              ],
            ),
            const SizedBox(height: AppDimens.gapM),
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _StatCell(label: '本周早起', value: '${week.successDays}', sub: '天', accent: AppColors.duckBeak)),
                const SizedBox(width: AppDimens.gapM),
                Expanded(child: _StatCell(label: '本周闹钟', value: '${week.successDays + week.failedDays}', sub: '天', accent: AppColors.ink)),
              ],
            ),
            const SizedBox(height: AppDimens.gapL),
            const Text('最近 7 天',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink)),
            const SizedBox(height: AppDimens.gapM),
            // 7 天分格条
            Container(
              padding: const EdgeInsets.all(AppDimens.gapM),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppCards.groupRadius),
                border: Border.all(color: AppColors.greyLine),
              ),
              child: Row(
                children: [
                  for (final s in provider.recentDays(7)) ...[
                    Expanded(child: _DayCell(stat: s)),
                    if (s != provider.recentDays(7).last)
                      const SizedBox(width: 6),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppDimens.gapL),
            Center(
              child: Ducky(size: 88, mood: DuckyMood.happy),
            ),
            const SizedBox(height: AppDimens.gapL),
          ],
        ),
      ),
    );
  }
}

/// 单个数据格（卡片分格之"卡格"）。
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.sub,
    required this.accent,
  });

  final String label;
  final String value;
  final String sub;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppCards.cellPadding),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppCards.cellRadius),
        border: Border.all(color: AppColors.greyLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.greyText)),
          const SizedBox(height: AppDimens.gapS),
          Text(value,
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                  color: accent)),
          const SizedBox(height: AppDimens.gapS),
          Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.greyText)),
        ],
      ),
    );
  }
}

/// 7 天分格条中的单天格。
class _DayCell extends StatelessWidget {
  const _DayCell({required this.stat});

  final DailyStat stat;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['', '一', '二', '三', '四', '五', '六', '日'];
    final (icon, color) = switch ((stat.hasAlarm, stat.gotUp)) {
      (true, true) => (Icons.check, AppColors.success),
      (true, false) => (Icons.close, AppColors.danger),
      _ => (Icons.remove, AppColors.greyText),
    };
    return Column(
      children: [
        Text(weekdays[stat.date.weekday],
            style: const TextStyle(fontSize: 12, color: AppColors.greyText)),
        const SizedBox(height: AppDimens.gapS),
        Icon(icon, color: color, size: 22),
      ],
    );
  }
}
