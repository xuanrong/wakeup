# 醒醒鸭（wakeup）— 鸭叫闹钟 App 设计文档 v1.0

---

## 0. 项目命名

| 项 | 值 |
|---|---|
| **App 显示名** | 醒醒鸭 |
| **Flutter 工程名 / package 名** | `wakeup` |
| **Android applicationId** | `com.wakeup.duck` |
| **iOS Bundle Identifier** | `com.wakeup.duck` |
| 项目目录 | `wakeup/` |

---

## 1. 项目概述

一款参考 **Clucky**（https://tryclucky.com）的"公鸡闹钟"玩法的 Flutter 跨平台闹钟 App，把叫声从"公鸡啼"换成 **"鸭子嘎嘎叫"**。

核心承诺：**闹钟会一直嘎嘎叫，直到你完成一个起床任务（Mission）才肯闭嘴。没有贪睡按钮。**

整体定位：搞笑 + 自律。用鸭子搞怪的声音和"起床任务"帮助赖床患者真正起床，同时不牺牲隐私（无账号、无广告、数据只留在本机）。

> **平台能力差异（重要）**：
> - **Android**：完整能力——前台服务持续响铃 + 全屏无法跳过 + 必须完成任务才停。
> - **iOS**：AlarmKit 触发的是**系统闹钟界面**，用户可**直接按系统关闭按钮**绕过任务（系统限制，无法拦截）；App 只能通过通知引导用户进入 App 完成任务。因此"无法跳过"是 **Android 专属卖点**，iOS 为"通知 + 引导"弱化版。

---

## 2. 完整功能清单

### 2.1 核心体验

| 功能 | 说明 |
|---|---|
| **鸭叫闹钟** | 到点后循环播放鸭子嘎嘎叫声，音量渐增，直到任务完成才停 |
| **起床任务（Mission）** | 必须完成指定任务才能关闭闹钟，无法跳过、无法滑动关闭 |
| **无贪睡** | 没有贪睡按钮，完成任务才停 |
| **静音/勿扰也照响** | 参考 Clucky 目标：Android 全屏 Intent + 前台服务；iOS 26 用 AlarmKit |
| **多任务可组合** | 每个闹钟可设置 1-3 个任务组合（脑力 + 体力混合） |
| **任务可扩展** | 内置 4 种核心任务，后续可增量扩展新任务类型 |

### 2.2 起床任务（Mission）库 — 核心 4 种

| 任务类型 | 说明 | 可调参数 | 唤醒方式 |
|---|---|---|---|
| **舒尔特方格** | 方格数字乱序，按顺序依次点击 | 难度 1-3 → 格数 3×3 / 4×4 / 5×5 | 脑力 |
| **输入古诗** | 屏幕显示一首古诗，正确打完全部文字（含标点） | 难度 1-3 → 短/中/长诗 | 脑力 |
| **步数任务** | 拿着手机走够指定步数 | 目标 20/40/60 步 | 身体 |
| **摇动任务** | 快速摇手机达到目标次数 | 目标 10/20/30 次 | 身体 |

> 后续可扩展：拍照、扫码、数学题、深蹲、学鸭叫等（见第 10 章）。

### 2.3 个性化

| 功能 | 说明 |
|---|---|
| **鸭叫音效包** | 内置 3+ 套：疯狂鸭子、温柔鸭子、电音鸭子、可自定义录音 |
| **音量渐增** | 0→最大音量渐增唤醒，可选"一响就最大" |
| **主题皮肤** | 4 套：鸭塘黄、午夜鸭、薄荷鸭、极简鸭 |
| **鸭子形象** | 静态鸭 / 眨眼鸭 / 跳舞鸭（闹钟响起时全屏动画） |
| **暗夜模式** | 22:00-6:00 自动切换深色主题 |

### 2.4 平台特性

| 功能 | 说明 |
|---|---|
| **全屏叫醒界面** | 闹钟响起时弹出全屏界面，阻止普通滑动关闭 |
| **系统闹钟联动** | Android 使用 `setAlarmClock`，状态栏显示"闹钟"图标、显示在系统闹钟列表 |
| **本地通知** | 入睡前提醒设置次日闹钟 |
| **桌面小组件** | Android/iOS 桌面显示"下次闹钟 + 连续早起天数" |

### 2.5 节假日与工作日智能调度

| 功能 | 说明 |
|---|---|
| **法定节假日识别** | 内置当年+次年节假日表，自动识别节假日休息、调休补班上班 |
| **工作日闹钟跳过节假日** | 闹钟级开关：工作日闹钟在节假日/周末不响（默认按"法定工作日"判定） |
| **仅法定工作日闹钟** | 只在真正的法定工作日响（自动处理调休） |
| **大小周闹钟** | 大周周六上班响、小周周六不响；基准周用户可设 |
| **自定义重复** | 任意勾选周几 + 单日覆盖（指定某天响/不响） |
| **节假日数据更新** | 设置页可联网更新最新节假日表，无网时用离线兜底 |
| **响铃日历预览** | 编辑闹钟时展示未来 30 天响铃日，所见即所得 |

### 2.6 数据与隐私

| 功能 | 说明 |
|---|---|
| **数据统计** | 起床率、平均任务耗时、各任务类型完成次数、连续早起记录 |
| **隐私锁** | App 锁（PIN/指纹），保护闹钟设置与统计 |
| **数据导出** | 导出统计与设置为 JSON |
| **无账号无广告** | 数据仅存本机，无云端、无推送广告 |

---

## 3. 核心玩法详细设计（Clucky 模式）

### 3.1 响铃流程

```
【预告阶段：提前 1 分钟】锁屏/通知界面——屏幕边缘探出一只鸭子
   ├── 探头探脑：鸭子从屏幕底部/侧边慢慢探出头，左看看右看看（眼睛转动、歪头）
   ├── 小声"嘎"一下，然后缩回去 → 提示"鸭子就要来了"（可关闭预告）
   │
【响铃阶段：到点闹钟响】
   ├── 系统层：
   │   ├── Android：前台服务 + 全屏 Intent Activity（FLAG_KEEP_SCREEN_ON）
   │   │           + AlarmManager.setAlarmClock（显示在系统闹钟、可绕勿扰）
   │   └── iOS 26+：AlarmKit 调度；旧版本：本地通知（静音模式可能被屏蔽，需提示）
   │
   ├── 动画层（核心视觉——"鸭群集结"渐进升级）：
   │   ├── Stage 1「独鸭开场」：全屏变暗，一只大鸭子入场，鼓腮开始嘎嘎叫
   │   ├── Stage 2「呼应」：叫 5 秒后，两侧各探头一只小鸭，一起叫（双声道不同音高）
   │   ├── Stage 3「集结」：再 5 秒，屏幕底部涌出一排鸭子，此起彼伏地叫
   │   ├── Stage 4「大军压境」：再 5 秒，漫天鸭子涌出、旋转跳舞，叫声叠加成"嘎嘎墙"
   │   └── 音量随鸭子数量逐级递增，鸭子越多越吵，直到任务完成才收场
   │
   ├── 声音层：
   │   ├── 后台响铃：原生 ExoPlayer 单主音层循环鸭叫
   │   ├── 进入全屏后：Flutter 接管，每只鸭子一个独立音层（不同音高/相位/延迟）用 `just_audio` 混音
   │   ├── 音量随 Stage 1→4 递增（如 40%→60%→80%→100%）
   │   └── 无法通过音量键/静音键关闭（Android 前台服务持续播放）
   │
   ├── 界面层：
   │   ├── 全屏"鸭群"界面（鸭子动画 + 大按钮"开始你的起床任务"）
   │   ├── 无"关闭"按钮、无滑动手势关闭；仅后台任务完成可解
   │   └── 防卸载/防强制停止（Android 可选 DEVICE_ADMIN 白名单权限）
   │
   └── 任务层：
       ├── 进入任务页 → 完成当前闹钟配置的任务（可组合 1-3 个）
       ├── 全部完成后 → 鸭群瞬间安静，"鸭子得意"音效 → 停止响铃
       └── 弹"你起床了"总结页（用时、完成的任务、连续早起记录）
```

