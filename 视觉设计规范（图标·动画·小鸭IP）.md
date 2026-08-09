# 醒醒鸭（WakeUp Duck）视觉设计规范
## 图标 · 动画 · 小鸭 IP

> 本文档为**视觉定稿基准**，替代并扩展 `assets/branding/VISUAL_SPEC.md` 中已过时的黄鸭设定。
> 以用户确认的「**白鸭 + 粗黑描边 + 大椭圆黑眼**」图标为 IP 唯一标准形象，实现阶段据此转 CustomPainter / Lottie / 图标位图。
> 涉及资产：`assets/branding/`、`assets/ducky/`，详见第 6 节资产清单。

---

## 1. 角色档案

| 项 | 值 |
|---|---|
| 角色名 | 小雅（Ducky） |
| 定位 | 闹钟场景的唯一主角，负责"催起床 + 庆祝完成" |
| 形象定稿 | **暖白身体 + 粗黑描边（3-5px）+ 大椭圆黑眼 + 粉腮红 + 橙喙（带双鼻孔点）+ 头顶卷毛 + 右侧曲线翅膀** |
| 体型 | 圆胖 Q 萌，大脑袋小身体，头:身 ≈ 1:1.2（接近 V1 圆胖短腿萌 / V2 标准均衡比例，非瘦长） |
| 气质关键词 | 歪头盯人、呆萌可爱、简洁聚焦、温暖明亮、略烦人但关心你 |
| 动态基调 | 静止时歪头待机；任务中张嘴嘎叫催促；完成后眯眼大笑庆祝 |

---

## 2. 白鸭 IP 造型规范（定稿）

### 2.1 元素清单（按优先级）

| 元素 | 规格 | 来源资产 |
|---|---|---|
| **身体** | 暖白 `#F5F0E8`（贴纸）/ 纯白 `#FFFFFF`（手绘），椭圆圆胖体型 | `ducky_walk_sticker.json` / `ducky_walk_doodle.json` |
| **粗黑描边** | `#1A1A1A`，图标 3-4px，动画 4-5px，统一圆头圆角 | `A_cute_white_duck_*.png` 图标、sticker/doodle 动画 |
| **眼睛** | **大椭圆黑眼**（非小黑点）：白底 + 橙虹膜 + 黑瞳 + 白色高光 4 层结构 | 图标确认稿、`ducky_walk_sticker.json` |
| **腮红** | 粉 `#F2C4B3`，两侧圆形/椭圆，无描边，透明度 0.55-0.65 | sticker/doodle 动画 |
| **喙** | 橙 `#FF8C00`（深）/ 高光 `#FFB040`，带双鼻孔点，朝向右侧 | sticker 动画、图标 |
| **头顶卷毛** | 一笔卷曲呆毛，与身体同色描边 | doodle 动画、图标 |
| **翅膀** | 右侧曲线翅膀（3 条羽毛弧线，stroke-only） | doodle 动画、图标 |
| **腿/脚蹼** | 腿橙 `#F0980C` / 脚蹼 `#FFB300`~`#FFAA33`，短腿 | 走路循环动画 |

### 2.2 版本谱系（本项目迭代记录，勿混淆）

| 版本 | 文件 | 状态 |
|---|---|---|
| 黄鸭（旧） | `ducky_front/side_quack/happy/sleepy.svg`、`ducky_walk.json`、`app_icon.svg/png` | **已废弃**，仅作历史参考，不用于新 UI |
| 白鸭·简约（V2） | `ducky_walk_white.json` | 中间版本，浅灰描边 `#C9CDD4` |
| 白鸭·贴纸（V3） | `ducky_walk_sticker.json` | 参考贴纸风：暖白 + 粗黑描边 5px + 4 层大眼 |
| 白鸭·极简手绘（V4） | `ducky_walk_doodle.json` | 对齐 `鸭子.jpeg`：黑点眼 + 3 条曲线翅膀 + 腮红卷毛 |
| **白鸭·定稿图标（V5）** | `A_cute_white_duck_app_icon_*.png` | **本规范基准**：白鸭 + 粗黑描边 + 大椭圆黑眼 + 黄圆角底 + 三高光 |

