# 醒醒鸭（wakeup）— 项目架构说明

> 架构设计的权威来源是 `C:\TraeProjects\atjob\鸭叫闹钟App设计文档.md`（简称"设计文档"）。
> 本文档是设计文档第 5、8 章的工程化落地方案：目录职责、模块边界、命名约定、约定顺序。

---

## 1. 技术栈

| 项 | 选择 |
|---|---|
| 框架 | Flutter 3.38.x（stable），Dart 3.10.x |
| 状态管理 | `provider`（单一依赖，MVP 不引入其他状态库） |
| 平台 | Android（minSdk 26）+ iOS（deployment 26.0，AlarmKit） |
| 应用 ID | `com.wakeup.duck`（Android applicationId / iOS Bundle ID 均已配置） |

---

## 2. 目录结构与职责

```
lib/
├── main.dart                    # 入口：初始化服务 → 冷启动分流（响铃页 or 首页）
├── app.dart                     # MaterialApp + 路由表 + Provider 装配
│
├── models/                      # 纯数据模型（无逻辑，可序列化 JSON）
│   ├── alarm_model.dart         #   闹钟（ScheduleType / skipHoliday / 单日覆盖）
│   ├── mission_config.dart      #   任务配置（MissionType / difficulty / target）
│   └── daily_stat.dart          #   每日统计（hasAlarm / gotUp / lazyFlag）
│
├── data/                        # 数据层：静态数据 + 仓库抽象 + 本地实现
│   ├── built_in_missions.dart   #   任务类型定义（含难度档位）
│   ├── poem_bank.dart           #   古诗库（公版，全角标点）
│   ├── duck_sounds.dart         #   音效资源清单（Asset 路径）
│   ├── holiday/                 #   法定节假日表（2026.json / 2027.json …）
│   ├── repositories/            #   ★ Repository 接口（抽象）
│   │   ├── alarm_repository.dart        #   闹钟 CRUD
│   │   ├── stat_repository.dart         #   统计读写
│   │   └── mission_progress_repository.dart  #   响铃任务进度（alarmId+日期防串）
│   └── local/                   #   ★ Repository 实现（可替换存储）
│       ├── prefs_store.dart     #   MVP：shared_preferences 实现
│       └── sqlite_store.dart    #   Phase 2：sqflite 实现
│
├── providers/                   # 状态层：暴露给 UI 的状态 + 业务编排
│   ├── alarm_provider.dart      #   闹钟列表 CRUD（依赖 AlarmRepository）
│   ├── ringing_provider.dart    #   响铃状态机 RingStage + 任务进度
│   ├── stats_provider.dart      #   统计 / 连续早起（依赖 StatRepository）
│   └── settings_provider.dart   #   主题 / 音效 / 设置
│
├── services/                    # 能力层：平台能力与复杂逻辑（无 UI）
│   ├── alarm_service.dart       #   platform channel：schedule/cancel/getStartAlarmId/stopRinging
│   ├── sound_service.dart       #   界面内音效混音（just_audio）
│   ├── mission_service.dart     #   任务执行逻辑分发（各任务判定）
│   ├── step_service.dart        #   步数（pedometer）/ 摇动（加速度计）
│   ├── holiday_service.dart     #   节假日 / 大小周 / 下次响铃计算
│   └── notification_service.dart#   本地通知 / 睡前提醒
│
├── pages/                       # 页面层（有 UI，只消费 Provider / Service）
│   ├── splash_page.dart         #   开屏动画（小鸭转身 + 品牌字）
│   ├── alarms_page.dart         #   闹钟列表
│   ├── alarm_edit_page.dart     #   新增/编辑闹钟
│   ├── ringing_page.dart        #   全屏响铃页（核心）
│   ├── mission_page.dart        #   任务执行页
│   ├── stats_page.dart          #   统计
│   └── profile_page.dart        #   我的
│
├── widgets/                     # 可复用组件（无业务 Provider 依赖）
│   ├── ducky.dart               #   小鸭 IP 组件（CustomPainter 造型 + 表情/动作）
│   ├── ducky_animation.dart     #   鸭群集结 / 开屏组合动画
│   ├── mission_card.dart        #   任务配置卡片
│   ├── schulte_grid.dart        #   舒尔特方格
│   ├── poem_input.dart          #   古诗输入组件
│   ├── progress_ring.dart       #   步数/摇动进度环
│   ├── calendar_preview.dart    #   响铃日历预览（节假日/补班/大小周标注）
│   └── stat_chart.dart          #   图表（Phase 3）
│
└── utils/
    └── constants.dart           # 颜色 / 尺寸 / 文案常量
```

---

## 3. 依赖方向（不可违反）

```
pages ──► providers ──► repositories ──► local(存储)
  │            │
  │            └──► services ──► platform channel / 传感器 / 节假日
  │
  └──► widgets ──► models
```