### 3.2 无贪睡

- **没有贪睡按钮**：响铃界面不提供任何 snooze 入口。
- 要停响铃，唯一途径就是完成配置的起床任务。
- 任务页退出无效：返回 / Home 只会回到全屏响铃页，鸭叫不停。

### 3.3 起床任务交互流程

```
响铃 → 全屏界面 → 点击"开始任务" → 进入任务页，按配置顺序逐个完成：

[舒尔特方格]
   ├── 格数随难度：3×3(1-9) / 4×4(1-16) / 5×5(1-25) 乱序
   ├── 点击顺序必须从 1 开始，点到错的数字 → 鸭叫一声 + 震一下
   ├── 全部按序点完 → "任务 1/2 完成 ✅"
   └── 计时（用时记录到统计，超时无惩罚）

[输入古诗]
   ├── 难度 1-3 对应诗长：短(4句) / 中(8句) / 长(16句)，从内置古诗库随机抽取
   ├── 屏幕显示古诗全文（含标题、作者、标点），下方输入框
   ├── 打错一个字 → 该字标红，可删改
   ├── 全部正确（含标点）→ 完成任务
   └── 备选难度：显示一半让用户补全

   比对规则（防输入法差异误判）：
   ├── 忽略首尾空白与连续空白
   ├── 半角标点视为等价于全角（如 "," ≡ "，"、"." ≡ "。"）
   ├── 不含标题/作者比对（MVP 只比对诗句正文）
   └── 输入框禁用输入法联想/自动纠错（`autocorrect: false` + `smartDashesType: disabled`）

[步数]
   ├── 系统步数传感器（Android `TYPE_STEP_COUNTER`，iOS `CMPedometer`）计步
   ├── 取**增量差值**（响应铃起始值 - 当前值），进度环实时显示
   ├── 走够目标步数（20/40/60）→ 完成任务
   └── 每走一步有震动反馈

[摇动]
   ├── 加速度计检测，每摇一下计数 +1 并震动
   ├── 摇够目标次数（10/20/30）→ 完成任务
   └── 快速连摇才算，慢摇不计

[任务完成] → 停止响铃 + 结算页
```

### 3.4 任务进度与异常处理

- **进度持久化**：进入任务页即把 `{alarmId, 触发日期, 当前任务序号, 已完成任务列表, 已点数字, 已输入古诗, 已计数}` 写入本地（`shared_preferences`）。每次任务状态变更同步写入。
- **进度防串（关键）**：进度记录**必须携带 alarmId + 触发日期**。响铃时先读取，校验 `alarmId + 日期` 与本闹钟本次触发匹配才续做；不匹配（如上一个闹钟的残留进度）则**重置**。
- **中途退出 / App 被杀**：重进响铃页时读取匹配的本地进度，**从未完成的任务继续**，不从头重来。
- **进度清理**：任务完成 / 结算后删除该条进度；同一闹钟次日再次响铃时自动覆盖旧记录。
- **中途改配置**：若用户在响铃时编辑了该闹钟（少见），以进入任务页时读取的配置为准。
- **任务超时**：不设硬性超时（杜绝用户"熬过去"）；响铃 30 分钟后记"赖床标签"（见 3.5），完成判定仍优先。

### 3.5 统计口径与连续早起规则

| 指标 | 定义 |
|---|---|
| **起床成功** | 响铃后完成全部配置任务并停止响铃（**无论耗时多久，完成判定优先**） |
| **起床失败** | 该闹钟当天到点响铃，但最终未完成任务（响铃结束后仍处于未完成任务状态） |
| **起床率** | 分母 = **当天有启用闹钟且到点响铃的天数**；分子 = 起床成功天数 |
| **任务耗时** | 进入任务页 → 最后一个任务完成的秒数 |
| **连续早起** | 连续 N 天"起床成功"；任一天起床失败即中断（**当天无响铃闹钟的天不中断，只不算连续**） |

> **关于"30 分钟"**：30 分钟不是"失败"判定，而是懒账标记——响铃 30 分钟后若仍未完成任务，统计里记一个"赖床标签"，且响铃继续（11.2）。之后完成仍算成功。
> **关于"主动关闭"**：iOS 上用户可在系统闹钟界面直接关闭（见"平台能力差异"与 4.2）；Android 上无关闭入口，只能通过完成任务停止。
> 计算口径以**本地日期**（`DateTime.now()` 本地时区）为准，跨天由"闹钟重复规则"决定哪天记账。
> 存储：MVP 用 `shared_preferences` 存 `DailyStat[]`；Phase 2 迁 `sqflite`。

### 3.6 节假日 / 工作日 / 大小周判定设计

#### 3.6.1 判定模型（分层优先级，高→低）

```
isRestDay(date)  该日是否为"休息日"（闹钟工作日模式下不应响铃）

  ① 自定义单日覆盖（最高）  → 用户强制指定：overrideRest / overrideWork
  ② 法定节假日表
       - holidays[] 命中      → 休息（即使是周二）
       - makeupWorkdays[] 命中 → 上班（即使是周日，调休补班）
  ③ 大小周规则（仅作用于周六）
       - 大周周六 → 上班
       - 小周周六 → 休息
  ④ 默认：周一~五上班、周六日休息
```

> 优先级保证：法定节假日 > 大小周 > 默认周几。补班周日的"大小周"不冲突，因为②先于③。

#### 3.6.2 节假日数据源（离线打包 + 可选更新）

- **离线内置**：当年 + 次年节假日表（依据国务院办公厅年度放假安排），JSON：
  ```json
  {
    "year": 2026,
    "holidays": ["2026-01-01", "2026-02-17", "..."],
    "makeupWorkdays": ["2026-02-14", "2026-02-28", "..."]
  }
  ```
- 存于 `data/holiday/2026.json`、`2027.json`。
- **可选联网更新**：设置页"更新节假日"→ 拉取当年/次年最新表 → 写入本地并记录 `updatedAt`。无网时用离线兜底；表过期（次年无表）时提示。
- 判定接口：`HolidayService.isRest(date)` / `isMakeupWork(date)` / `isHoliday(date)`。

