import 'package:flutter/material.dart';

import '../utils/constants.dart';
import 'alarms_page.dart';
import 'profile_page.dart';
import 'stats_page.dart';

/// 主框架：底部导航（闹钟 / 统计 / 我的），极简白底 + 卡片化指示。
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;

  static const _pages = [AlarmsPage(), StatsPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border(
            top: BorderSide(color: AppColors.greyLine, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.access_alarm_outlined),
                selectedIcon: Icon(Icons.access_alarm,
                    color: AppColors.duckYellowDeep),
                label: '闹钟',
              ),
              NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart,
                    color: AppColors.duckYellowDeep),
                label: '统计',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person,
                    color: AppColors.duckYellowDeep),
                label: '我的',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
