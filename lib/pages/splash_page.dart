import 'package:flutter/material.dart';

import '../utils/constants.dart';
import '../widgets/ducky.dart';

/// 开屏页：白鸭 + 品牌字（卡片分格徽章）。冷启动响铃时由 main 跳过此页（短版处理）。
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRoutes.root);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Ducky(size: 160),
            const SizedBox(height: AppDimens.gapXL),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.gapXL, vertical: AppDimens.gapM),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppCards.groupRadius),
                border: Border.all(color: AppColors.greyLine),
              ),
              child: const Column(
                children: [
                  Text('醒醒鸭',
                      style: TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: AppColors.ink)),
                  SizedBox(height: AppDimens.gapS),
                  Text(AppTexts.tagline,
                      style:
                          TextStyle(fontSize: 15, color: AppColors.greyText)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