#### 3.6.3 大小周

- **定义**：大周 = 六天工作（周六上班）；小周 = 五天工作（周六休）。
- **基准**：用户设置页可设定"起始周"（默认当周），从该周六起按周六序号奇偶轮换。
- 判定：`isBigWeekSat(date)` = 自基准周起的周六序号为偶数。仅影响周六，与节假日表叠加（见 3.6.1）。

#### 3.6.4 自定义

- **周几模式**：任意勾选周几（现有 `repeatDays`）。
- **单日覆盖**：`overrides: { "2026-09-01": RestOrWork }`，最高优先级，用于出差/请假/特殊安排。

#### 3.6.5 闹钟重复类型与下次响铃计算

```
scheduleType: enum { daily, weekday, legal, bigSmallWeek, custom }

AlarmModel 增加：
  scheduleType          // 上述 5 类
  skipHoliday: bool     // 闹钟级开关：工作日闹钟跳过节假日/周末
  bigSmallBaseWeek: DateTime?  // 大小周基准周（scheduleType=bigSmallWeek）
  dayOverrides: Map<String, RestOrWork>  // 单日覆盖

nextRingTime(alarm) =
  从 now 起逐日检查 day：
    该日是否响铃 = matchesSchedule(day) && !(skipHoliday && isRestDay(day))
    取第一个满足者 → 该日 alarm.time
```

- `matchesSchedule(day)`：
  - daily → 恒 true
  - weekday → 周一到周五（若 skipHoliday 开，再叠加 isRestDay 过滤）
  - legal → isRestDay(day) == false（法定工作日，自动处理调休）
  - bigSmallWeek → 周一~五，或大周周六
  - custom → repeatDays.contains(weekday)，dayOverrides 优先

#### 3.6.6 响铃日历预览

- 编辑闹钟页内嵌 30 天日历：响铃日高亮 + 节假日标注（休=灰、补班=橙、大小周周六=蓝）。
- 实时预览"跳过节假日开/关"的效果，避免配置误导。

---

## 4. 闹钟技术实现方案（跨平台）

> Clucky 之所以"静音/勿扰也照响"，是因为用了 Apple AlarmKit。
> Flutter 跨平台没有现成的一揽子方案，需要分平台做原生通道。

### 4.1 Android

> **音频分工（关键）**：
> - **后台/锁屏响铃** → 原生前台服务用 `ExoPlayer` 播放鸭叫（App 被杀、锁屏、Dart 未启动时也能响）
> - **全屏页面内动画音效 / 任务反馈音** → Flutter 层用 `just_audio` 播放
> - 两条链路互不依赖；用户点"开始任务"进入全屏页后，原生服务降为静音待命，由 Flutter 接管界面内音效，任务完成时通知原生服务停止
> - **切换防断层**：进入全屏页时，原生音量用 500ms 淡出 → 同时 Flutter 侧鸭群音效从 0 淡入；反之任务完成停止时反向。避免两套音源交接瞬间的爆音/断音。

| 技术 | 说明 |
|---|---|
| `AlarmManager.setAlarmClock` | 注册系统级闹钟，状态栏显示闹钟图标、入系统闹钟列表、可绕过部分勿扰 |
| **前台服务 (Foreground Service)** | `ExoPlayer` 播放鸭叫 + 保持进程存活；`foregroundServiceType=mediaPlayback` |
| **全屏 Intent Activity** | 闹钟响时启动全屏 Activity，`onCreate` 保持屏幕常亮、禁止返回/Home 关闭 |
| **精确闹钟权限** | Android 12+ 需 `SCHEDULE_EXACT_ALARM`，`USE_FULL_SCREEN_INTENT` |
| 音效 | `ExoPlayer` 循环 + 音量渐增（原生侧实现，防锁屏后失效） |
| 重启恢复 | 注册 `BOOT_COMPLETED` 广播，重启后重建闹钟 |

**音量策略（MVP 决策）**：
- Android 响铃走**系统闹钟音量通道**（`AudioAttributes.USAGE_ALARM`），不受媒体音量/静音键影响。
- 渐增方案：`音量起点 30% → 100%`，20 秒线性渐增；可选"一响就 100%"。
- 渐增在原生 ExoPlayer 侧实现（`LinearVolumeShaper`），Flutter 不参与。
- iOS：通知声音由系统播放，音量跟随系统；AlarmKit 模式则用系统闹钟音量。

**前台服务常驻通知**：Android 前台服务必须显示一条常驻通知（用户可见，不可滑动删除）。文案：「醒醒鸭」正在运行 · 点击查看下次闹钟。通过 `contentIntent` 点击打开 App 首页。

**权限被拒降级（Android）**：
- `SCHEDULE_EXACT_ALARM` 被拒 → 降级为 `setAlarmClock` 不保证精确，提示用户手动授权；App 不崩溃。
- `POST_NOTIFICATIONS` 被拒（Android 13+）→ 全屏响铃 Activity 可能不自动弹出，但前台服务声音仍响；首次设闹钟时引导授权通知。

**Android 权限清单（AndroidManifest.xml）：**

| 权限 | 用途 | 备注 |
|---|---|---|
| `SCHEDULE_EXACT_ALARM` | 精确闹钟调度 | Android 12+，首次设闹钟引导授权 |
| `USE_FULL_SCREEN_INTENT` | 全屏响铃 Activity | Android 14+ 需用户手动放行"全屏通知" |
| `WAKE_LOCK` | 锁屏亮屏 | 前台服务持有 |
| `FOREGROUND_SERVICE` + `FOREGROUND_SERVICE_MEDIA_PLAYBACK` | 前台服务类型声明 | Android 14+ 必需 |
| `POST_NOTIFICATIONS` | 通知（响铃/提醒） | Android 13+ 运行时授权 |
| `RECEIVE_BOOT_COMPLETED` | 重启后恢复闹钟 | 静态注册 |
| `VIBRATE` | 摇动/点错震动反馈 | 正常权限 |
| `android.hardware.sensor.accelerometer`（feature） | 摇动检测 | `<uses-feature>` 声明 |
| `android.hardware.sensor.step_counter`（feature） | 步数任务 | `<uses-feature>` 声明 |

### 4.2 iOS

| 技术 | 说明 |
|---|---|
| **AlarmKit（iOS 26+）** | 新版系统闹钟 API，可"静音/勿扰/焦点模式照响" |
| **本地通知（旧版兜底）** | iOS < 26 用 UNUserNotificationCenter，但静音开关/勿扰会静音——需在设置页明确提示 |
| 音频 | AVAudioPlayer / AVAudioEngine 播放循环鸭叫（App 前台全屏时） |
| 后台限制说明 | **第三方 App 无法在后台长播音频**；AlarmKit 触发的是"通知 + 用户打开 App"，任务界面必须在 App 前台完成。此限制与 Clucky 一致——响铃时系统会弹通知并引导进入 App |