**规则**：
1. `pages` 只能依赖 `providers` / `widgets` / `models`，**不得**直接碰 `repositories` 或 `local`。
2. `providers` 依赖 `repositories`（接口）与 `services`，**不得** import `local` 具体实现。
3. `repositories` 是接口抽象；`local` 是实现。换存储（prefs → sqlite）只改 `local` 与装配。
4. `models` 不依赖任何上层，纯数据。
5. 页面之间不互相 import（用命名路由跳转）。

---

## 4. 模块边界与关键约定

### 4.1 响铃渲染模型（设计文档 5.1）
- `RingingActivity`（原生壳）只负责：亮屏/锁屏/拦截返回与 Home。
- 鸭群动画、任务、结算全部是 Flutter 页面，渲染在 Activity 内嵌的 FlutterView。
- **App 存活**：复用主引擎，`onRing` 事件 → `Navigator.push` 到响铃路由。
- **App 被杀**：`FlutterEngineGroup` 冷启动，`main.dart` 读 `getStartAlarmId()` 分流，只渲染响铃页。

### 4.2 音频分工
- 后台/锁屏响铃 → 原生 ExoPlayer（`USAGE_ALARM`，音量 30%→100% 渐增）。
- 界面内动画音效 / 任务反馈 → Flutter `just_audio`。
- 切换防断层：进入全屏时原生 500ms 淡出 ↔ Flutter 淡入。
- 接口：`alarm_service.muteBackground(bool)` 控制原生声音待命。

### 4.3 原生 ↔ Dart 通信（Channel：`com.wakeup.duck/alarm`）
| 方向 | 方法 | 说明 |
|---|---|---|
| D→N | `scheduleAlarm(alarmId, timestamp, soundPath)` | 注册下次响铃 |
| D→N | `cancelAlarm(alarmId)` | 取消 |
| D→N | `getStartAlarmId()` | 冷启动取本次响铃 |
| D→N | `stopRinging()` | 任务完成停声 |
| D→N | `muteBackground(bool)` | 全屏接管时原生静音待命 |
| N→D | `onRing(alarmId)`（EventChannel） | App 存活时通知推响铃页 |

### 4.4 响铃状态机
```
enum RingStage { preview, stage1, stage2, stage3, stage4, mission, done }
```
由 `ringing_provider` 持有，单方向推进，任务页回响铃页不倒退（任务中断续做不算倒退）。

### 4.5 任务进度防串
进度 JSON 携带 `{alarmId, triggerDate, ...}`，响铃时校验匹配才续做，否则重置（设计文档 3.4）。

---

## 5. 命名约定

| 类型 | 约定 | 示例 |
|---|---|---|
| 文件 | snake_case | `alarm_edit_page.dart` |
| 类 | PascalCase | `AlarmEditPage` |
| 枚举 | PascalCase + 值小写 | `RingStage.preview` |
| Provider | 后缀 `Provider` | `AlarmProvider` |
| Service | 后缀 `Service` | `HolidayService` |
| Repository | 后缀 `Repository` | `AlarmRepository` |
| 路由常量 | 全大写 | `/alarm-edit` → `AppRoutes.alarmEdit` |
| JSON key | snake_case | `triggerDate` |

---

## 6. 路由表

| 路由 | 页面 | 说明 |
|---|---|---|
| `/` | MainScaffold | 底部导航（闹钟/统计/我的） |
| `/splash` | SplashPage | 开屏（首路由，冷启动响铃时跳过） |
| `/alarm-edit` | AlarmEditPage | 新增/编辑闹钟 |
| `/ringing` | RingingPage | 全屏响铃页 |
| `/mission` | MissionPage | 任务执行页 |

---

## 7. 测试结构

```
test/
├── poem_match_test.dart          # 古诗比对规则（空白/半角标点/正文）
├── schulte_test.dart             # 舒尔特判定逻辑
├── step_progress_test.dart       # 步数差值计算
├── mission_progress_test.dart    # 进度持久化 + alarmId/日期防串
├── stat_calc_test.dart           # 起床率/连续早起口径
├── holiday_test.dart             # 节假日/补班/大小周/单日覆盖判定
└── alarm_model_test.dart         # 闹钟序列化/下次触发时间计算
```

纯逻辑（models / services 判定）优先单测，页面只做轻量 Widget 冒烟测试。

---

## 8. 开发顺序（Phase 1 内部）

1. 工程骨架 + `constants.dart` + 路由表
2. `models`（AlarmModel / MissionConfig / DailyStat）+ 序列化测试
3. `data/holiday` 离线表 + `HolidayService`（判定 + 下次响铃计算）+ `holiday_test`
4. `repositories`（接口）+ `local/prefs_store`（实现）
5. `mission_service`（4 种任务判定）+ 相关单测
6. `widgets/ducky.dart`（IP）+ `splash_page`
7. 原生层（Android AlarmManager + 前台服务 + RingingActivity + channel）
8. `alarm_service` 对接 + 闹钟列表/编辑页
9. `ringing_provider` + 响铃页/任务页串联
10. 统计 + 文本型展示 + 验收清单回归