> 定稿口径：V5 图标为最终形象；动画表现力（大椭圆 4 层眼）以 `ducky_walk_sticker.json` 为准，翅膀/腮红细节可融合 doodle 的曲线风格。

---

## 3. 色板

### 3.1 白鸭 IP 色

| 名称 | Hex | 用途 |
|---|---|---|
| 身体暖白 | `#F5F0E8` | 身体、头（贴纸风） |
| 身体纯白 | `#FFFFFF` | 身体、头（手绘风、图标） |
| 描边黑 | `#1A1A1A` | 全部轮廓描边 3-5px |
| 翅暖白 | `#EBE5DB` | 翅膀填充（贴纸） |
| 喙橙（深） | `#FF8C00` | 下喙、腿 |
| 喙高光橙 | `#FFB040` | 上喙 |
| 喙橙（手绘） | `#F5A623` | 手绘风喙 |
| 脚蹼橙 | `#FFAA33` / `#FFB300` | 脚蹼 |
| 腿橙 | `#F0980C` | 腿部 |
| 虹膜橙 | `#D4691A` | 眼睛虹膜层 |
| 瞳黑 | `#1A1A1A` | 瞳孔 |
| 眼神光白 | `#FFFFFF` | 眼部高光 |
| 腮红粉 | `#F2C4B3`（55-65%） | 脸颊 |
| 鼻孔点 | `#1A1A1A` | 喙上双鼻孔 |

### 3.2 图标 / 品牌色

| 名称 | Hex | 用途 |
|---|---|---|
| 图标底黄（深） | `#FFC400` | App 图标渐变底、强调色 |
| 图标底黄（浅） | `#FFDE59` | 图标渐变上沿 |
| 高光白 | `#FFFFFF` | 右上角三道高光、眼神光 |

### 3.3 旧黄鸭色（已废弃，仅供对照）

`#FFC400` 鸭身主黄 / `#FF8A00` 喙 / `#2B2018` 眼 / `#FF8A7A` 腮红 / `#FFE680` 肚皮 —— 全部不再用于新 UI。

---

## 4. 图标设计

### 4.1 设计构成（1024×1024）

```
┌──────────────────────────────┐
│  #FFDE59 → #FFC400 渐变底      │   ← 纯色渐变背景
│  右上角三道白色高光              │
│                              │
│        白鸭（歪头盯人）          │   ← 居中主体：暖白身体+粗黑描边+
│    大椭圆黑眼 / 粉腮红 /         │      大椭圆黑眼+粉腮红+橙喙双鼻孔+
│    橙喙 / 头顶卷毛 / 曲线翅膀     │      头顶卷毛+右侧曲线翅膀
│                              │
│                              │
└──────────────────────────────┘
```

- 画布 1024×1024，黄色渐变圆角方底（App Icon 形），四周保留 ≥90px 安全区（鸭身不贴边）。
- iOS 自动裁圆角；Android 自适应图标用白鸭主体作前景、`#FFC400` 纯色作背景。
- 三处白色高光固定于右上角，作为品牌记忆点。

### 4.2 已发布尺寸

