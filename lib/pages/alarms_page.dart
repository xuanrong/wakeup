import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/alarm_model.dart';
import '../models/mission_config.dart';
import '../providers/alarm_provider.dart';
import '../utils/constants.dart';
import '../widgets/ducky.dart';

/// 闹钟列表页（极简产品 + 萌系 IP + 卡片分格）：
/// 白鸭页头卡 + 每闹钟一张分组卡（时间格 | 信息格 | 开关格）。
class AlarmsPage extends StatelessWidget {
  const AlarmsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlarmProvider>();
    final alarms = provider.alarms;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => provider.load(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.pagePadding,
            AppDimens.pagePadding,
            AppDimens.pagePadding,
            96,
          ),
          children: [
            const _DuckHeader(),
            const SizedBox(height: AppDimens.gapL),
            Text(
              alarms.isEmpty ? '还没有闹钟' : '今日闹钟',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppDimens.gapM),
            if (alarms.isEmpty)
              const _EmptyState()
            else
              for (final a in alarms) ...[
                _AlarmCard(alarm: a),
                const SizedBox(height: AppDimens.gapM),
              ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.duckYellow,
        foregroundColor: AppColors.ink,
        shape: const StadiumBorder(),
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.alarmEdit),
        icon: const Icon(Icons.add),
        label: const Text('新建闹钟',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}

/// 白鸭页头卡：白鸭 IP + 下次响铃胶囊，卡片分格。
class _DuckHeader extends StatelessWidget {
  const _DuckHeader();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlarmProvider>();
    final next = provider.nextAlarm;
    return Container(
      padding: const EdgeInsets.all(AppDimens.gapL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppCards.groupRadius),
        border: Border.all(color: AppColors.greyLine),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Ducky(size: 96),
              const SizedBox(width: AppDimens.gapM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '醒醒鸭',
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: AppColors.ink,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: AppDimens.gapS),
                    Text(
                      AppTexts.tagline,
                      style: const TextStyle(
                          fontSize: 14, color: AppColors.greyText),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (next != null) ...[
            const SizedBox(height: AppDimens.gapL),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.duckYellow.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppCards.cellRadius),
              ),
              child: Row(
                children: [
                  const Icon(Icons.alarm, size: 18, color: AppColors.duckYellowDeep),
                  const SizedBox(width: AppDimens.gapS),
                  Text(
                    '${AppTexts.nextAlarmPrefix} ${next.timeText}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimens.gapXL),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppCards.groupRadius),
        border: Border.all(color: AppColors.greyLine),
      ),
      child: Column(
        children: [
          const Ducky(size: 140, mood: DuckyMood.sleepy),
          const SizedBox(height: AppDimens.gapM),
          Text(
            AppTexts.emptyAlarms,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.ink),
          ),
          const SizedBox(height: AppDimens.gapS),
          Text(
            AppTexts.emptyAlarmsSub,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: AppColors.greyText),
          ),
        ],
      ),
    );
  }
}

/// 闹钟分组卡：分上（时间格）下（信息格 + 开关格）两级。
class _AlarmCard extends StatelessWidget {
  const _AlarmCard({required this.alarm});

  final AlarmModel alarm;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AlarmProvider>();
    final disabled = !alarm.enabled;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppCards.groupRadius),
        border: Border.all(color: AppColors.greyLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 时间格
          InkWell(
            onTap: () => Navigator.of(context)
                .pushNamed(AppRoutes.alarmEdit, arguments: alarm.id),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppDimens.gapL, AppDimens.gapL, AppDimens.gapL, AppDimens.gapM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      alarm.timeText,
                      style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        height: 0.9,
                        letterSpacing: 0.5,
                        color: disabled
                            ? AppColors.greyText.withValues(alpha: 0.5)
                            : AppColors.ink,
                      ),
                    ),
                  ),
                  Icon(
                    disabled ? Icons.alarm_off : Icons.alarm_on,
                    color: disabled
                        ? AppColors.greyText.withValues(alpha: 0.6)
                        : AppColors.duckYellowDeep,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),
          // 分割线
          Container(height: 1, color: AppCards.divider),
          // 信息格：重复类型 + 标签 + 任务标签 + 开关
          Padding(
            padding: const EdgeInsets.all(AppDimens.gapM),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SubtitleRow(alarm: alarm, disabled: disabled),
                      const SizedBox(height: AppDimens.gapS),
                      _NextRing(alarm: alarm),
                      if (alarm.label.isNotEmpty) ...[
                        const SizedBox(height: AppDimens.gapS),
                        Text(alarm.label,
                            style: const TextStyle(
                                fontSize: 14, color: AppColors.ink)),
                      ],
                      if (alarm.missions.isNotEmpty) ...[
                        const SizedBox(height: AppDimens.gapM),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final m in alarm.missions) _MissionTag(m: m),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppDimens.gapS),
                Switch(
                  value: alarm.enabled,
                  onChanged: (v) => provider.toggleEnabled(alarm.id, v),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 重复类型 + 跳过节假日标签（胶囊分格）。
class _SubtitleRow extends StatelessWidget {
  const _SubtitleRow({required this.alarm, required this.disabled});

  final AlarmModel alarm;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final color =
        disabled ? AppColors.greyText.withValues(alpha: 0.7) : AppColors.greyText;
    final title = switch (alarm.scheduleType) {
      ScheduleType.daily => '每天',
      ScheduleType.weekday => '工作日',
      ScheduleType.legal => '仅法定工作日',
      ScheduleType.bigSmallWeek => '大小周',
      ScheduleType.custom => '自定义',
    };
    return Row(
      children: [
        Text(title, style: TextStyle(fontSize: 13, color: color)),
        if (alarm.skipHoliday)
          Row(
            children: [
              const SizedBox(width: AppDimens.gapS),
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.greyText,
                ),
              ),
              const SizedBox(width: AppDimens.gapS),
              Text('跳过节假日', style: TextStyle(fontSize: 13, color: color)),
            ],
          ),
      ],
    );
  }
}

/// 任务小标签（胶囊分格）。
class _MissionTag extends StatelessWidget {
  const _MissionTag({required this.m});

  final MissionConfig m;

  @override
  Widget build(BuildContext context) {
    final icon = switch (m.type) {
      MissionType.schulte => Icons.grid_on,
      MissionType.poem => Icons.menu_book,
      MissionType.steps => Icons.directions_walk,
      MissionType.shake => Icons.phone_android,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.duckYellow.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.duckYellowDeep),
          const SizedBox(width: 4),
          Text(
            m.displayName,
            style: const TextStyle(fontSize: 12, color: AppColors.ink),
          ),
        ],
      ),
    );
  }
}

/// 下次响铃时间小字。
class _NextRing extends StatelessWidget {
  const _NextRing({required this.alarm});

  final AlarmModel alarm;

  @override
  Widget build(BuildContext context) {
    if (!alarm.enabled) {
      return const Text('已停用',
          style: TextStyle(fontSize: 13, color: AppColors.greyText));
    }
    final next = context.read<AlarmProvider>().nextRingTime(alarm);
    if (next == null) {
      return const SizedBox.shrink();
    }
    final weekdays = ['', '一', '二', '三', '四', '五', '六', '日'];
    final label =
        '${next.month}/${next.day} 周${weekdays[next.weekday]} ${next.hour.toString().padLeft(2, '0')}:${next.minute.toString().padLeft(2, '0')}';
    return Text(label,
        style: const TextStyle(fontSize: 13, color: AppColors.greyText));
  }
}
