import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/alarm_provider.dart';
import '../services/alarm_service.dart';
import '../utils/constants.dart';
import '../widgets/ducky.dart';

/// 我的页（极简 + 卡片分格）：白鸭小头 + 分格设置列表（卡组 → 卡格）。
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
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
                        '我的',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.ink,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(height: AppDimens.gapS),
                      Text('醒醒鸭 · v1.0.0',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.greyText)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimens.gapL),
            // 卡组：个性化
            const _Group(
              title: '个性化',
              children: [
                _Tile(icon: Icons.volume_up, title: '音效包', subtitle: '疯狂鸭子'),
                _Tile(icon: Icons.palette_outlined, title: '主题', subtitle: '素白极简'),
                _Tile(icon: Icons.nightlight_outlined, title: '暗夜模式', subtitle: '22:00-6:00 自动'),
              ],
            ),
            const SizedBox(height: AppDimens.gapL),
            // 卡组：其他（含 Debug 响铃测试）
            _Group(
              title: '其他',
              children: [
                const _Tile(icon: Icons.info_outline, title: '关于', subtitle: 'v1.0.0'),
                if (kDebugMode)
                  _Tile(
                    icon: Icons.notifications_active,
                    title: '立即响铃测试',
                    subtitle: 'Debug 入口',
                    onTap: () async {
                      if (context.read<AlarmProvider>().alarms.isEmpty) return;
                      await AlarmService.triggerTest();
                    },
                  ),
              ],
            ),
            const SizedBox(height: AppDimens.gapL),
            Center(
              child: Ducky(size: 88, mood: DuckyMood.idle),
            ),
          ],
        ),
      ),
    );
  }
}

/// 设置卡组（分格容器）。
class _Group extends StatelessWidget {
  const _Group({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppDimens.gapS),
          child: Text(title,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.greyText)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppCards.groupRadius),
            border: Border.all(color: AppColors.greyLine),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 56),
                    color: AppCards.divider,
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// 设置卡格（单项）。
class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppCards.cellPadding, vertical: AppDimens.gapM),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.duckYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppCards.cellRadius),
              ),
              child: Icon(icon, size: 20, color: AppColors.duckYellowDeep),
            ),
            const SizedBox(width: AppDimens.gapM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!,
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.greyText)),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.greyText),
          ],
        ),
      ),
    );
  }
}
