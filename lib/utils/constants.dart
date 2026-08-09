import 'package:flutter/material.dart';

/// 全局常量：颜色 / 尺寸 / 文案。
/// 设计基准见「视觉设计规范（图标·动画·小鸭IP）.md」与 assets/branding/VISUAL_SPEC.md（白鸭定稿）。
class AppColors {
  AppColors._();

  // ---- 主色系（鸭黄，唯一强调色）----
  static const Color duckYellow = Color(0xFFFFC400);
  static const Color duckYellowLight = Color(0xFFFFD94A);
  static const Color duckYellowDeep = Color(0xFFFFB300);
  static const Color duckDark = Color(0xFFF5A800);

  // ---- 白鸭 IP 定稿色 ----
  static const Color duckBodyWarm = Color(0xFFF5F0E8); // 身体暖白
  static const Color duckBodyWhite = Color(0xFFFFFFFF); // 身体纯白
  static const Color duckOutline = Color(0xFF1A1A1A); // 粗黑描边
  static const Color duckWing = Color(0xFFEBE5DB); // 翅暖白
  static const Color duckBeak = Color(0xFFFF8C00); // 喙橙（深）
  static const Color duckBeakLight = Color(0xFFFFB040); // 喙高光橙
  static const Color duckIris = Color(0xFFD4691A); // 虹膜橙
  static const Color duckLeg = Color(0xFFF0980C); // 腿橙
  static const Color duckFoot = Color(0xFFFFAA33); // 脚蹼橙
  static const Color duckBlush = Color(0xFFF2C4B3); // 腮红粉

  // ---- 中性（极简：白底 + 浅灰卡片）----
  static const Color ink = Color(0xFF1A1A1A);
  static const Color paper = Color(0xFFFAFAF8);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color greyText = Color(0xFF9A9A9A);
  static const Color greyLine = Color(0xFFEFEEEA);

  // 语义
  static const Color danger = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);
  static const Color restTag = Color(0xFF9E9E9E);
  static const Color makeupTag = Color(0xFFFF8A00);
  static const Color bigWeekTag = Color(0xFF4E89F7);
}

/// 卡片分格（Segmented Cards）设计令牌：页面信息按「卡组 → 卡格」两级分格。
class AppCards {
  AppCards._();

  /// 卡组：整卡圆角（分格容器）。
  static const double groupRadius = 28;

  /// 卡格：单个信息格圆角（组内小格）。
  static const double cellRadius = 18;

  /// 卡格分割线样式（组内竖切 / 横切）。
  static const Color divider = AppColors.greyLine;

  /// 卡格内间距。
  static const double cellPadding = 14;
}

class AppDimens {
  AppDimens._();

  static const double cardRadius = 24;
  static const double buttonRadius = 28;
  static const double pagePadding = 20;
  static const double gapS = 8;
  static const double gapM = 16;
  static const double gapL = 24;
  static const double gapXL = 32;
}

class AppRoutes {
  AppRoutes._();

  static const String root = '/';
  static const String splash = '/splash';
  static const String alarmEdit = '/alarm-edit';
  static const String ringing = '/ringing';
  static const String mission = '/mission';
}

class AppTexts {
  AppTexts._();

  // 顶部诙谐文案
  static const String tagline = '设置一个闹钟，鸭鸭叫你起床';
  static const String nextAlarmPrefix = '下次闹钟';
  static const String emptyAlarms = '还没有闹钟，鸭子很寂寞';
  static const String emptyAlarmsSub = '点下方按钮，让鸭鸭来喊你';
  static const String startMission = '开始起床任务';
  static const String finishMission = '不错，你是真鸭子！';
  static const String ringingTitle = '嘎嘎嘎！';
  static const String missionExitHint = '响着你也睡不着，不如做任务！';
}