> **App 被杀时 iOS 的兜底**：闹钟触发 → 系统通知响铃（自定义声音打包进 Bundle，在通知 `sound` 中引用）→ 用户点通知进入 App → 进入全屏响铃页做任务。后台长播仅限 Android。

**iOS 权限：**
- `UNUserNotificationCenter.requestAuthorization`：通知授权（首次使用时引导）
- `Info.plist` 声明 `UIBackgroundModes`：如需极短后台音频可加 `audio`（不建议依赖）
- AlarmKit：无需额外权限，随系统闹钟权限管理

> Flutter 侧通过 **platform channel** 封装：
> - `alarm_service.dart` → 原生 `scheduleAlarm(...)` / `cancelAlarm(...)`
> - Android 端用 Kotlin 实现上面的 AlarmManager + 前台服务 + 全屏 Activity
> - iOS 端用 Swift 实现 AlarmKit 调度 + 通知扩展
> - 这是本项目的**唯一原生代码**，其余全部 Dart 实现

### 4.3 平台版本基线

| 平台 | 项 | 值 |
|---|---|---|
| Android | minSdk | 26（Android 8.0，step_counter / 前台服务友好） |
| Android | targetSdk / compileSdk | 最新稳定（如 35） |
| Android | Java/Kotlin | Kotlin（AGP 自带） |
| iOS | deployment target | 26.0（AlarmKit 必需）；iOS < 26 用通知兜底 |
| iOS | Xcode | 最新稳定 |

### 4.4 原生 ↔ Dart 通信接口表（MethodChannel / EventChannel）

> Channel 名：`com.wakeup.duck/alarm`

| 方向 | 方法 | 参数 | 返回 | 说明 |
|---|---|---|---|---|
| Dart→原生 | `scheduleAlarm` | `alarmId, timestamp, soundPath` | `bool` | 注册下次响铃（setAlarmClock） |
| Dart→原生 | `cancelAlarm` | `alarmId` | `bool` | 取消闹钟 |
| Dart→原生 | `getStartAlarmId` | — | `String?` | 冷启动时取本次响铃的 alarmId |
| Dart→原生 | `stopRinging` | — | `void` | 任务完成，通知原生停止前台服务声音 |
| Dart→原生 | `muteBackground` | `bool` | `void` | 进入全屏后原生声音静音待命（Flutter 接管音效） |
| 原生→Dart | `onRing`（EventChannel） | `alarmId` | — | App 存活时通知 Dart 推响铃页 |

**调用时序**：
- 后台响铃：原生播放 → `onRing` → App 前台推响铃页 → `muteBackground(true)` → Flutter 接管鸭群音效 → 任务完成 → `stopRinging` → `muteBackground(false)` 并停服务
- 冷启动：RingingActivity 建引擎 → Dart 读 `getStartAlarmId()` → 渲染响铃页 → 同上

---

## 5. App 生命周期与响铃触发（重点）

> 闹钟响时 App 可能在前台、后台、甚至**已被系统杀死**。本方案保证三种状态都能响。

```
                    ┌──────────────────────────────┐
                    │  闹钟到点（AlarmManager 触发）   │
                    └──────────────┬───────────────┘
                                   │
                    ┌──────────────▼───────────────┐
                    │  Android 前台服务立即播放鸭叫    │
                    │ （ExoPlayer，App 被杀也照常）    │
                    └──────────────┬───────────────┘
                                   │
        ┌──────────────────────────▼──────────────────────────┐
        │ 唤醒策略：启动全屏 RingingActivity                     │
        │   A. App 前台 → 直接显示响铃页（复用现有 Flutter 页面）    │
        │   B. App 后台 → 全屏 Activity 弹到前台                  │
        │   C. App 被杀 → 冷启动 FlutterEngine，传 alarmId        │
        │   D. 锁屏   → 点亮屏幕 + KEYGUARD_DISMISS 全屏显示       │
        └──────────────────────────┬──────────────────────────┘
                                   │
        ┌──────────────────────────▼──────────────────────────┐
        │ Flutter 响铃页拿到 alarmId → 加载该闹钟的任务配置        │
        │ → 播放鸭群集结动画（Flutter 侧 just_audio 音效）         │
        │ → 用户点 [开始任务] → 完成任务                          │
        └──────────────────────────┬──────────────────────────┘
                                   │
        ┌──────────────────────────▼──────────────────────────┐
        │ 任务完成 → 通知原生停止响铃 → 停止前台服务 → 结算页         │
        └─────────────────────────────────────────────────────┘
```

### 5.1 渲染模型（关键决策）

> **响铃页 = RingingActivity（原生壳）内嵌 FlutterView**。动画、任务、结算全部是 Flutter 页面，原生只负责：唤醒屏幕、播放后台声音、禁止退出。

```
RingingActivity (Kotlin) ──原生壳，只管：亮屏/锁屏/拦截返回与Home
   └── FlutterView ──渲染 RingingPage（鸭群动画/任务/结算）
        │
        ├── 启动方式 A【App 存活】→ 复用主 App 的 FlutterEngine（缓存）
        │      ├── Dart 侧 App 收到 onRing 事件 → push 到响铃路由
        │      └── 页面间跳转用 Navigator（保留底部 Tab 栈）
        │
        └── 启动方式 B【App 被杀】→ 冷启动独立 FlutterEngine（FlutterEngineGroup）
               ├── main.dart 读启动参数 alarmId → 直接渲染 RingingPage
               └── 渲染完响铃页/任务/结算后退出（不加载首页）
```

**冷启动路由分流**：

```
main.dart
   ├── 读取 flutter_local_notifications 传参 / platform channel 的 getStartAlarmId()
   ├── 有 alarmId → 用 FlutterEngineGroup 建独立引擎，only 渲染 RingingPage
   └── 无 alarmId → 正常启动，进入主 App（底部 Tab）
```

### 5.2 状态处理细则

| 状态 | 处理 |
|---|---|
| **App 前台** | 原生仅播放声音，不弹 Activity；Dart 侧收到广播直接推响铃页 |
| **App 后台** | 全屏 Activity 弹到前台，Dart 恢复后接管 |
| **App 被杀** | 冷启动 FlutterEngineGroup → 只渲染响铃页 → 完成后正常退出 |
| **锁屏** | 全屏 Activity `FLAG_SHOW_WHEN_LOCKED` + `FLAG_TURN_SCREEN_ON`，显示响铃页 |
| **任务中退出/被杀** | 重进响铃页**继续未完成任务**（进度持久化到本地，见 3.4） |
| **响铃中用户杀 App** | Android 前台服务继续响，重新打开 App 回到响铃页 |

---

## 6. 页面结构

