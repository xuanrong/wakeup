# 视觉规范 · 小雅（Ducky）· 白鸭定稿

> 对应 `视觉设计规范（图标·动画·小鸭IP）.md` 与 ARCHITECTURE.md 中小鸭 IP 的角色定位。
> 本文档为**视觉定稿基准**（白鸭 + 粗黑描边 + 大椭圆黑眼），实现阶段据此转 CustomPainter / Lottie。

## 1. 角色档案

| 项 | 值 |
|---|---|
| 角色名 | 小雅（Ducky） |
| 定位 | 闹钟场景的唯一主角，负责"催起床 + 庆祝完成" |
| 形象 | **暖白身体 + 粗黑描边（3-5px）+ 大椭圆黑眼 + 粉腮红 + 橙喙（带双鼻孔点）+ 头顶卷毛 + 右侧曲线翅膀** |
| 体型 | 圆胖 Q 萌，大脑袋小身体（头:身 ≈ 1:1.2），歪头盯人、呆萌可爱 |
| 动态基调 | 静止时歪头待机；任务中催促（张嘴嘎叫）；完成后得意眯眼 |

## 2. 色板

### 2.1 白鸭 IP 色（定稿）

| 名称 | Hex | 用途 |
|---|---|---|
| 身体暖白 | `#F5F0E8` | 身体、头（贴纸风） |
| 身体纯白 | `#FFFFFF` | 身体、头（手绘风、图标） |
| 描边黑 | `#1A1A1A` | 全部轮廓描边 3-5px |
| 翅暖白 | `#EBE5DB` | 翅膀填充 |
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

### 2.2 图标 / 品牌色

| 名称 | Hex | 用途 |
|---|---|---|
| 图标底黄（深） | `#FFC400` | App 图标渐变底、强调色 |
| 图标底黄（浅） | `#FFDE59` | 图标渐变上沿 |
| 高光白 | `#FFFFFF` | 图标右上角三道高光、眼神光 |

> 旧黄鸭色（`#FFC400` 鸭身主黄 / `#FF8A00` 喙 / `#2B2018` 眼等）已废弃，不再用于新 UI。

## 3. 已生成素材（assets/）

| 文件 | 用途 | 使用场景 |
|---|---|---|
| `ducky/A_cute_white_duck_app_icon_on__2026-08-08T17-41-12.png` | **白鸭定稿 App 图标 1024²** | 图标制作基准（替换旧黄鸭） |
| `branding/app_icon.png` | App 图标主图（旧黄鸭，**待替换**） | 图标制作基准 / Flutter 内展示 |
| `branding/app_icon.svg` | App 图标矢量版（旧黄鸭，**待替换**） | 图标制作基准 |
| `ducky/duck_walk_quack.json` | Lottie 动画（行走+张嘴嘎叫，30fps/120帧，512²，markers: walk_leisure/quack/loop） | 响铃催促、首页动效 |
| `ducky/ducky_front.svg` | 正面微笑鸭（旧黄鸭，**待按白鸭重绘**） | 设置页、首页头部 |
| `ducky/ducky_side_quack.svg` | 侧身张嘴"嘎嘎"鸭（旧黄鸭，**待重绘**） | 响铃催促、任务提示 |
| `ducky/ducky_happy.svg` | 眯眼大笑庆祝鸭（旧黄鸭，**待重绘**） | 任务完成结算页 |
| `ducky/ducky_sleepy.svg` | 戴睡帽打哈欠鸭（旧黄鸭，**待重绘**） | 空状态、睡前提示 |

## 3.1 白鸭走路循环 Lottie 版本

