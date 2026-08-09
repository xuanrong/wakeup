import 'package:flutter_test/flutter_test.dart';
import 'package:wakeup/data/poem_bank.dart';
import 'package:wakeup/models/mission_config.dart';
import 'package:wakeup/services/mission_service.dart';

void main() {
  group('舒尔特', () {
    test('难度→格数', () {
      expect(MissionService.schulteGridSize(1), 3);
      expect(MissionService.schulteGridSize(2), 4);
      expect(MissionService.schulteGridSize(3), 5);
    });

    test('数字乱序且覆盖 1..n', () {
      final nums = MissionService.schulteNumbers(4, seed: 42);
      expect(nums.length, 16);
      final sorted = [...nums]..sort();
      expect(sorted, List.generate(16, (i) => i + 1));
    });

    test('目标顺序判定', () {
      expect(MissionService.nextSchulteTarget(const []), 1);
      expect(MissionService.nextSchulteTarget(const [1, 2]), 3);
      expect(MissionService.isSchulteCorrect(const [1], 2), isTrue);
      expect(MissionService.isSchulteCorrect(const [1], 3), isFalse);
    });
  });

  group('古诗比对', () {
    test('完全匹配', () {
      final p = PoemBank.byId('jueju_001')!;
      expect(MissionService.isPoemComplete(p.fullText, p.fullText), isTrue);
    });

    test('半角标点等价全角', () {
      final p = PoemBank.byId('jueju_001')!;
      final typed = p.lines.join().replaceAll('，', ',').replaceAll('。', '.');
      expect(MissionService.isPoemComplete(p.fullText, typed), isTrue);
    });

    test('忽略首尾与空白', () {
      final p = PoemBank.byId('jueju_001')!;
      expect(MissionService.isPoemComplete(' ${p.fullText} ', p.fullText), isTrue);
    });

    test('错字判定', () {
      final p = PoemBank.byId('jueju_001')!;
      final wrong = p.fullText.replaceFirst('床', '窗');
      expect(MissionService.isPoemComplete(p.fullText, wrong), isFalse);
    });

    test('首个错误位置', () {
      final p = PoemBank.byId('jueju_001')!;
      expect(MissionService.firstPoemErrorIndex(p.fullText, p.fullText), -1);
      expect(MissionService.firstPoemErrorIndex(p.fullText, '床'), 1);
      expect(MissionService.firstPoemErrorIndex(p.fullText, '床前'), 2);
    });
  });

  group('步数/摇动', () {
    test('步数差值', () {
      expect(MissionService.stepProgress(1000, 1015), 15);
      expect(MissionService.stepProgress(1000, 990), 0); // 负值兜底
    });

    test('完成判定', () {
      expect(MissionService.isStepsComplete(20, 20), isTrue);
      expect(MissionService.isStepsComplete(20, 19), isFalse);
      expect(MissionService.isShakeComplete(10, 10), isTrue);
    });
  });

  group('任务参数', () {
    test('steps/shake 目标', () {
      expect(MissionService.effectiveTarget(const MissionConfig(type: MissionType.steps, target: 40)), 40);
      expect(MissionService.effectiveTarget(const MissionConfig(type: MissionType.steps)), 20);
      expect(MissionService.effectiveTarget(const MissionConfig(type: MissionType.shake, target: 30)), 30);
      expect(MissionService.effectiveTarget(const MissionConfig(type: MissionType.shake)), 10);
      expect(MissionService.effectiveTarget(const MissionConfig(type: MissionType.schulte)), 0);
    });

    test('resolvePoem 按难度取 / 按 id 取', () {
      final p1 = MissionService.resolvePoem(
        const MissionConfig(type: MissionType.poem, difficulty: 1),
        seed: 0,
      );
      expect(p1.difficulty, 1);

      final p3 = MissionService.resolvePoem(
        const MissionConfig(type: MissionType.poem, difficulty: 3),
        seed: 0,
      );
      expect(p3.difficulty, 3);

      final fixed = MissionService.resolvePoem(
        const MissionConfig(type: MissionType.poem, difficulty: 1, poemId: 'lvshi_001'),
      );
      expect(fixed.id, 'lvshi_001');
    });

    test('古诗库数量充足', () {
      expect(PoemBank.byDifficulty(1).length, greaterThanOrEqualTo(10));
      expect(PoemBank.byDifficulty(2).length, greaterThanOrEqualTo(10));
      expect(PoemBank.byDifficulty(3).length, greaterThanOrEqualTo(10));
    });
  });
}