| 平台 | 路径 | 尺寸 |
|---|---|---|
| Android mdpi | `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` | 48 |
| Android hdpi | `.../mipmap-hdpi/` | 72 |
| Android xhdpi | `.../mipmap-xhdpi/` | 96 |
| Android xxhdpi | `.../mipmap-xxhdpi/` | 144 |
| Android xxxhdpi | `.../mipmap-xxxhdpi/` | 192 |
| iOS | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` | 20~1024 共 15 张 |

---

## 5. 动画体系

### 5.1 表情状态机（DuckyMood）

代码中 `enum DuckyMood { idle, urging, happy, sleepy }`（`lib/widgets/ducky.dart`），各页面按状态调用对应资产：

| 枚举 | 表情 | 触发场景 | 推荐资产 |
|---|---|---|---|
| `idle` | 歪头待机 / 眨眼 | 首页、设置页默认 | `duck_walk_quack.json`（walk_leisure 段） |
| `urging` | 张嘴嘎叫 | 响铃页催促、任务失败惩罚 | `duck_walk_quack.json`（quack 段）/ 侧身张喙 |
| `happy` | 眯眼大笑 | 任务完成、成就解锁 | 张喙大笑 + 头顶 ✓ |
| `sleepy` | 闭眼打哈欠 | 无任务空状态、晚安提示 | 睡帽 + Zzz |

### 5.2 走路循环（Walk Cycle，标准动画核心）

**4 关键帧分镜**：Contact → Down → Passing → Up（各 15 帧）。

| 关键帧 | 帧 | 身体 Y | 身体旋转 | 头旋转 | 后腿角 | 前腿角 |
|---|---|---|---|---|---|---|
| Contact | 0 | 0 | 0° | 0° | +30° | -12° |
| Down | 15 | +8（最低） | -2° | +2° | +8° | -32° |
| Passing | 30 | -8（最高） | 0° | 0° | -12° | +30° |
| Up | 45 | -4 | +2° | -2° | -32° | +8° |

**通用规格**：
- 画布 512×512，30fps，60 帧 = 2.0s 无缝循环。
- 身体上下浮动 ±8px + 微摆 ±2°，双腿反相交替，翅膀反相轻摆 ±4°，头部微反相 ±2°。
- 纯变换关键帧（位置/旋转），无路径形变，兼容 lottie-flutter。
- markers：`contact`(0) / `down`(15) / `passing`(30) / `up`(45)。

### 5.3 版本化 Lottie（assets/ducky/）

| 文件 | 图层 | 风格 | 用途建议 |
|---|---|---|---|
| `duck_walk_quack.json` | 5 | 120 帧，含悠闲行走(0-60)+张嘴嘎叫(60-120) markers：walk_leisure/quack/loop | **响铃催促、首页动效（当前代码默认）** |
| `ducky_walk.json` | 12 | 黄鸭（已废弃） | 仅供历史 |
| `ducky_walk_white.json` | 7 | 纯白 + 浅灰描边 | 浅色背景场景（已不用） |
| `ducky_walk_sticker.json` | 8 | 暖白 + 粗黑描边 5px + 4 层大眼 | **贴近定稿形象，推荐替换默认动效** |
| `ducky_walk_doodle.json` | 10 | 极简手绘：黑点眼 + 3 条曲线翅膀 + 腮红卷毛 | 贴纸/轻量场景 |

> 代码回退逻辑：`ducky.dart` 会探测 Lottie 是否有可见图层，无则回退到 `_DuckyPainter` 自绘（当前为旧黄鸭造型，需同步更新为白鸭定稿造型）。

### 5.4 场景动效建议

| 场景 | 动效 | 时长 | 曲线 |
|---|---|---|---|
| **开屏-小鸭** | 转身 → 探头 → 眨眼 → 嘎一声 → 摇尾巴 | 2.2s | easeOutCubic |
| **预告-探头鸭** | 屏幕边缘探头 → 左顾右盼 → 缩回 | 循环/8s | easeInOutBack |
| **响铃-独鸭开场** | 大鸭从下方弹入 + 鼓腮呼吸（开叫） | 进场 600ms | easeOutBack |
| **响铃-呼应** | 两侧小鸭探头加入，左右摇摆 | 600ms | easeOutBack |
| **响铃-集结** | 底部涌出一排小鸭此起彼伏点头 | 交错 1.5s | easeOut |
| **响铃-大军压境** | 满天小鸭旋转/飘浮/跳舞 | 持续循环 | linear |
| 待机 | 轻微眨眼/歪头循环 | 循环 3s | easeInOutSine |
| 任务完成 | 鸭群瞬间安静 + 头顶 ✓ 弹跳 | 400ms | easeOutBack |
| 结算页 | 结果卡片 + 得意鸭弹入 | 600ms | easeOutBack |

> 「鸭群集结」视觉上模拟鸭群即可，不实际生成大量对象，保证低端设备性能（设计文档 5/响铃动画）。

---

## 6. 资产清单

### 6.1 图标与品牌

| 文件 | 说明 |
|---|---|
| `assets/branding/app_icon.png` | App 图标主图（1024²，旧黄鸭，待替换为白鸭定稿） |
| `assets/branding/app_icon.svg` | App 图标矢量版（旧黄鸭，待替换） |
| `assets/ducky/A_cute_white_duck_app_icon_*.png` | **白鸭定稿图标 1024²（当前基准）** |

### 6.2 表情 SVG（旧黄鸭，待按白鸭重绘）

| 文件 | 表情 | 场景 |
|---|---|---|
| `assets/ducky/ducky_front.svg` | 正面微笑 | 首页、设置页 |
| `assets/ducky/ducky_side_quack.svg` | 侧身张嘴 | 响铃催促 |
| `assets/ducky/ducky_happy.svg` | 眯眼大笑 | 结算庆祝 |
| `assets/ducky/ducky_sleepy.svg` | 睡帽打哈欠 | 空状态、晚安 |

### 6.3 走路循环 Lottie + 分镜 + 生成脚本

| 风格 | Lottie | 分镜 | 生成脚本 |
|---|---|---|---|
| 黄鸭（废弃） | `ducky_walk.json` | `ducky_walk_storyboard.svg` | `gen_lottie_walk.py` / `gen_storyboard.py` |
| 白鸭简约 | `ducky_walk_white.json` | `ducky_walk_white_storyboard.svg` | `gen_lottie_walk_white.py` / `gen_storyboard_white.py` |
| 贴纸风 | `ducky_walk_sticker.json` | `ducky_walk_sticker_storyboard.svg` | `gen_lottie_sticker.py` / `gen_storyboard_sticker.py` |
| 极简手绘 | `ducky_walk_doodle.json` | `ducky_walk_doodle_storyboard.svg` | `gen_lottie_doodle.py` / `gen_storyboard_doodle.py` |
| 嘎叫组合 | `duck_walk_quack.json` | — | — |

### 6.4 参考图（项目根目录）

| 文件 | 说明 |
|---|---|
| `醒醒鸭图标.png` | 图标参考稿 |
| `图标设计图.png` | 图标设计图 |
| `鸭子.jpeg` | 极简手绘参考（V4 来源） |
| `鸭子动画设计图.png` | 动画设计图 |
| `鸭嘎1.wav` | 鸭叫音效素材 |

---

## 7. 使用规范

1. **全 App 只用一只鸭**：白鸭定稿形象贯穿响铃页/空状态/结算/设置/小组件，禁止混用素材库其他鸭子。
2. **配色统一**：主色鸭黄 `#FFC400` 作唯一强调色，其余克制用黑白灰；白鸭本体颜色见第 3 节。
3. **动画克制**：只在关键瞬间（开屏、响铃、任务完成）播放动画，平时页面平稳、只做轻微呼吸/眨眼。
4. **实现路径**：MVP 用 Lottie（`duck_walk_quack.json` 起步，后替换为 `ducky_walk_sticker.json` 定稿风）+ CustomPainter 回退；CustomPainter 造型需从旧黄鸭同步为白鸭定稿。
5. **一致性验收**：新 UI 上白鸭的描边宽度、眼型（大椭圆 4 层）、喙色、腮红、卷毛必须与图标一致（见 MVP 验收清单 #15 IP 一致性）。

---

## 8. 待办（IP 定稿后的收尾）

- [ ] 将 `assets/branding/app_icon.svg/png` 从旧黄鸭替换为白鸭定稿（`A_cute_white_duck_*.png`）。
- [ ] 4 张表情 SVG（front/side_quack/happy/sleepy）按白鸭 + 粗黑描边 + 大椭圆眼重绘。
- [ ] `lib/widgets/ducky.dart` 的 `_DuckyPainter` 造型更新为白鸭（含 4 层大眼、卷毛、曲线翅）。
- [ ] 默认 Lottie 由 `duck_walk_quack.json`（黄鸭）迁移到定稿风（贴纸/手绘），或重导出白鸭版 quack 组合动画。