| 文件 | 图层 | 风格 | 状态 |
|---|---|---|---|
| `ducky/ducky_walk_sticker.json` | 8 | 暖白 + 粗黑描边 5px + 4 层大眼 + 圆胖体型 | **贴近定稿，推荐默认动效** |
| `ducky/ducky_walk_doodle.json` | 10 | 极简手绘：黑点眼 + 3 条曲线翅膀 + 腮红卷毛 | 贴纸/轻量场景 |
| `ducky/ducky_walk_white.json` | 7 | 纯白 + 浅灰描边 `#C9CDD4` | 已不用（中间版） |
| `ducky/ducky_walk.json` | 12 | 黄鸭 | 已废弃 |

> 分镜：`ducky_walk_sticker_storyboard.svg` / `ducky_walk_doodle_storyboard.svg`（4 关键帧）。
> 生成脚本：`gen_lottie_sticker.py` / `gen_storyboard_sticker.py` / `gen_lottie_doodle.py` / `gen_storyboard_doodle.py` 等。

## 3.2 App 图标已发布尺寸

| 平台 | 路径 | 尺寸 |
|---|---|---|
| Android mdpi | `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` | 48 |
| Android hdpi | `.../mipmap-hdpi/` | 72 |
| Android xhdpi | `.../mipmap-xhdpi/` | 96 |
| Android xxhdpi | `.../mipmap-xxhdpi/` | 144 |
| Android xxxhdpi | `.../mipmap-xxxhdpi/` | 192 |
| iOS | `ios/Runner/Assets.xcassets/AppIcon.appiconset/` | 20~1024 共 15 张 |

## 3.3 Lottie markers（`duck_walk_quack.json`）

| marker | 帧 | 含义 |
|---|---|---|
| `walk_leisure` | 0-60 | 悠闲行走（控制器左右平移 + 身体呼吸摆动 + 脚步 + 翅膀） |
| `quack` | 60-120 | 张嘴嘎叫（喙缩放 100→115→100） |
| `loop` | 0-120 | 整段循环 |

> 走路循环 markers（sticker/doodle 等）：`contact`(0) / `down`(15) / `passing`(30) / `up`(45)。

## 4. 图标与安全区

- App 图标：1024×1024 画布，**黄色渐变圆角方底**（`#FFDE59→#FFC400`）+ **右上角三道白色高光** + **居中白鸭**（歪头盯人）。
- iOS 自动裁圆角，设计时四周保留 ≥ 90px 安全区（鸭身不贴边）。
- Android 自适应图标：用白鸭主体做前景，背景用纯色 `#FFC400`。

## 5. 表情状态机（DuckyMood）

代码中用一个枚举表达鸭子情绪，各页面按状态调用对应素材/动画：

| 枚举 | 表情 | 触发场景 |
|---|---|---|
| `idle` | 歪头待机 / 眨眼 | 首页、设置页默认 |
| `urging` | 侧身张嘴嘎叫 | 响铃页催促、任务失败惩罚 |
| `happy` | 眯眼大笑 | 任务完成、成就解锁 |
| `sleepy` | 闭眼打哈欠 | 无任务空状态、晚安提示 |

## 6. 动画建议

- 常驻呼吸：身体上下 2-4px 缩放，3s 循环。
- 催促：张嘴开合 0.8s，配合摆动翅膀 0.4s。
- 完成：跳跃 + 转圈 0.5s，落地后眯眼大笑。
- 睡觉：Zzz 向上飘，2s 循环。
- **走路循环**（白鸭定稿风，`ducky_walk_sticker.json`）：4 关键帧 walk cycle——Contact→Down→Passing→Up，60f@30fps=2.0s loop。身体上下浮动 ±8px + 微摆 ±2°，双腿反相交替摆动（后腿 [30,8,-12,-32]° / 前腿 [-12,-32,30,8]°），翅膀反相轻摆 ±4°，头部微反相 ±2°。侧身朝右，纯变换关键帧无路径形变，兼容 lottie-flutter。

> 待办：`lib/widgets/ducky.dart` 的 `_DuckyPainter` 回退造型需从旧黄鸭更新为白鸭定稿（4 层大眼、卷毛、曲线翅）。
