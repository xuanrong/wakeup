import 'package:shared_preferences/shared_preferences.dart';

import '../data/local/prefs_alarm_repository.dart';
import '../data/local/prefs_mission_progress_repository.dart';
import '../data/local/prefs_stat_repository.dart';
import '../data/local/prefs_store.dart';
import '../data/repositories/alarm_repository.dart';
import '../data/repositories/mission_progress_repository.dart';
import '../data/repositories/stat_repository.dart';
import '../providers/alarm_provider.dart';
import '../providers/ringing_provider.dart';
import '../providers/stats_provider.dart';
import '../services/holiday_service.dart';

/// 依赖装配（Phase 1：全用 shared_preferences 实现）。
/// main.dart 初始化后注入 AppDeps；页面通过 Provider.of 取用。
class AppDeps {
  AppDeps._({
    required this.prefsStore,
    required this.alarmRepository,
    required this.statRepository,
    required this.missionProgressRepository,
    required this.holidayService,
    required this.alarmProvider,
    required this.ringingProvider,
    required this.statsProvider,
  });

  final PrefsStore prefsStore;
  final AlarmRepository alarmRepository;
  final StatRepository statRepository;
  final MissionProgressRepository missionProgressRepository;
  final HolidayService holidayService;
  final AlarmProvider alarmProvider;
  final RingingProvider ringingProvider;
  final StatsProvider statsProvider;

  static Future<AppDeps> create() async {
    final prefs = await SharedPreferences.getInstance();
    final store = PrefsStore(prefs);

    final alarmRepo = PrefsAlarmRepository(store);
    final statRepo = PrefsStatRepository(store);
    final progressRepo = PrefsMissionProgressRepository(store);

    final holidayService = HolidayService();
    final alarmProvider = AlarmProvider(alarmRepo, holidayService);
    final ringingProvider = RingingProvider(progressRepo);
    final statsProvider = StatsProvider(statRepo);

    final deps = AppDeps._(
      prefsStore: store,
      alarmRepository: alarmRepo,
      statRepository: statRepo,
      missionProgressRepository: progressRepo,
      holidayService: holidayService,
      alarmProvider: alarmProvider,
      ringingProvider: ringingProvider,
      statsProvider: statsProvider,
    );
    await deps.alarmProvider.load();
    await deps.statsProvider.load();
    return deps;
  }
}