```
App（底部导航栏 3 个 Tab）
│
├── ⏰ 闹钟 Tab (AlarmsPage)
│   ├── 顶部中心：一句诙谐提示（"下次闹钟 …"）+ 小鸭 IP 静静待机（眨眼）
│   ├── 闹钟列表（卡片式极简：大号时间 + 重复类型文案 + 任务图标，留白呼吸）
│   ├── 空状态：小鸭失落表情 + "还没有闹钟，鸭子很寂寞" + [+ 新建]
│   ├── 新增/编辑闹钟页 (AlarmEditPage)
│   │   ├── 时间滚轮选择
│   │   ├── 重复类型：每天 / 工作日 / 仅法定工作日 / 大小周 / 自定义周几
│   │   ├── 闹钟级开关：跳过节假日（工作日模式）
│   │   ├── 单日覆盖：指定某天响/不响
│   │   ├── 响铃日历预览（未来 30 天，节假日/补班/大小周标注）
│   │   ├── 标签（如"上班""晨跑"）
│   │   ├── 任务配置（从 4 种核心任务中勾选 1-3 个，设置难度/参数）
│   │   └── 音效包选择（试听）
│   └── 快捷开关（下次闹钟、连续早起天数）
│
├── 📈 统计 Tab (StatsPage)
│   ├── 本周起床率（Phase 1 简化版：本周成功/失败天数文本，不做图表）
│   ├── 连续早起天数卡片
│   └── 最近 7 天起床情况列表（✓/✗）
│
└── 🦆 我的 Tab (ProfilePage)
    ├── 音效包管理（内置 3 套 + 我的录音）
    ├── 主题皮肤选择
    ├── 设置（音量渐增、暗夜模式、隐私锁、数据导出）
    └── 关于/赞赏
```

> MVP 范围裁剪：统计 Tab 仅展示"文本型"数据，环形图/条形图等图表放 Phase 3。任务类型排行图不在 MVP。

> **开发调试入口（MVP 必需）**：设置页提供"立即响铃测试"按钮（`kDebugMode` 下显示），绕过真实闹钟时间，直接触发 RingingActivity / 响铃页，用于联调动画、任务与声音切换。

### 页面详情

#### 响铃页 (RingingPage) - 全屏核心页面

```
全屏动态场景——"鸭群集结"渐进动画（Flutter 内实现，进入全屏后播放）
   ├── Stage 1 独鸭开场：暗色背景，一只大鸭子从下方入场，鼓腮开叫（单个音层）
   ├── Stage 2 呼应：左右各探出一只小鸭，双声道、不同音高加入
   ├── Stage 3 集结：底部涌出一排鸭子此起彼伏，叫声叠加
   ├── Stage 4 大军压境：满天鸭子旋转跳舞，叫声音层叠加到峰值，屏幕布满鸭群
   ├── 顶部：当前时间 + "嘎嘎嘎！"大标题（随 Stage 逐级放大/抖动）
   ├── 中部：鸭群动画 + 循环混音鸭叫
   ├── 底部：[开始起床任务] 大按钮（唯一可操作按钮，点击后切到任务页）
   └── 任务完成 → 鸭群瞬间静音/退场 → 结算页：用时 / 完成的任务 / 连续早起记录
```

#### 任务页 (MissionPage)

```
顶部：任务进度条（1/2、2/2）+ 当前任务类型图标
中部：按任务类型动态切换
   ├── 舒尔特：3×3 / 4×4 / 5×5 数字网格（随难度）+ 点击顺序提示
   ├── 古诗：古诗全文展示 + 输入框 + 错字标红
   ├── 步数：加速度计计步 + 进度环
   └── 摇动：摇动计数器 + 震动反馈
底部：退出提示（"响着你也睡不着，不如做任务！"）
```

---

## 7. UI/UX 设计

### 7.1 设计语言（参考 Clucky 极简风）

> Clucky 官网的视觉密码：**超大标题 + 一句话卖点 + 大量留白 + 极简色块 + 轻松诙谐文案**。醒醒鸭沿用这套语言，换成鸭子 IP。

| 原则 | 落地 |
|---|---|
| **极简** | 一屏只讲一件事；去掉装饰线/渐变/阴影堆叠，主体靠留白和对比 |
| **大字标题** | 关键文案用大号粗体（如响铃页"嘎嘎嘎！"、设置页"明天准时醒"） |
| **一句话卖点** | 每个页面顶部一句诙谐文案，如设置页"设置一个闹钟，鸭鸭叫你起床" |
| **单一强调色** | 全 App 主色鸭黄 `#FFC93C` 作唯一强调色，其余克制用黑白灰 |
| **圆润** | 卡片/按钮大圆角（24-32px），手感亲和 |
| **诙谐文案** | 空状态："还没有闹钟，鸭子很寂寞"；完成任务："不错，你是真鸭子！" |
| **动效克制** | 动画只在关键瞬间（开屏、响铃、完成任务），平时页面平稳 |

### 7.2 多主题配色（保留，默认极简风）

| 主题名 | 主背景 | 主色 | 强调色 | 文字 | 风格关键词 |
|---|---|---|---|---|---|
| **素白极简（默认）** | `#FAFAF8` | `#FFFFFF` | `#FFC400` | `#1A1A1A` | Clucky 式留白 + 鸭黄点缀 |
| **鸭塘黄** | `#FFF6E0` | `#FFC93C` | `#FF8A00` | `#4A3B1F` | 明黄、暖、搞笑 |
| **午夜鸭** | `#1A1A2E` | `#3D3D8A` | `#E94560` | `#F5F5F5` | 深蓝、暗红、睡前友好 |
| **薄荷鸭** | `#F0FAF4` | `#4ECDC4` | `#2A9D8F` | `#1F3D36` | 浅绿、清新 |

### 7.3 小鸭 IP —「小雅」（Ducky）

**形象设定**：一只圆润的白鸭（**白鸭 + 粗黑描边 + 大椭圆黑眼**，视觉定稿见 `视觉设计规范（图标·动画·小鸭IP）.md` 与 `assets/branding/VISUAL_SPEC.md`）。

| 项 | 设计 |
|---|---|
| **基础造型** | 暖白身体 `#F5F0E8`/`#FFFFFF` + 粗黑描边 `#1A1A1A`（3-5px）+ 橙喙 `#FF8C00`（带双鼻孔点）+ 大椭圆黑眼（白底/橙虹膜/黑瞳/高光 4 层）+ 粉腮红 `#F2C4B3` + 头顶卷毛 + 右侧曲线翅膀 |
| **比例** | 圆胖 Q 萌，大脑袋小身体，Q 版（头:身 ≈ 1:1.2），歪头盯人 |
| **动作集** | 待机歪头眨眼、探头、鼓腮开叫、走路循环、跳舞、四散飞走（Lottie / 帧动画） |
| **IP 使用位** | 响铃页主角、空状态、结算庆祝、设置页头像、小组件图标 |
| **一致性** | 全 App 只用这一只白鸭，描边/眼型/喙色/腮红/卷毛与图标一致，强化 IP 记忆点 |

> MVP 动画实现：鸭子用 Lottie（`duck_walk_quack.json` 起步，后迁移到定稿风 `ducky_walk_sticker.json`）+ CustomPainter 回退（`_DuckyPainter` 需按白鸭定稿重绘）+ `flutter_animate` 做位移/缩放/呼吸；Phase 3 全面铺开白鸭 Lottie 提升表现力。

