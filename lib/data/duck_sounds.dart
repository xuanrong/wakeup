/// 音效资源清单（Asset 路径）。音频素材导入后在此登记。
/// MVP 阶段音频素材未就绪时，DuckSounds 提供占位路径映射。
library;

class DuckSounds {
  DuckSounds._();

  /// 内置音效包 id → 主循环音（Asset 路径）。
  static const Map<String, String> soundPacks = {
    'crazy': 'assets/sounds/quack_crazy.ogg',
    'gentle': 'assets/sounds/quack_gentle.ogg',
    'electric': 'assets/sounds/quack_electric.ogg',
  };

  static const String victory = 'assets/sounds/duck_victory.ogg';
  static const String wrong = 'assets/sounds/duck_wrong.ogg';
  static const String preview = 'assets/sounds/duck_preview.ogg';
}
