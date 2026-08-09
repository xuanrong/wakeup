import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../utils/constants.dart';

/// 小鸭情绪（对应 VISUAL_SPEC.md 的表情状态机）。
enum DuckyMood {
  idle, // 歪头待机 / 眨眼（默认）
  urging, // 张嘴催促（嘎嘎）
  happy, // 眯眼大笑
  sleepy, // 困倦
}

/// 小鸭 IP 组件：优先播放 Lottie（assets/ducky/duck_walk_quack.json），
/// 图层尚未导出（全是空控制器）时自动回退到萌化 CustomPainter。
class Ducky extends StatefulWidget {
  const Ducky({
    super.key,
    this.size = 160,
    this.mood = DuckyMood.idle,
    this.repeat = true,
    this.lottieAsset = 'assets/ducky/duck_walk_quack.json',
  });

  final double size;
  final DuckyMood mood;

  /// Lottie 是否循环播放。
  final bool repeat;
  final String lottieAsset;

  @override
  State<Ducky> createState() => _DuckyState();
}

class _DuckyState extends State<Ducky> {
  bool? _hasVisibleLayers;

  @override
  void initState() {
    super.initState();
    _probe();
  }

  Future<void> _probe() async {
    bool visible;
    try {
      final raw = await rootBundle.loadString(widget.lottieAsset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final layers = json['layers'] as List? ?? const [];
      // 有任意非空图层（ty != 3 即不是空控制器）才算可用。
      visible = layers.any((l) {
        final m = l as Map;
        return m['ty'] != 3;
      });
    } catch (_) {
      visible = false;
    }
    if (mounted && _hasVisibleLayers != visible) {
      setState(() => _hasVisibleLayers = visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = Size.square(widget.size);
    if (_hasVisibleLayers == true) {
      return Lottie.asset(
        widget.lottieAsset,
        width: widget.size,
        height: widget.size,
        repeat: widget.repeat,
        fit: BoxFit.contain,
      );
    }
    return CustomPaint(size: size, painter: _DuckyPainter(widget.mood));
  }
}

/// 白鸭定稿造型（对齐「视觉设计规范」V5 图标）：
/// 暖白身体 + 粗黑描边 + 大椭圆黑眼（白底/虹膜/瞳/高光）+ 粉腮红 + 橙喙（双鼻孔）+ 卷毛。
class _DuckyPainter extends CustomPainter {
  const _DuckyPainter(this.mood);

  final DuckyMood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 512.0;

    const body = AppColors.duckBodyWarm; // 暖白
    const outline = AppColors.duckOutline; // 粗黑描边
    const beak = AppColors.duckBeak;
    const beakLight = AppColors.duckBeakLight;
    const iris = AppColors.duckIris;
    const eye = AppColors.ink;
    const blush = AppColors.duckBlush;
    const tongue = Color(0xFFFF6B6B);

    double X(double v) => v * s;
    double Y(double v) => v * s;

    final stroke = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = outline
      ..strokeWidth = X(8)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    // ---- 身体（圆胖椭圆 + 粗黑描边）----
    final bodyRect = Rect.fromCenter(
        center: Offset(X(256), Y(370)), width: X(300), height: X(270));
    canvas.drawOval(bodyRect, stroke..color = outline);
    canvas.drawOval(
        bodyRect.deflate(X(4)), fill..color = body);

    // 肚皮高光（暖白偏白）
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(X(256), Y(404)),
          width: X(180),
          height: X(150)),
      fill..color = AppColors.duckBodyWhite.withValues(alpha: 0.7),
    );

    // ---- 左侧曲线翅膀（3 条羽毛弧线，stroke-only）----
    final wing = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = outline
      ..strokeWidth = X(5)
      ..strokeCap = StrokeCap.round;
    final wingPaths = [
      Path()
        ..moveTo(X(96), Y(330))
        ..quadraticBezierTo(X(78), Y(356), X(92), Y(382)),
      Path()
        ..moveTo(X(108), Y(332))
        ..quadraticBezierTo(X(92), Y(358), X(104), Y(388)),
      Path()
        ..moveTo(X(120), Y(334))
        ..quadraticBezierTo(X(106), Y(360), X(118), Y(392)),
    ];
    for (final p in wingPaths) {
      canvas.drawPath(p, wing);
    }

    // ---- 头（大圆 + 粗黑描边）----
    final headCenter = Offset(X(256), Y(206));
    canvas.drawCircle(headCenter, X(126), stroke..color = outline);
    canvas.drawCircle(
        headCenter, X(126) - X(4), fill..color = body);

    // ---- 头顶卷毛（一笔曲线）----
    final curl = Path()
      ..moveTo(X(238), Y(88))
      ..quadraticBezierTo(X(224), Y(58), X(248), Y(34))
      ..quadraticBezierTo(X(268), Y(50), X(282), Y(80));
    canvas.drawPath(curl, Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..color = outline
      ..strokeWidth = X(8)
      ..strokeCap = StrokeCap.round);

    // ---- 腮红（粉，无描边）----
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(X(170), Y(246)), width: X(48), height: X(30)),
      fill..color = blush.withValues(alpha: 0.65),
    );
    canvas.drawOval(
      Rect.fromCenter(
          center: Offset(X(342), Y(246)), width: X(48), height: X(30)),
      fill..color = blush.withValues(alpha: 0.65),
    );

    // ---- 眼睛（按情绪）----
    switch (mood) {
      case DuckyMood.sleepy:
        canvas.drawPath(
          Path()
            ..moveTo(X(188), Y(200))
            ..quadraticBezierTo(X(210), Y(222), X(232), Y(200)),
          stroke..strokeWidth = X(9),
        );
        canvas.drawPath(
          Path()
            ..moveTo(X(280), Y(200))
            ..quadraticBezierTo(X(302), Y(222), X(324), Y(200)),
          stroke..strokeWidth = X(9),
        );
      case DuckyMood.happy:
        canvas.drawPath(
          Path()
            ..moveTo(X(186), Y(196))
            ..quadraticBezierTo(X(208), Y(176), X(230), Y(196)),
          stroke..strokeWidth = X(9),
        );
        canvas.drawPath(
          Path()
            ..moveTo(X(282), Y(196))
            ..quadraticBezierTo(X(304), Y(176), X(326), Y(196)),
          stroke..strokeWidth = X(9),
        );
      default:
        // 大椭圆黑眼：白底 + 虹膜 + 瞳 + 高光
        for (final cx in [208.0, 304.0]) {
          final eyeCenter = Offset(X(cx), Y(192));
          canvas.drawOval(
            Rect.fromCenter(
                center: eyeCenter, width: X(56), height: X(44)),
            fill..color = AppColors.duckBodyWhite,
          );
          canvas.drawOval(
            Rect.fromCenter(
                center: eyeCenter.translate(X(2), Y(2)),
                width: X(34),
                height: X(34)),
            fill..color = iris,
          );
          canvas.drawOval(
            Rect.fromCenter(
                center: eyeCenter.translate(X(4), Y(4)),
                width: X(17),
                height: X(17)),
            fill..color = eye,
          );
          canvas.drawCircle(
            eyeCenter.translate(X(10), Y(-7)), X(5), fill..color = Colors.white);
        }
    }

    // ---- 喙（按情绪）----
    switch (mood) {
      case DuckyMood.urging:
        final open = Path()
          ..moveTo(X(256), Y(238))
          ..quadraticBezierTo(X(216), Y(230), X(206), Y(258))
          ..quadraticBezierTo(X(204), Y(300), X(256), Y(314))
          ..quadraticBezierTo(X(308), Y(300), X(306), Y(258))
          ..quadraticBezierTo(X(296), Y(230), X(256), Y(238))
          ..close();
        canvas.drawPath(open, fill..color = beak);
        canvas.drawPath(open, stroke..color = outline);
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(X(256), Y(288)), width: X(52), height: X(18)),
          fill..color = tongue,
        );
      case DuckyMood.happy:
        final laugh = Path()
          ..moveTo(X(256), Y(238))
          ..quadraticBezierTo(X(216), Y(230), X(206), Y(258))
          ..quadraticBezierTo(X(204), Y(302), X(256), Y(316))
          ..quadraticBezierTo(X(308), Y(302), X(306), Y(258))
          ..quadraticBezierTo(X(296), Y(230), X(256), Y(238))
          ..close();
        canvas.drawPath(laugh, fill..color = beak);
        canvas.drawPath(laugh, stroke..color = outline);
        canvas.drawOval(
          Rect.fromCenter(
              center: Offset(X(256), Y(292)), width: X(56), height: X(20)),
          fill..color = tongue,
        );
      default:
        // 微笑闭嘴：上喙高光 + 下喙 + 双鼻孔
        final lower = Path()
          ..moveTo(X(256), Y(240))
          ..quadraticBezierTo(X(222), Y(232), X(210), Y(256))
          ..quadraticBezierTo(X(214), Y(284), X(256), Y(294))
          ..quadraticBezierTo(X(298), Y(284), X(302), Y(256))
          ..quadraticBezierTo(X(290), Y(232), X(256), Y(240))
          ..close();
        canvas.drawPath(lower, fill..color = beak);
        canvas.drawPath(lower, stroke..color = outline);
        final upper = Path()
          ..moveTo(X(256), Y(240))
          ..quadraticBezierTo(X(222), Y(232), X(210), Y(256))
          ..quadraticBezierTo(X(234), Y(266), X(278), Y(266))
          ..quadraticBezierTo(X(296), Y(258), X(302), Y(256))
          ..quadraticBezierTo(X(290), Y(232), X(256), Y(240))
          ..close();
        canvas.drawPath(upper, fill..color = beakLight);
        canvas.drawCircle(Offset(X(242), Y(248)), X(4), fill..color = outline);
        canvas.drawCircle(Offset(X(270), Y(248)), X(4), fill..color = outline);
    }
  }

  @override
  bool shouldRepaint(_DuckyPainter oldDelegate) => oldDelegate.mood != mood;
}