### 7.4 开屏动画（Splash）

```
点击 App 图标进入
   ├── 0-0.4s：浅色纯背景（品牌白/鸭黄渐变淡入），居中一只小鸭背影
   ├── 0.4-1.2s：小鸭慢慢转身，探出头（屏侧探头→回中），左看右看，眨眼睛
   ├── 1.2-1.8s：小鸭张大嘴轻声"嘎~"，屏幕浮现品牌字 "醒醒鸭"（描边粗体）
   ├── 1.8-2.2s：小鸭点头一下，文案淡入："嘎，把你叫醒鸭！"
   └── 2.2s：动画淡出 → 进入首页（或冷启动时直接进响铃页）
```

- **冷启动进响铃页时不播完整开屏**（改短版 0.8s），优先保证响铃及时。
- 开屏动画帧序列存 `assets/lottie/splash_ducky.json`（或在原生 splash 层做简易版本）。

### 7.5 字体

- 标题：`Baloo 2`（圆润可爱，呼应鸭IP）+ 超大字号营造"极简大字标题"
- 正文：`Noto Sans SC`
- 数字（统计）：`JetBrains Mono`

### 7.6 动画体系

| 场景 | 动效 | 时长 | 曲线 |
|---|---|---|---|
| **开屏-小鸭** | 转身→探头→眨眼→嘎一声→摇尾巴 | 2.2s | easeOutCubic |
| **预告-探头鸭** | 鸭子从屏幕边缘探头→左顾右盼→缩回（眼睛转动+歪头） | 循环/单次 8s | easeInOutBack |
| **响铃-独鸭开场** | 大鸭从下方弹入 + 鼓腮呼吸（鼓腮即开叫） | 进场 600ms | easeOutBack |
| **响铃-呼应** | 两侧小鸭探头加入，左右摇摆 | 进场 600ms | easeOutBack |
| **响铃-集结** | 底部涌出一排小鸭此起彼伏点头 | 交错入场 1.5s | easeOut |
| **响铃-大军压境** | 满天小鸭旋转/飘浮/跳舞，铺满全屏 | 持续循环 | linear |
| 鸭子待机 | 轻微眨眼/摆头循环 | 循环 3s | easeInOutSine |
| 任务进度环 | 步数/摇动实时进度 | 实时 | — |
| 任务完成 | 鸭群瞬间安静 + 头顶 ✓ 弹跳 | 400ms | easeOutBack |
| 结算页 | 结果卡片 + 得意鸭弹入 | 600ms | easeOutBack |

### 7.7 音效设计

| 音效 | 用途 |
|---|---|
| 鸭叫 A（疯狂嘎嘎） | 默认闹铃声（主音层），循环 |
| 鸭叫 B（温柔嘎） | 温和模式 |
| 鸭叫 C（电音鸭） | 音效包 |
| 鸭叫 小鸭/回声 | Stage 2-4 叠加音层（不同音高、相位、延迟混音） |
| 鸭子得意（胜利） | 任务完成、鸭群收场 |
| 鸭子疑惑 | 舒尔特点错、古诗打错时 |
| 鸭子预告"嘎" | 预告阶段探头时轻声一叫 |
| 开屏"嘎" | 开屏动画小鸭叫那一声 |
| 用户自定义录音 | 我的音效包 |

**音频素材来源（MVP）**：
- 优先从 CC0/CC-BY（署名）授权音源获取鸭叫素材，如 Freesound、Zapsplat、Sonnis。商用前核对授权。
- 文件格式：Android 用 `.ogg`（ExoPlayer/通知声音），iOS 用 `.aac` 或 `.wav`（通知自定义声音）。
- 无授权素材时的兜底方案：程序合成鸭叫（简单正弦波包络），保证 MVP 可发布。

---

## 8. 技术架构

### 8.1 项目结构

```
lib/
├── main.dart                                  # 入口（初始化服务 + 主题）
├── app.dart                                   # MaterialApp + 路由 + Provider
│
├── models/
│   ├── alarm_model.dart                       # 闹钟模型
│   ├── mission_config.dart                    # 任务配置模型
│   └── daily_stat.dart                        # 每日统计模型
│
├── data/
│   ├── built_in_missions.dart                 # 内置任务类型定义
│   ├── poem_bank.dart                         # 古诗库
│   ├── duck_sounds.dart                       # 音效资源清单
│   ├── holiday/
│   │   ├── 2026.json                          # 法定节假日表（当年）
│   │   └── 2027.json                          # （次年）
│   ├── repositories/
│   │   ├── alarm_repository.dart              # 闹钟 CRUD 抽象（MVP: shared_preferences → Phase2: sqflite）
│   │   ├── stat_repository.dart               # 统计读写抽象
│   │   └── mission_progress_repository.dart   # 响铃任务进度读写（alarmId+日期防串）
│   │
│   └── local/
│       ├── prefs_store.dart                   # shared_preferences 封装（MVP 实现）
│       └── sqlite_store.dart                  # sqflite 实现（Phase 2）
│
├── providers/
│   ├── alarm_provider.dart                    # 闹钟列表 CRUD（依赖 alarm_repository）
│   ├── ringing_provider.dart                  # 响铃状态机（RingStage + 任务进度）
│   ├── stats_provider.dart                    # 统计/连续早起（依赖 stat_repository）
│   └── settings_provider.dart                 # 主题/音效/设置
│
├── services/
│   ├── alarm_service.dart                     # platform channel 调度闹钟（原生）
│   ├── sound_service.dart                     # 界面内音效混音（just_audio）
│   ├── mission_service.dart                   # 任务执行逻辑分发
│   ├── step_service.dart                      # 步数（pedometer）/摇动（加速度计）检测
│   ├── holiday_service.dart                   # 节假日判定 + 大小周 + 下次响铃计算
│   └── notification_service.dart              # 本地通知/睡前提醒
│
├── pages/
│   ├── splash_page.dart                        # 开屏动画页（小鸭转身 + 品牌字）
│   ├── alarms_page.dart                        # 闹钟列表
│   ├── alarm_edit_page.dart                    # 新增/编辑闹钟
│   ├── ringing_page.dart                       # 全屏响铃页（核心）
│   ├── mission_page.dart                       # 任务执行页
│   ├── stats_page.dart                         # 统计
│   └── profile_page.dart                       # 我的
│
├── widgets/
│   ├── ducky.dart                              # 小鸭 IP 组件（CustomPainter 基础造型 + 表情/动作）
│   ├── ducky_animation.dart                    # 鸭群集结/开屏等组合动画
│   ├── mission_card.dart                       # 任务配置卡片
│   ├── schulte_grid.dart                      # 舒尔特方格
│   ├── poem_input.dart                         # 古诗输入组件
│   ├── progress_ring.dart                     # 步数/摇动进度环
│   ├── calendar_preview.dart                   # 响铃日历预览（节假日/补班/大小周标注）
│   └── stat_chart.dart                        # 图表
│
└── utils/
    └── constants.dart                         # 颜色/尺寸/分类常量

test/
├── poem_match_test.dart                       # 古诗比对规则（空白/半角标点/正文）
├── schulte_test.dart                          # 舒尔特判定逻辑
├── step_progress_test.dart                    # 步数差值计算
├── mission_progress_test.dart                 # 进度持久化 + alarmId/日期防串
├── stat_calc_test.dart                        # 起床率/连续早起口径
├── holiday_test.dart                          # 节假日/补班/大小周/单日覆盖判定
└── alarm_model_test.dart                      # 闹钟序列化/下次触发时间计算
```

