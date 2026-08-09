import 'package:flutter/material.dart';

import 'app.dart';
import 'app_deps.dart';
import 'services/alarm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 依赖装配（shared_preferences 初始化 + 闹钟加载）。
  final deps = await AppDeps.create();

  // 冷启动分流：读本次响铃 alarmId，有值则只渲染响铃页（跳过开屏/首页）。
  final startAlarmId = await AlarmService.getStartAlarmId();

  runApp(WakeupApp(deps: deps, startAlarmId: startAlarmId));
}
