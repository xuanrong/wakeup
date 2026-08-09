import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_deps.dart';
import 'pages/alarm_edit_page.dart';
import 'pages/main_scaffold.dart';
import 'pages/mission_page.dart';
import 'pages/ringing_page.dart';
import 'pages/splash_page.dart';
import 'providers/alarm_provider.dart';
import 'providers/ringing_provider.dart';
import 'providers/stats_provider.dart';
import 'utils/constants.dart';

/// MaterialApp + 路由表 + Provider 装配。
/// 响铃路由由 [navigateToRinging] 统一入口触发（App 存活时）。
class WakeupApp extends StatelessWidget {
  const WakeupApp({super.key, required this.deps, this.startAlarmId});

  final AppDeps deps;

  /// 冷启动响铃的 alarmId（非空则直接进响铃页）。
  final String? startAlarmId;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AlarmProvider>.value(value: deps.alarmProvider),
        ChangeNotifierProvider<RingingProvider>.value(value: deps.ringingProvider),
        ChangeNotifierProvider<StatsProvider>.value(value: deps.statsProvider),
      ],
      child: MaterialApp(
        title: '醒醒鸭',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        initialRoute: startAlarmId != null ? AppRoutes.ringing : AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashPage(),
          AppRoutes.root: (_) => const MainScaffold(),
          AppRoutes.alarmEdit: (_) => const AlarmEditPage(),
          AppRoutes.ringing: (_) => RingingPage(initialAlarmId: startAlarmId),
          AppRoutes.mission: (_) => const MissionPage(),
        },
      ),
    );
  }

  ThemeData _buildTheme() {
    const ink = AppColors.ink;
    final base = ThemeData(
      useMaterial3: true,
      fontFamilyFallback: const ['PingFang SC', 'Noto Sans SC', 'sans-serif'],
    );
    final text = base.textTheme;
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.duckYellow,
        surface: AppColors.paper,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: AppColors.paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: ink,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppCards.groupRadius)),
          side: BorderSide(color: AppColors.greyLine, width: 1),
        ),
      ),
      textTheme: base.textTheme
          .copyWith(
            headlineLarge: const TextStyle(
              color: ink,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: 0.5,
            ),
            headlineMedium: const TextStyle(
              color: ink,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            titleLarge: text.titleLarge?.copyWith(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            bodyLarge: text.bodyLarge?.copyWith(
              color: ink,
              fontSize: 16,
              height: 1.5,
            ),
            bodyMedium: text.bodyMedium?.copyWith(
              color: ink,
              fontSize: 15,
              height: 1.5,
            ),
          )
          .apply(bodyColor: ink, displayColor: ink),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.duckYellow,
          foregroundColor: ink,
          shape: const StadiumBorder(),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: AppColors.white, fontSize: 15),
        behavior: SnackBarBehavior.floating,
        shape: StadiumBorder(),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.duckYellow
                : AppColors.white),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.duckYellow.withValues(alpha: 0.35)
                : AppColors.greyLine),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.white,
        indicatorColor: AppColors.duckYellow.withValues(alpha: 0.18),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink)
                : const TextStyle(fontSize: 12, color: AppColors.greyText)),
        iconTheme: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? const IconThemeData(color: AppColors.duckYellowDeep)
                : const IconThemeData(color: AppColors.greyText)),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: AppColors.duckYellow,
        backgroundColor: AppColors.cardBg,
        labelStyle: const TextStyle(color: AppColors.ink, fontSize: 13),
        side: BorderSide.none,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: AppColors.duckYellow, width: 1.5),
        ),
      ),
    );
  }
}

/// 应用存活时，外部（原生 onRing 事件）调用此入口推响铃页。
void navigateToRinging(BuildContext context) {
  Navigator.of(context, rootNavigator: true).pushNamed(AppRoutes.ringing);
}