### 8.2 原生层（仅此部分非 Dart）

```
android/
├── app/src/main/kotlin/.../AlarmScheduler.kt   # AlarmManager.setAlarmClock
├── app/src/main/kotlin/.../RingingService.kt   # 前台服务（播放鸭叫 + 音量渐增）
├── app/src/main/kotlin/.../RingingActivity.kt  # 全屏响铃 Activity（锁屏唤醒）
├── app/src/main/kotlin/.../BootReceiver.kt     # 重启恢复闹钟
└── AndroidManifest.xml                          # 权限/服务声明

ios/
└── Runner/.../AlarmScheduler.swift             # AlarmKit（iOS 26+）+ 旧版通知兜底
```
> 说明：iOS 自定义响铃声音直接打包进 App Bundle 并在通知 `sound` 中引用，**不需要** Notification Service Extension（Flutter 扩展里跑不了 Dart，且本场景无动态修改通知内容需求）。

### 8.3 依赖清单

```yaml
# ★ = Phase 1 MVP 必需
# 其余按对应 Phase 再引入

dependencies:
  flutter:
    sdk: flutter

  # ★ 状态管理
  provider: ^6.0.0

  # 音频（二选一）
  just_audio: ^0.9.0        # ★ 界面内音效/试听（响铃音效走原生 ExoPlayer，不走这个）

  # 传感器（★ 步数/摇动）
  sensors_plus: ^6.0.0   # ★ 摇动检测（加速度计原始数据）
  pedometer: ^4.0.0      # ★ 步数任务（Android STEP_COUNTER / iOS CMPedometer）

  # 本地存储
  shared_preferences: ^2.3.0   # ★ 闹钟/设置/任务进度
  sqflite: ^2.3.0              # Phase 2 统计

  # 通知（★ 响铃兜底/睡前提醒）
  flutter_local_notifications: ^18.0.0

  # ★ 权限
  permission_handler: ^11.3.0

  # 隐私锁（Phase 3）
  local_auth: ^2.3.0

  # 桌面小组件（Phase 2）
  home_widget: ^0.7.0

  # 动画
  flutter_animate: ^4.5.0   # ★ 基础动画
  lottie: ^3.1.0            # Phase 3 鸭子 Lottie 动画（MVP 用内置 Sprite/Canvas 先顶着）
```

### 8.4 数据模型

```dart
// 闹钟模型
enum ScheduleType { daily, weekday, legal, bigSmallWeek, custom }
enum RestOrWork { rest, work }

class AlarmModel {
  final String id;
  final TimeOfDay time;            // 响铃时间
  final ScheduleType scheduleType; // 重复类型
  final List<int> repeatDays;      // custom 模式：周一=1 … 周日=7
  final bool skipHoliday;          // 闹钟级：工作日闹钟跳过节假日/周末
  final DateTime? bigSmallBaseWeek; // 大小周基准周
  final Map<String, RestOrWork> dayOverrides; // 单日覆盖（"2026-09-01" → rest/work）
  final String label;              // 标签
  final List<MissionConfig> missions; // 任务组合（1-3 个）
  final String soundPackId;        // 音效包
  final bool volumeFadeIn;         // 音量渐增
  final bool enabled;
}

// 任务配置模型
enum MissionType { schulte, poem, steps, shake }

class MissionConfig {
  final MissionType type;          // 舒尔特/古诗/步数/摇动
  final int difficulty;            // 1-3：舒尔特=格数档、古诗=诗长档（steps/shake 忽略）
  final int target;                // 仅 steps/shake：目标步数 / 摇动次数
  final String? poemId;            // 古诗 ID（type=poem 时）
}

// 响铃状态机（ringing_provider 的核心）
enum RingStage {
  preview,      // 预告阶段（探头鸭）
  stage1,       // 独鸭开场
  stage2,       // 呼应
  stage3,       // 集结
  stage4,       // 大军压境
  mission,      // 任务页
  done,         // 结算页
}

// 每日统计
class DailyStat {
  final DateTime date;
  final bool hasAlarm;             // 当天是否有启用闹钟到点响铃（起床率分母）
  final bool gotUp;                // 是否起床成功（完成全部任务）
  final bool lazyFlag;             // 赖床标签：响铃 30 分钟未完成任务
  final int missionSeconds;        // 任务总耗时（未完成则 0）
  final List<MissionType> done;    // 完成的任务类型
}
```

---

## 9. 数据持久化策略

- **闹钟列表/设置**：`shared_preferences`（JSON）
- **任务进度**：`shared_preferences`（JSON，携带 alarmId + 日期防串，响铃任务中途写入，见 3.4）
- **统计/连续早起**：MVP 用 `shared_preferences` 存 `DailyStat[]`；Phase 2 迁 `sqflite`
- **导出**：统计 + 设置导出为 JSON

### 9.1 古诗素材规范

- 来源：公版《唐诗三百首》/《千家诗》等（作者逝世超 50 年，无版权风险）。
- 难度分级：短=四句绝句 / 中=八句律诗 / 长=十六句长诗。
- 格式规范：每首含 `id / 标题 / 作者 / 朝代 / 诗句数组 / 难度`，标点统一全角（`，。！？`），存入 `data/poem_bank.dart`。
- 数量：MVP 每档 ≥ 10 首（共 ≥ 30 首）。
- 比对规则：忽略首尾空白；半角标点等价全角；只比对正文诗句（见 3.3）。

---

## 10. 后续可扩展

| 功能 | 说明 | 优先级 |
|---|---|---|
| 更多任务类型 | 拍照、扫码、数学题、深蹲、学鸭叫等（Mission 架构已支持扩展） | ⭐⭐⭐ |
| 多种动物音效包 | 鸡叫、狗叫、牛叫……"动物闹钟全家桶" | ⭐⭐ |
| 起床 AI 对话 | 关闹钟前和鸭子 AI 聊两句（TTS/ASR） | ⭐⭐ |
| 贪睡券/成就 | 若想要奖励系统，可后续按模块加入 | ⭐ |
| 多人对战 | 和朋友比连续早起 / 起床时间排行 | ⭐ |
| Apple Watch / Wear OS | 手表端振动提醒 + 完成任务 | ⭐ |
| 天气播报 | 起床后播报今日天气 | ⭐ |

---

## 11. MVP 验收清单与边界情况

### 11.1 MVP 验收清单

| # | 验收项 | 通过标准 |
|---|---|---|
| 1 | 闹钟准时响 | 误差 ≤ 10 秒 |
| 2 | 杀进程仍响 | 从最近任务强制滑掉 App 后，闹钟仍响（Android） |
| 3 | 锁屏亮屏 | 锁屏状态响铃 → 屏幕自动点亮并显示响铃页 |
| 4 | 无法跳过 | Android：响铃页无关闭按钮、返回键无效、Home 后仍在响。iOS：不适用（系统闹钟可被关闭，见"平台能力差异"） |
| 5 | 任务驱动关闭 | 完成全部任务后 1 秒内停响，出现结算页（Android）；iOS 为通知引导进 App 完成任务 |
| 6 | 中途退出续做 | 任务页退出重进，进度从断点继续 |
| 7 | 静音/勿扰仍响 | Android 音量 0 + 勿扰下仍响 |
| 8 | 重启恢复 | 手机关机重启后，已启用的闹钟仍会响 |
| 9 | 无网络可用 | 飞行模式下全流程（响铃+任务）正常 |
| 10 | 权限被拒降级 | 拒绝精确闹钟/通知权限时，App 不崩溃并提示引导 |
| 11 | 节假日跳过 | 工作日闹钟 + 跳过节假日开 → 法定节假日当天不响、调休补班周日响 |
| 12 | 大小周判定 | 大周周六响、小周周六不响（按设定基准周） |
| 13 | 单日覆盖优先 | 指定某天"不响"覆盖节假日/大小周判定 |
| 14 | 开屏动画 | 冷启动播开屏小鸭动画（≤2.5s）→ 进首页；冷启动响铃时短版（≤1s）直接进响铃页 |
| 15 | IP 一致性 | 全 App 小鸭形象统一（造型/配色），响铃页/空状态/设置页/小组件一致 |

### 11.2 边界情况

| 场景 | 处理 |
|---|---|
| 时区/夏令时 | 用系统 `TimeOfDay` + 本地日期计算下一次触发，交给 AlarmKit/AlarmManager 处理时区 |
| 跨天重复 | `23:59` 后的重复闹钟按规则顺延到次日，不丢响 |
| 两闹钟时间重叠 | 同一时刻两个闹钟 → 优先级按列表顺序，后一个并入响铃页显示两个任务组 |
| 任务 30 分钟未完成 | 记"赖床标签"（见 3.5），响铃保持；之后完成仍算成功 |
| 删除正在响的闹钟 | 响铃页继续本次任务，删除只影响下次 |
| 手机重启在响铃中 | 重启后闹钟丢失属系统行为，靠 `BOOT_COMPLETED` 重建未来闹钟，正在响的不恢复 |
| **iOS 用户按系统关闭闹钟** | 系统闹钟界面可被用户直接关闭（AlarmKit 限制，见 4.2）——此时响铃停止、任务未完成，按"起床失败"记账 |

---

## 12. 实现路线图

```
Phase 1 — MVP（核心循环）
├── 工程骨架：Flutter 初始化 + Repository 层（prefs 实现）+ 测试结构
├── 小鸭 IP：ducky.dart（CustomPainter 造型 + 表情/动作）
├── 开屏动画页（SplashPage，短版冷启动 0.8s）
├── 闹钟列表（极简卡片 + 小鸭 IP 空状态）+ 新增/编辑闹钟
├── 节假日系统：离线表 + 判定（daily/weekday/legal/bigSmallWeek/custom + 单日覆盖）
├── 响铃日历预览（30 天，节假日/补班/大小周标注）
├── 原生：Android 前台服务 + RingingActivity(嵌 FlutterView) + 循环鸭叫(ExoPlayer)
├── 原生↔Dart 通信：MethodChannel/EventChannel 接口表实现（4.4）
├── 4 种核心任务：舒尔特方格 / 输入古诗 / 步数(pedometer) / 摇动(加速度计)
├── 任务驱动关闭（无贪睡）+ 任务进度续做（alarmId+日期防串）
├── 响铃状态机 RingStage（preview→stage1-4→mission→done）
├── 开发调试入口：设置页"立即响铃测试"（kDebugMode）
├── 本地持久化（闹钟/设置/进度/统计 → shared_preferences）
├── 统计：文本型（成功/失败天数、连续早起）
└── 单测：古诗比对 / 舒尔特 / 进度防串 / 统计口径 / 节假日判定

Phase 2 — 平台完善
├── iOS 26 AlarmKit 原生实现 + 旧版通知兜底
├── 桌面小组件（小鸭 IP 图标）
├── 睡前提醒通知
├── 重启后闹钟恢复（Android BOOT_COMPLETED）
└── sqflite 统计存储（切换 Repository 实现）

Phase 3 — 体验完善
├── 统计图表（环形图/条形图/排行）
├── 4 套主题 + 暗夜自动切换
├── 隐私锁
├── 数据导出
└── 小鸭 Lottie 动画全面铺开（开屏/鸭群集结/表情包提升表现力）
```

---

## 13. 关键技术风险与对策

| 风险 | 说明 | 对策 |
|---|---|---|
| iOS 后台无法长播 | iOS < 26 静音/勿扰可屏蔽通知音 | iOS 26 优先用 AlarmKit；旧版在设置页明确提示局限 |
| Android 精确闹钟权限 | Android 12+ 需用户授权 SCHEDULE_EXACT_ALARM | 首次设置闹钟时引导授权 + 权限被拒时降级提示 |
| 全屏响铃被 Home/返回键关闭 | 用户按返回键退出全屏 | Activity 屏蔽返回键、接管 Home 事件（devOptions）、前台服务持续播放 |
| 步数/摇动误计 | 加速度计抖动误判 | 步数用系统 `TYPE_STEP_COUNTER` 增量差值；摇动用阈值 + 短时间窗口过滤，需连续快速才算 |
| 步数增量异常 | 用户响铃前已走动，`TYPE_STEP_COUNTER` 是全局累计值 | 响应铃时记录起始值，用差值；重置或重启传感器以当前值为基线 |
| 舒尔特/古诗难度不适配 | 太难劝退或太简单无效 | 提供难度分级，可调格数/诗长 |
| iOS 任务可被绕过 | 系统闹钟界面可被直接关闭 | 产品定位上明确 iOS 为弱化版（通知+引导）；Android 为完整版 |
| 杀进程导致不响 | 国产 ROM 后台限制 | 引导用户加白名单 + 前台服务 + BOOT_COMPLETED 恢复 |
| 任务进度串闹钟 | 上闹钟残留进度被下闹钟误读 | 进度携带 alarmId + 日期，响铃时校验匹配（见 3.4） |
| 节假日表过期 | 跨年后无次年数据，判定失效 | 离线内置当年+次年；设置页联网更新；无表时降级为"默认周几"并提示 |
| 大小周基准漂移 | 用户换周/跨年混乱 | 基准周固化存于闹钟配置；跨年自动按用户基准周延续轮换 |
| 下次响铃计算性能 | 30 天逐日遍历在多闹钟下浪费 | 判定表内存缓存（year → holiday map）；单日覆盖用 HashMap 查询 |


